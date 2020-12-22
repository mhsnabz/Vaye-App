//
//  SplashScreen.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import RevealingSplashView
import FirebaseAuth
import FirebaseFirestore
import Lottie
class SplashScreen: UIViewController {
    var navControl : UIViewController!
    var currentUser : CurrentUser?
    var waitAnimation = AnimationView()
    let splahScreen  = RevealingSplashView(iconImage: UIImage(named: "logo")!, iconInitialSize: CGSize(width: 100 , height: 100), backgroundColor: .white)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        waitAnimation = .init(name : "newton")
        waitAnimation.animationSpeed = 1
        waitAnimation.loopMode = .loop
        view.addSubview(splahScreen)
        
        view.addSubview(waitAnimation)
        waitAnimation.anchor(top: nil, left: nil, bottom: view.bottomAnchor, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 20, marginRigth: 0, width: 100, heigth: 200)
        waitAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waitAnimation.play()
        splahScreen.animationType = .twitter
      
        if Auth.auth().currentUser?.uid != nil {
            
          //  Utilities.waitProgress(msg: nil)
            let db = Firestore.firestore().collection("status").document(Auth.auth().currentUser!.uid)
            db.getDocument { (docSnap, err) in
                if err == nil {
                    if docSnap!.exists {
                        let status = docSnap?.get("status") as! Bool
                        if status
                        {
                         
                            let dbc = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
                            dbc.getDocument { (doc, err) in
                                self.waitAnimation.removeFromSuperview()
                                self.splahScreen.startAnimation {
                                    let vc = MainTabbar()
                                    vc.currentUser = CurrentUser.init(dic: doc!.data()!)
                                    vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                                    self.present(vc, animated: true, completion: nil)
                                    
                                }
                            }
                           
                        }
                        else
                        {
                            self.checkIsCompelte(withUid: Auth.auth().currentUser!.uid)
                            
                        }
                    }
                    else
                    {
                        self.goToNextViewController()
                    }
                    
                }
                
            }
            
        }else{
             goToNextViewController()
            
        }
        
        
    }
    
    private func goToNextViewController(){
        splahScreen.startAnimation {
            self.waitAnimation.removeFromSuperview()
                      let vc = LoginVC()
                      vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                      self.present(vc, animated: true, completion: nil)
                  }
    
   
    }
    
    private func checkIsCompelte(withUid uid : String){
        let db = Firestore.firestore().collection("priority").document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                if docSnap!.exists {
                    let priority = docSnap?.get("priority") as! String
                    if priority == "student"
                    {
                        UserService.shared.checkUserIsComplete(uid: uid) { (val) in
                            if val{
                                UserService.shared.getTaskUser(uid: uid) { (user) in
                                    let cont = UINavigationController(rootViewController: SetStudentNumber(taskUser: user))
                                    cont.modalPresentationStyle = .fullScreen
                                    self.present(cont, animated: true) {
                                        self.waitAnimation.removeFromSuperview()
                                    }
                                    
                                }
                            }
                        }
                        
                        
                    }
                    else if priority == "teacher"
                    {
                        self.checkHasExistTeacher(withUid : uid)
                    }
                }
                else{
                    self.waitAnimation.removeFromSuperview()
                   
                    
                   
                }
            }
        }
        
    }
    func checkHasExistTeacher(withUid uid : String!){
        let db = Firestore.firestore().collection("user").document(uid)
        db.getDocument { (doc, err) in
            if err == nil {
                guard let doc = doc else { return }
                if doc.exists {
                    if (doc.get("name")) == nil {
                        Utilities.dismissProgress()
                        
                        let cont = UINavigationController(rootViewController: TeacherVC())
                        cont.modalPresentationStyle = .fullScreen
                        self.present(cont, animated: true, completion: nil)
                        self.waitAnimation.removeFromSuperview()
                    } else if (doc.get("fakulte") == nil){
                        Utilities.dismissProgress()
                        UserService.shared.getCurrentUser(uid: Auth.auth().currentUser!.uid) { (user) in
                            let cont = UINavigationController(rootViewController: SetTeacherFakulte(currentUser : user))
                            cont.modalPresentationStyle = .fullScreen
                            self.present(cont, animated: true, completion: nil)
                            self.waitAnimation.removeFromSuperview()
                        }
                        
                    }
                }else  {
                    Utilities.errorProgress(msg: "Kaydınızı Bulunmuyor")
                    
                    
                    let cont = UINavigationController(rootViewController: LoginVC())
                    cont.modalPresentationStyle = .fullScreen
                    self.present(cont, animated: true, completion: nil)
                    self.waitAnimation.removeFromSuperview()
                        
                }
            }
    }
    
    }

    
    
}
