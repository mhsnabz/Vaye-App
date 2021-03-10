//
//  LoginVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import RevealingSplashView
import TweeTextField
import Firebase
import JDropDownAlert
import SVProgressHUD
import FirebaseAuth
import FirebaseFirestore
import PopupDialog
class LoginVC: UIViewController {
    
    
    //MARK: - init
    
    let logoView : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "logo")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    
    let labelContrackt : UILabel = {
        let label = UILabel()
        label.text = "Devam ederek"
        label.font = UIFont(name: Utilities.font, size: 12)!
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    let lbl : UILabel = {
        let label = UILabel()
        label.text = "hükümlerimizi kabul ettiğinizi bildirirsiniz"
        label.font = UIFont(name: Utilities.font, size: 12)!
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    let lblAnd : UILabel = {
        let lbl = UILabel()
        lbl.text = " ve "
        lbl.font =  UIFont(name: Utilities.font, size: 12)!
        return lbl
    }()
    let termsOfServiceBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.textColor = UIColor.mainColor()
        let text1 = NSMutableAttributedString(string: "Hizmet Şartları", attributes :[NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor:  UIColor.mainColor() ])
        btn.setAttributedTitle(text1, for: .normal)
        btn.addTarget(self, action: #selector(termsOfService), for: .touchUpInside)
        return btn
        
    }()
    let privacyPolicy : UIButton = {
        let btn = UIButton(type: .system)
        let text1 = NSMutableAttributedString(string: "Gizlilik Politikası", attributes :[NSAttributedString.Key.font : UIFont(name:Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor:  UIColor.mainColor() ])
        btn.setAttributedTitle(text1, for: .normal)
        btn.addTarget(self, action: #selector(gizlilikPolitikasi), for: .touchUpInside)
        return btn
    }()
    
    let forgetPassWrodBtn : UIButton = {
        let btn = UIButton(type: .system)
        let text1 = NSMutableAttributedString(string: "Şifremi Unuttum ! ", attributes :[NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!
            , NSAttributedString.Key.foregroundColor: UIColor.lightGray ])
        text1.append(NSAttributedString(string: "Şifreni Sıfırla", attributes :[NSAttributedString.Key.font : UIFont(name:Utilities.font, size: 14)!
            , NSAttributedString.Key.foregroundColor:UIColor.mainColor() ]))
        btn.setAttributedTitle(text1, for: .normal)
        btn.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        return btn
    }()
    let email : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "E-posta Adresi(@iste.edu.tr)"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.keyboardType = UIKeyboardType.emailAddress
            txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        
        return txt
    }()
    
    
    let password : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Şifreniz"
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
    let btnLogin : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Giris", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)!
      btn.addTarget(self, action: #selector(login), for: .touchUpInside)
        btn.backgroundColor = UIColor.mainColorTransparent()
        return btn
    }()
    
    let btnReg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kaydol", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)!
        btn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        return btn
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        view.addSubview(logoView)
        hideKeyboardWhenTappedAround()
        
        logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoView.anchor(top: view.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 40, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 100, heigth: 100)
        let stackViewLogin = UIStackView(arrangedSubviews: [email,password,btnLogin])
        stackViewLogin.distribution = .fillEqually
        stackViewLogin.spacing = 14
        stackViewLogin.axis = .vertical
        Utilities.styleTextField(email)
        Utilities.styleTextField(password)
        Utilities.enabledButton(btnLogin)
        view.addSubview(stackViewLogin)
        stackViewLogin.anchor(top: logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 178)
        view.addSubview(btnReg)
        btnReg.anchor(top: stackViewLogin.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 14, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        Utilities.styleHollowButton(btnReg)
        view.addSubview(forgetPassWrodBtn)
        forgetPassWrodBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 16, marginBottom: 32, marginRigth: 16, width: 0, heigth: 0)
        let stackViewTerms = UIStackView(arrangedSubviews: [labelContrackt,termsOfServiceBtn,lblAnd,privacyPolicy])
        stackViewTerms.alignment = .center
        stackViewTerms.axis = .horizontal
        stackViewTerms.spacing = 4
        let stack = UIStackView(arrangedSubviews: [stackViewTerms,lbl])
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.anchor(top: nil, left: view.leftAnchor, bottom: forgetPassWrodBtn.topAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 30, marginRigth: 12, width: 0, heigth: 0)
        email.delegate = self
        password.delegate = self
        
        
    }
    

    //MARK:--functions

    //MARK: -Handelers
    
    @objc func login(){
        Utilities.waitProgress(msg: "Giriş Yapılıyor")
        guard let _email = email.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return}
        guard let pass = password.text else { return }
        Auth.auth().signIn(withEmail: _email, password: pass) {[weak self] (result, err) in
            guard let self = self else {
                Utilities.dismissProgress()
                return }
            if err == nil
            {
                guard let user = result?.user else {
                    Utilities.dismissProgress()
                    return }
                

                let db = Firestore.firestore().collection("user").document(user.uid)
                db.getDocument {[weak self] (docSnap, err) in
                    guard let sself = self else { return }
                    
                    if err == nil {
                        guard let snap = docSnap else { return }
                        if snap.exists {
                            let vc = SplashScreen()
                            vc.currentUser = CurrentUser.init(dic: docSnap!.data()!)
                            vc.modalPresentationStyle = .fullScreen
                            sself.present(vc, animated: true) {
                                Utilities.dismissProgress()
                            }
                        }
                        else{
                            let getPriority = Firestore.firestore().collection("priority")
                                .document(user.uid)
                            getPriority.getDocument { (docSnap, err) in
                                if err == nil {
                                    guard let snap = docSnap else {
                                        Utilities.dismissProgress()
                                        return }
                                    if snap.get("priority") as! String == "teacher" {
                                        UserService.shared.getTaskTeacher(uid: user.uid) { (taskUser) in
                                            guard let isValid = taskUser.isValid else {
                                                Utilities.dismissProgress()
                                                return
                                            }
                                            
                                            if  isValid {
                                                if user.isEmailVerified {
                                                    let vc = SplashScreen()
                                                    vc.modalPresentationStyle = .fullScreen
                                                    sself.present(vc, animated: true) {
                                                        Utilities.dismissProgress()
                                                    }
                                                }else{
                                                    sself.emailDialog(email: user.email!, user: user)
                                                    Utilities.dismissProgress()
                                                    return
                                                }
                                                
                                            }else{
                                                Utilities.dismissProgress()
                                                sself.showWaitingDialog(name: taskUser.name, user: user)
                                                return
                                            }
                                        }
                                    }else if snap.get("priority") as! String == "student"{
                                        UserService.shared.getTaskUser(uid: user.uid) { (taskUser) in
                                            guard let sself = self else { return}
                                            if user.isEmailVerified {
                                                sself.emailDialog(email: user.email!, user: user)
                                                Utilities.dismissProgress()
                                                return
                                            }else{
                                                let vc = SplashScreen()
                                               
                                                vc.modalPresentationStyle = .fullScreen
                                                sself.present(vc, animated: true) {
                                                    Utilities.dismissProgress()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                        
                       
                    }
                }
              
                
            }else{
                if err?.localizedDescription == "The password is invalid or the user does not have a password." {
                    let alert = JDropDownAlert(position: .bottom, direction: .toLeft)
                    alert.alertWith("Hata", message: "Şifreniz Hatalı")
                    self.password.infoLabel.text = "Şifren Hatalı"
                    self.email.infoLabel.text = ""
                    Utilities.dismissProgress()
                    return
                }
                if err?.localizedDescription == "The email address is badly formatted."{
                    self.password.infoLabel.text = ""
                    self.email.infoLabel.text = "E-Posta Adresin Hatalı"
                    let alert = JDropDownAlert(position: .bottom, direction: .toLeft)
                    alert.alertWith("Hata", message: "E-Posta Adresin Hatalı")
                    Utilities.dismissProgress()
                    
                    return
                }
                if err?.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."{
                    self.password.infoLabel.text = ""
                    self.email.infoLabel.text = "E-Posta Adresinde Kayıtlı Kullanıcı Yok"
                    let alert = JDropDownAlert(position: .bottom, direction: .toLeft)
                    alert.alertWith("Hata", message: "E-Posta Adresin Hatalı")
                    Utilities.dismissProgress()
                    
                    return
                }
                if err?.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred."{
                    let alert = JDropDownAlert(position: .bottom, direction: .toLeft)
                    self.password.infoLabel.text = ""
                    self.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                    self.password.infoLabel.text = ""
                    self.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                    alert.alertWith("Ağ Hatası", message: "Internet Bağlantınızı Kontrol Ediniz")
                    Utilities.dismissProgress()
                    
                    return
                }
            }
        }
    }
    func verified (user : FirebaseAuth.User, comletion : @escaping(Bool) -> Void ){
        
        if !user.isEmailVerified {
            self.emailDialog(email: user.email!, user: user)
            do {
                try Auth.auth().signOut()
                //false olacak
                comletion(false)
                return
            }
            catch{
            }
            comletion(true)
        }else{
            comletion(true)
        }
        
    }
    func emailDialog(email : String , user : User)
      {
          let popup = PopupDialog(title: "\(email) ",
              message: "E-poosta Adresinizi Doğrulayamadık. Tekrar E-postası Göndermemizi İstermisiniz ? ",
              buttonAlignment: .vertical,
              transitionStyle: .zoomIn,
              tapGestureDismissal: false,
              panGestureDismissal: true,
              hideStatusBar: true) {
                  print("Completed")
          }
          let buttonOne = DefaultButton(title: "Evet") {
              user.sendEmailVerification { (err) in
                  if err == nil {
                    Utilities.succesProgress(msg: "E-posta Gönderildi")
                  
                      popup.dismiss()
                  }else{
                    Utilities.errorProgress(msg: "Çok Fazla İstek Gönderdiniz , Lütfen Daha Sonra Tekrar Deneyiniz")
                      print(err?.localizedDescription as Any)
                      popup.dismiss();
                  }
              }
              popup.dismiss()
              
          }
          let btn2 = CancelButton(title: "Vazgeç") {
            Utilities.dismissProgress()
          }
          
          popup.addButtons([buttonOne,btn2])
          self.present(popup, animated: true, completion: nil)
      }
    func showWaitingDialog(name : String , user : User){
        let popup = PopupDialog(title: "Sayın \(name) ",
                                message: "Üniversitenizin kurumsal web sitesinden \(name) araştıracağız\n. Size destek@vaye.app'den en geç 24 saat içinde onay mesajı göndereceğiz \n Bize destek@vaye.app'den ulaşabilirsiniz ",
                                buttonAlignment: .vertical,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
                                    print("Completed")
                            }
        let btn2 = DestructiveButton(title: "TAMAM") {
          Utilities.dismissProgress()
        }
        popup.addButtons([btn2])
        self.present(popup, animated: true, completion: nil)
    }

    @objc func formValidations(){
        guard
            email.hasText , password.hasText else {
                btnLogin.isEnabled = false
                btnLogin.backgroundColor = UIColor.mainColorTransparent()
                return
        }
        btnLogin.isEnabled = true
        btnLogin.backgroundColor = UIColor.mainColor()
    }
    @objc func signUp(){
        var centrelController : UIViewController!
        let homeController = ChooseSchool()
        
        centrelController = UINavigationController(rootViewController: homeController)
        centrelController.modalPresentationStyle = .fullScreen
        self.present(centrelController, animated: true, completion: nil)
    }
    @objc func termsOfService(){
        let vc = KullanımKosulları()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func gizlilikPolitikasi(){
        let vc = GizlilikPolitikasi()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func resetPassword()
    {
        let vc = ForgetPasswordVC()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}
extension LoginVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      
           if textField == email {
            textField.returnKeyType = UIReturnKeyType.continue
               password.becomeFirstResponder()
           }
           else if textField == password {
             textField.returnKeyType = UIReturnKeyType.continue
               login()
           }

           return true
       }
}
