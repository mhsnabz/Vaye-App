//
//  HomeVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class HomeVC: UIViewController {
    
    //MARK: -properties
    var centerController : UIViewController!
    var delegate : HomeControllerDelegate?
    var currentUser : CurrentUser?{
        didSet{
            navigationItem.title = currentUser?.bolum
            
        }
    }
    var isMenuOpen : Bool = false
    var barTitle : String?
    var menu = UIButton()
    
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
       
  
        return btn
    }()
    
    //MARK:- lifeCycle
    
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
        } else {
            let rigthBtn = UIBarButtonItem(image: UIImage(named: "menu")!, style: .plain, target: self, action: #selector(menuClick))
            let leftBtn = UIBarButtonItem(image: UIImage(named: "plus")!, style: .plain, target: self, action: #selector(setLessons))
            navigationItem.leftBarButtonItem = rigthBtn
            navigationItem.rightBarButtonItem = leftBtn
        }
        
        setNavigationBar()
        UserService.shared.fetchUser {[weak self] (currentUser) in
            self?.currentUser = currentUser
        }
        
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)

        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
    
    }
    //MARK: - functions
    @objc func newPost(){
        guard let currentUser = currentUser else {
            return
        }
        let vc = ChooseLessonTB(currentUser: currentUser)
        centerController = UINavigationController(rootViewController: vc)
        centerController.modalPresentationStyle = .fullScreen
        self.present(centerController, animated: true, completion: nil)
        
    }
    @objc func setLessons(){
        guard let user = currentUser else { return }
        let vc = LessonList(currentUser: user)
        vc.currentUser = user
        vc.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    @objc func menuClick(){
        self.delegate?.handleMenuToggle(forMenuOption: nil)
        if !isMenuOpen {
            self.isMenuOpen = false
        }
        else{
            self.isMenuOpen = true
            
        }    
    }
    // /İSTE/lesson/Bilgisayar Mühendisliği
    
    private func getBolumName(fakulteName : String){
        guard let currentUser = currentUser else { return }
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("fakulte").collection("fakulte").document(fakulteName)
        db.getDocument { (docSnap, err) in
            if err == nil {
                let children = docSnap!.data()
                for (_, value) in children! {
                    let db = Firestore.firestore().collection("İSTE")
                        .document("lesson").collection(value as! String)
                    db.addDocument(data: ["data":"data"])
                    
                }
                
                
            }
        }
    }
    
}
