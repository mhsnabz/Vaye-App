//
//  ChangePassword.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import FirebaseAuth
class ChangePassword: UIViewController {

    var currentUser : CurrentUser
    var user = Auth.auth().currentUser
    let password : TweeAttributedTextField = {
          let txt = TweeAttributedTextField()
                 txt.placeholder = "Şifrenizi Giriniz"
          txt.font = UIFont(name: Utilities.fontBold, size: 14)!
                 txt.activeLineColor =   UIColor.mainColor()
                 txt.lineColor = .darkGray
                 txt.textAlignment = .center
                 txt.activeLineWidth = 1.5
                 txt.animationDuration = 0.7
           txt.infoFontSize = 10
           txt.infoTextColor = .red
           txt.isSecureTextEntry = true
            txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
                 return txt
       }()
       let newPass : TweeAttributedTextField = {
             let txt = TweeAttributedTextField()
                    txt.placeholder = "Yeni Şifrenizi Giriniz"
             txt.font = UIFont(name: Utilities.fontBold, size: 14)!
                    txt.activeLineColor =   UIColor.mainColor()
                    txt.lineColor = .darkGray
                    txt.textAlignment = .center
                    txt.activeLineWidth = 1.5
                    txt.animationDuration = 0.7
              txt.infoFontSize = 10
              txt.infoTextColor = .red
              txt.isSecureTextEntry = true
               txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
                    return txt
          }()
       
       
       let newPassAgain : TweeAttributedTextField = {
               let txt = TweeAttributedTextField()
                      txt.placeholder = "Yeni Şifrenizi Tekrar Giriniz"
               txt.font = UIFont(name: Utilities.fontBold, size: 14)!
                      txt.activeLineColor =   UIColor.mainColor()
                      txt.lineColor = .darkGray
                      txt.textAlignment = .center
                      txt.activeLineWidth = 1.5
                      txt.animationDuration = 0.7
                txt.infoFontSize = 10
                txt.infoTextColor = .red
                txt.isSecureTextEntry = true
                 txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
                      return txt
            }()
    let buttonChange : UIButton = {
               let btn = UIButton(type: .system)
                  btn.setTitle("Şifreni Değiştir", for: .normal)
              btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)!

                  btn.backgroundColor = UIColor.mainColorTransparent()
                btn.addTarget(self, action: #selector(resetPass), for: .touchUpInside)
                
                  return btn
              }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        hideKeyboardWhenTappedAround()
        addDoneButtonOnKeyboard()
        navigationItem.title = "Şifreni Değiştir"
        
               let stacView = UIStackView(arrangedSubviews: [password,newPass,newPassAgain])
               stacView.axis = .vertical
               stacView.spacing = 14
               stacView.distribution = .fillEqually
               view.addSubview(stacView)
               stacView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 242)
               
               view.addSubview(buttonChange)
        buttonChange.anchor(top: stacView.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 50)
               
               Utilities.styleFilledButton(buttonChange)
        
    }
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Bitti", style: .done, target: self, action: #selector(doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            newPassAgain.inputAccessoryView = doneToolbar
            password.inputAccessoryView = doneToolbar
            newPass.inputAccessoryView = doneToolbar
            
        }

        @objc func doneButtonAction(){
            newPassAgain.resignFirstResponder()
            password.resignFirstResponder()

            newPass.resignFirstResponder()

            
        }
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isOkey = false
       @objc func formValidations()
       {
           if password.text!.isEmpty {
               password.infoLabel.text = "Lütfen Şifrenizi Giriniz"
               
               return
           }else{
                password.infoLabel.text = ""
         
           }
           
           if newPassAgain.text != newPass.text {
               newPassAgain.infoLabel.text = "Şifreleriniz Aynı değil"
               newPass.infoLabel.text = "Şifreleriniz Aynı değil"
                   isOkey = false
               return
           }else{
               isOkey = true
               newPassAgain.infoLabel.text = ""
               newPass.infoLabel.text = ""
           }
        if newPassAgain.text!.count < 6 {
            newPassAgain.infoLabel.text = "Şifreniz Çok Kısa! En az 6 karakter olması gerekiyor"
            newPass.infoLabel.text = "Şifreniz Çok Kısa! En az 6 karakter olması gerekiyor"
                isOkey = false
            return
        }else{
            isOkey = true
            newPassAgain.infoLabel.text = ""
            newPass.infoLabel.text = ""
        }
       }
       @objc func resetPass(){
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
           if isOkey {
               changePassword(email: (user?.email)!, currentPassword: password.text!, newPassword: newPass.text!) { (err) in
                   if let err = err {
                       if err.localizedDescription == "The password is invalid or the user does not have a password."{
                           self.password.infoLabel.text = "Şifreniz Yanlış"
                         Utilities.dismissProgress()
                           return
                       }
                   }else{
                    Utilities.dismissProgress()
                    Utilities.succesProgress(msg: "Şifreniz Başarıyla Değiştirildi")
                   }
               }
           }
           else{
    
            Utilities.dismissProgress()

           }
       }
       func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
           let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
           Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
               if let error = error {
                   completion(error)
               }
               else {
                   Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                       completion(error)
                   })
               }
           })
       }
}
