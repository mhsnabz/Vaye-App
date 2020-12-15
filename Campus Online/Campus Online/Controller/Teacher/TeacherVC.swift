//
//  TeacherVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 15.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import JDropDownAlert
import FirebaseAuth
import Firebase
import FirebaseStorage
import SVProgressHUD

class TeacherVC: UIViewController {

    
    //MARK:-- variables
    var isExistUserName = true
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var unvanlar = [String]()
    var isSelected = false
    let name : TweeAttributedTextField = {
                 let txt = TweeAttributedTextField()
                  txt.placeholder = "Adınızı ve Soyadınız"
           txt.font = UIFont(name: Utilities.font, size: 14)!
                  txt.activeLineColor =   UIColor.mainColor()
                  txt.lineColor = .darkGray
                  txt.textAlignment = .center
                  txt.activeLineWidth = 1.5
                  txt.animationDuration = 0.7
            txt.infoFontSize = UIFont.smallSystemFontSize
                     txt.infoTextColor = .red
                    txt.infoAnimationDuration = 0.4
            txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
                  
                  return txt
              }()
    let userName : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "@kullanıcı adınınzı belirleyin"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        
        txt.animationDuration = 0.7
        // txt.hideInfo(animated: true)
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        txt.addTarget(self, action: #selector(setUserName), for: .editingDidEnd)
        txt.addTarget(self, action: #selector(isExistUsername), for: .editingDidEnd)
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        return txt
    }()
    var unvan : UIButton = {
       let btn = UIButton()
        btn.setTitle("Unvan Seçinizi", for: .normal)
        btn.backgroundColor = .darkGray
        btn.addTarget(self, action: #selector(unvanSec), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        return btn
    }()
    let devamEtButton : UIButton = {
        
        let btn = UIButton(type: .system)
        btn.setTitle("Devam Et", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
       
       btn.addTarget(self, action: #selector(setTeacherInfo), for: .touchUpInside)

        return btn
   
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.title = "Kaydınızı Tamamlayın"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(unvanCell.self, forCellReuseIdentifier: "id")
        
        view.addSubview(unvan)
        unvan.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 40, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 40)
        
        view.addSubview(name)
        
        name.anchor(top: unvan.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 50)
        view.addSubview(userName)
        userName.anchor(top: name.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 25, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 50)
        
        view.addSubview(devamEtButton)
        devamEtButton.anchor(top: userName.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
         
        
        Utilities.styleFilledButton(devamEtButton)
        devamEtButton.isEnabled = false
        devamEtButton.backgroundColor = .mainColorTransparent()
    }
    
//MARK:--functions
    func getUnvan() -> String{
         if unvan.titleLabel?.text == unvanlar[0]{
             return "Ast."
         }
        
         if unvan.titleLabel?.text == unvanlar[1]{
             return "Ars. Gör."
         }
         if unvan.titleLabel?.text == unvanlar[2]{
             return "Öğr. Gör."
         }
         if unvan.titleLabel?.text == unvanlar[3]{
             return "Dr."
         }
         if unvan.titleLabel?.text == unvanlar[4]{
              return "Doç. Dr."
         }
           if unvan.titleLabel?.text == unvanlar[5]{
          return "Prof. Dr."
           }
         return ""
     }
   //MARK:--selectors
    @objc func unvanSec(){
        unvanlar = ["Asistan","Arastırma Görevlisi","Öğretim Görevlisi","Doktor","Doçent Doktor","Profesör Doktor"]
        selectedButton = unvan
        addTransparentView(frame: unvan.frame)
    }
    func addTransparentView(frame : CGRect)  {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
               transparentView.frame = window?.frame ?? self.view.frame
               transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
               transparentView.alpha = 0
        self.view.addSubview(transparentView)
          tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
           self.view.addSubview(tableView)
         tableView.layer.cornerRadius = 5
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
            transparentView.addGestureRecognizer(tapgesture)
          UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
                  self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.origin.x + 25, width: frame.width, height: CGFloat(self.unvanlar.count * 50))
              }, completion: nil)
     }
    @objc func removeTransparentView(){
        let frame = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
                            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.origin.x + 25, width: frame.width, height:0)
                        }, completion: nil)
    }
    @objc func formValidations() {

        guard  name.hasText && userName.hasText else {
                   devamEtButton.isEnabled = false
                   devamEtButton.backgroundColor = UIColor.mainColorTransparent()
                   return
           }
        devamEtButton.isEnabled = true
        devamEtButton.backgroundColor = UIColor.mainColor()
     }
    @objc func setTeacherInfo(){
        Utilities.waitProgress(msg: "Lütfen Bekleyiniz")
        if isSelected {
            let uid = Auth.auth().currentUser!.uid as String
            let email = Auth.auth().currentUser!.email!
            let _name = ("\(getUnvan())\(name.text!)")
            let _unvan = getUnvan()
            let _username = userName.text
            let dic = ["number":"","name":_name,"slient":[],"profileImage":"","unvan":_unvan,"thumb_image":"","email":email,"priority":"teacher","uid":uid,"username":_username as Any , "instagram": "", "twitter":"","linkedin":"","github":""] as [String : Any]
            let db = Firestore.firestore().collection("user")
                .document(uid)
            db.setData(dic, merge: true) { (err) in
                if err == nil {
                    var dicUsername = Dictionary<String,Any>()
                    dicUsername = ["username":_username as Any,"email":email,"uid":uid]
                    let a = Firestore.firestore().collection("username").document(_username!)
                    a.setData(dicUsername, merge: true) { (err) in
                        if err == nil {
                            let dbTask = Firestore.firestore().collection("user")
                                .document(uid).collection("saved-task")
                                .document("task")
                            
                            dbTask.setData(["data":[]], merge: true) { (err) in
                                if err == nil {
                                    UserService.shared.getCurrentUser(uid: uid) { (user) in
                                        let cont = UINavigationController(rootViewController: SetTeacherFakulte(currentUser: user))
                                         cont.modalPresentationStyle = .fullScreen
                                         self.present(cont, animated: true) {
                                             Utilities.dismissProgress()
                                         }
                                    }
                                  
                                }
                            }
                        }
                    }
                }
            }
        }else{
            Utilities.errorProgress(msg: "Lütfen Ünvan Seçiniz")
        }
    }
    @objc func setUserName(){
        let textInput = userName.text
        let str2 = textInput!.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        userName.text  = "@" + username
        
    }
    @objc func isExistUsername(){
        if userName.text!.count > 2 {
            Utilities.checkUserExist(username: userName.text!) { (value) in
                if value {
                    self.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Alınmış"
                    self.isExistUserName = value
                    return
                }else{
                    self.userName.infoLabel.text = ""
                    self.isExistUserName = value
                    return
                }
            }
        }
        
    }
}
class unvanCell : UITableViewCell {
    
}
extension TeacherVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unvanlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! unvanCell
        cell.textLabel?.text = unvanlar[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           unvan.setTitle(unvanlar[indexPath.row], for: .normal)
             unvan.backgroundColor = .red
        isSelected = true
        self.removeTransparentView()
    }
    
    
}
