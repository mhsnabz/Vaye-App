//
//  SetStudentNumber.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import FirebaseFirestore
import FirebaseAuth

class SetStudentNumber: UIViewController {
    var navControl : UIViewController!
    var taskUser : TaskUser
    //MARK: -variables
    var isExistNumber = true
    var isExistUserName = true
    let userNumber :  TweeAttributedTextField = {
           let txt = TweeAttributedTextField()
           txt.placeholder = "Okul Numaranı Gir"
           txt.font = UIFont(name: Utilities.font, size: 14)!
           txt.activeLineColor =   UIColor.mainColor()
           txt.lineColor = .darkGray
           txt.textAlignment = .center
           txt.activeLineWidth = 1.5
           txt.animationDuration = 0.7
           txt.infoFontSize = UIFont.smallSystemFontSize
           txt.infoTextColor = .red
           txt.infoAnimationDuration = 0.4
           txt.autocorrectionType = .no
           txt.autocapitalizationType = .none
           txt.keyboardType = UIKeyboardType.numberPad
           txt.returnKeyType = .continue
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        txt.addTarget(self, action: #selector(isExist), for: .editingDidEnd)
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
        
        return txt
    }()
    let name : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Adınız ve Soyadınız"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.textContentType = .name
        txt.returnKeyType = .continue
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        
        return txt
    }()
    let reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kaydet ve Devam Et", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
     btn.addTarget(self, action: #selector(setNewUser), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Kaydını Tamamla"
        view.addSubview(userNumber)
        view.addSubview(name)
        view.addSubview(userName)
        hideKeyboardWhenTappedAround()
        name.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 30, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        userName.anchor(top: name.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 16, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        userNumber.anchor(top: userName.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width - 80, heigth: 50)
        
        
        view.addSubview(reg)
        reg.anchor(top: userNumber.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width - 80, heigth: 50)
       
        reg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userNumber.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        Utilities.styleFilledButton(reg)
    }
    
    init(taskUser : TaskUser) {
        self.taskUser = taskUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func setNewUser(){
        name.infoLabel.text = ""
        userNumber.infoLabel.text = ""

        userName.infoLabel.text = ""
        let username = userName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = userNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let _name = name.text
      
        if !isExistUserName && !isExistNumber
        {
            if username!.count < 4 {
                userName.infoLabel.text = "Kullanıcı Adınız En Az 4 Karakterden Oluşmalıdır"
                reg.isEnabled = false
                Utilities.dismissProgress()
                return
            }
            
            if number!.count != 9 {
                userNumber.infoLabel.text = "Okul Numaranız Yanlış"
                reg.isHidden = false
                Utilities.dismissProgress()
                return
            }
            
            if !name.hasText {
                name.infoLabel.text = "Lütfen Adınızı ve Soyadınızı Giriniz"
                Utilities.dismissProgress()
                
                return
            }
          
            guard userNumber.hasText else {
                self.userNumber.infoLabel.text = "Numaranızı Girin Lütfen"
                Utilities.dismissProgress()
                return
            }
            guard userNumber.text?.count == 9 else {
                self.userNumber.infoLabel.text = "Numaranız Yanlış"
                Utilities.dismissProgress()
                return
            }
            self.userNumber.infoLabel.text = ""
            Utilities.waitProgress(msg: "Lütfen Bekleyiniz")
            Utilities.checkUserNumberExist(usernumber: userNumber.text!, school: taskUser.short_school) { (value) in
                if value {
                    Utilities.errorProgress(msg: "Hata")
                    self.userNumber.infoLabel.text = "Bu Numaraya Zaten Bir Öğrenci Kayıtlı"
                    return
                }
                else
                {
                    let db = Firestore.firestore().collection("task-user").document(self.taskUser.uid)
                    let dic = ["number":self.userNumber.text!,"name":_name as Any,"username":username as Any] as [String:Any]
                    db.setData(dic, merge: true) { (err) in
                        if err == nil {
                            UserService.shared.getTaskUser(uid: self.taskUser.uid) { (user) in
                                let cont = UINavigationController(rootViewController: SetFakulte(taskUser: user))
                                cont.modalPresentationStyle = .fullScreen
                                self.present(cont, animated: true)
                            }
                           
                        
                        }
                    }
               
                }
            }
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
    @objc func formValidations() {
        guard
            userNumber.hasText, name.hasText,userNumber.hasText  else {
            reg.isEnabled = false
            reg.backgroundColor = UIColor.mainColorTransparent()
            return
        }
        
        self.reg.isEnabled = true
        self.reg.backgroundColor = UIColor.mainColor()
        
    }
    @objc func isExist()
    {
        if userNumber.text!.count > 2 {
            Utilities.checkUserNumberExist(usernumber: userNumber.text!, school: taskUser.short_school) { (value) in
                if value {
                    self.userNumber.infoLabel.text = "Bu Numara Zaten Kayıtlı"
                    self.isExistNumber = value
                    return
                }else{
                    self.userNumber.infoLabel.text = ""
                    self.isExistNumber = value
                    return
                }
            }
        }
        
    }
}
