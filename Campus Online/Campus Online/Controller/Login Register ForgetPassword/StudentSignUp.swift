//
//  StudentSignUp.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 21.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import PopupDialog


class StudentSignUp: UICollectionViewCell {
    //MARK: -variables
    var isExistNumber = true
    var isExistUserName = true
    weak var rootController : SignUp?
    var school : SchoolModel?
    lazy var labelContrackt : UILabel = {
        let label = UILabel()
        label.text = "Devam ederek"
        label.font = UIFont(name: Utilities.font, size: 12)!
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    lazy var lbl : UILabel = {
        let label = UILabel()
        label.text = "hükümlerimizi kabul ettiğinizi bildirirsiniz"
        label.font = UIFont(name: Utilities.font, size: 12)!
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    lazy var lblAnd : UILabel = {
        let lbl = UILabel()
        lbl.text = " ve "
        lbl.font =  UIFont(name: Utilities.font, size: 12)!
        return lbl
    }()
    lazy var termsOfServiceBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.textColor = UIColor.mainColor()
        let text1 = NSMutableAttributedString(string: "Hizmet Şartları", attributes :[NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor:  UIColor.mainColor() ])
        btn.setAttributedTitle(text1, for: .normal)
        btn.addTarget(self, action: #selector(termsOfService), for: .touchUpInside)
        return btn
        
    }()
    lazy var privacyPolicy : UIButton = {
        let btn = UIButton(type: .system)
        let text1 = NSMutableAttributedString(string: "Gizlilik Politikası", attributes :[NSAttributedString.Key.font : UIFont(name:Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor:  UIColor.mainColor() ])
        btn.setAttributedTitle(text1, for: .normal)
        btn.addTarget(self, action: #selector(gizlilikPolitikasi), for: .touchUpInside)
        return btn
    }()
    
    lazy var forgetPassWrodBtn : UIButton = {
        let btn = UIButton(type: .system)
        let text1 = NSMutableAttributedString(string: "Zaten Bir Hesabım var ! ",attributes :[NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray ])
        
        text1.append(NSAttributedString(string: "Giriş Yap ", attributes :[NSAttributedString.Key.font : UIFont(name:Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor:UIColor.mainColor() ]))
        btn.setAttributedTitle(text1, for: .normal)
        
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Hesap Oluştur", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
        btn.addTarget(self, action: #selector(setNewUser), for: .touchUpInside)
        return btn
    }()
    
  
    lazy var email : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "E-posta Adresi(Kurumsal E-Posta Adresi)"
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
        txt.returnKeyType = .continue
        txt.autocapitalizationType = .none
        txt.keyboardType = UIKeyboardType.emailAddress
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        
        return txt
    }()
    lazy var password :  TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Şifre Belirleyin"
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
        txt.returnKeyType = .continue
        txt.isSecureTextEntry = true
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        return txt
    }()
    lazy var userNumber :  TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Okul Numaran"
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
//        txt.addTarget(self, action: #selector(isExist), for: .editingDidEnd)
        return txt
    }()
    lazy var scroolView : UIScrollView = {
        let v = UIScrollView(frame: .zero)
        v.contentSize = CGSize(width: frame.width, height: 304)
        v.contentSize = .init(width: v.contentSize.width, height: content_view.frame.height)
        v.addSubview(content_view)
        content_view.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width, heigth: 304)
        return v
    }()
    lazy var contenViewSize  = CGSize(width: frame.width, height: 304)
    lazy var content_view : UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        
        view.frame.size = contenViewSize
        
        let stackViewLogin = UIStackView(arrangedSubviews: [userNumber,email,password,reg])
        stackViewLogin.distribution = .fillEqually
        stackViewLogin.spacing = 12
        stackViewLogin.axis = .vertical

        Utilities.styleTextField(userNumber)

        Utilities.styleTextField(email)
        Utilities.styleTextField(password)
        Utilities.enabledButton(reg)
        view.addSubview(stackViewLogin)
        let size = stackViewLogin.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        stackViewLogin.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 162 + 12 + 50)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        rootController?.hideKeyboardWhenTappedAround()
        addDoneButtonOnKeyboard()
        addSubview(forgetPassWrodBtn)
        forgetPassWrodBtn.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 16, marginBottom: 12, marginRigth: 16, width: 0, heigth: 0)
        let stackViewTerms = UIStackView(arrangedSubviews: [labelContrackt,termsOfServiceBtn,lblAnd,privacyPolicy])
        stackViewTerms.alignment = .center
        stackViewTerms.axis = .horizontal
        stackViewTerms.spacing = 4
        let stack = UIStackView(arrangedSubviews: [stackViewTerms,lbl])
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.anchor(top: nil, left: leftAnchor, bottom: forgetPassWrodBtn.topAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 30, marginRigth: 12, width: 0, heigth: 0)
        addSubview(scroolView)
        scroolView.anchor(top: topAnchor, left: leftAnchor, bottom: stackViewTerms.topAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width:0, heigth: 0)
  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:--functions
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Bitti", style: .done, target: self, action: #selector(doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            userNumber.inputAccessoryView = doneToolbar
            password.inputAccessoryView = doneToolbar
            email.inputAccessoryView = doneToolbar
            
        }

        @objc func doneButtonAction(){
            userNumber.resignFirstResponder()
            password.resignFirstResponder()

            email.resignFirstResponder()

            
        }
    //MARK:--selectors
   
    
    @objc func setNewUser(){
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        email.infoLabel.text = ""
        userNumber.infoLabel.text = ""
        password.infoLabel.text = ""
       
        let numberr = userNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let userEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let schooll = school else {
            Utilities.dismissProgress()
            return }
        guard let number = numberr else {
            Utilities.dismissProgress()
            return
        }
        Utilities.checkUserNumberExist(usernumber: number, school: schooll.shortName) {[weak self] (val) in
            guard let sself = self else { return }
            if !val {
                
                    if number.count != 9 {
                        sself.userNumber.infoLabel.text = "Okul Numaranız Yanlış"
                        sself.reg.isHidden = false
                        Utilities.dismissProgress()
                        return
                    }
                    
                    if SchoolShortName.ISTE.description == schooll.shortName {
                        let myStringArr = userEmail!.components(separatedBy: "@")
                        
                        if myStringArr.count > 1 {
                            print(myStringArr[1])
                            if myStringArr[1] != "iste.edu.tr"{
                                sself.email.infoLabel.text = "@iste.edu.tr Hesabınızla Kaydolmanız Gerekiyor"
                                sself.reg.isHidden = false
                                Utilities.dismissProgress()
                                return
                            }
                        }else{
                            sself.email.infoLabel.text = "@iste.edu.tr Hesabınızla Kaydolmanız Gerekiyor"
                            sself.reg.isHidden = false
                            Utilities.dismissProgress()
                            return
                        }
                        
                    }
                let cleanedPass = sself.password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    if cleanedPass.count < 5{
                        sself.password.infoLabel.text = "En az 6 Karakter Olmalıdır"
                        sself.reg.isHidden = false
                        Utilities.dismissProgress()
                        return
                    }
                    
                    Auth.auth().createUser(withEmail: userEmail!, password: pass!) { (result, error) in
                        if error != nil {
                            if error?.localizedDescription == "The email address is already in use by another account."{
                                Utilities.errorProgress(msg: "Hata Oluştu")
                                sself.reg.isHidden = false
                                sself.email.infoLabel.text = "Bu E-Posta Adresi Zaten Kayıtlı "
                                sself.reg.isEnabled = false
                                return
                            }
                            if error?.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred."{
                                
                                sself.password.infoLabel.text = ""
                                sself.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                                sself.password.infoLabel.text = ""
                                sself.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                                sself.reg.isEnabled = false
                                Utilities.errorProgress(msg: nil)
                                return
                            }
                            
                        }else{
                            if result != nil {
                                Utilities.waitProgress(msg: "Kayıt Yapılıyor")
                            
                                let dic = ["number":number,"email":result!.user.email!,"priority":"student","uid":result!.user.uid,"short_school":sself.school?.shortName! as Any ,"schoolName":sself.school?.name! as Any] as [String : Any]
                                
                                let db = Firestore.firestore().collection("task-user")
                                    .document(result!.user.uid)
                                db.setData(dic, merge: true) { (err) in
                                    if err == nil {
                                        let dbc = Firestore.firestore()
                                        dbc.collection("priority").document(Auth.auth().currentUser!.uid).setData(["priority" : "student"]) { (err) in
                                            if err == nil {
                                                dbc.collection("status").document(Auth.auth().currentUser!.uid).setData(["status":false], merge: true) { (err) in
                                                    if err == nil {
                                                        Utilities.dismissProgress()
                                                        do {
                                                        
                                                            try  Auth.auth().signOut()
                                                           
                                                        }
                                                        catch {
                                                            print("err : \(error.localizedDescription.description)")
                                                        }
                                                        // create the alert
                                                               let alert = UIAlertController(title: "Kayıt Tamamlandı", message: "\(String(describing: result?.user.email) ) adresine Bir Tane Doğrulama E-Postası Gönderdik. Lütfen E-Posta Adresinizi Doğrulayıp Tekrar Giriş Yapınız", preferredStyle: UIAlertController.Style.alert)

                                                               // add an action (button)
                                                               alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                                                               action in
                                                                let vc = LoginVC()
                                                                vc.modalPresentationStyle = .fullScreen

                                                                sself.rootController?.present(vc, animated: true, completion: {
                                                                   
                                                                })
                                                               }))
                                                        
                                                            sself.rootController?.present(alert, animated: true, completion: nil)
                                                    }
                                                }
                                            }else{
                                                Utilities.dismissProgress()
                                                Utilities.errorProgress(msg: err?.localizedDescription)
                                                sself.reg.isEnabled = false
                                                return
                                            }
                                        }
                                    }else{
                                        Utilities.dismissProgress()
                                        Utilities.errorProgress(msg: err?.localizedDescription)
                                        sself.reg.isEnabled = false
                                        return
                                    }
                                }
                            }else{
                                Utilities.dismissProgress()
                                Utilities.errorProgress(msg: "Hata Oluştu")
                                sself.reg.isEnabled = false
                                return
                            }
                        }
                    }
                
                        
                  
            
            }else{
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: nil)
                sself.userNumber.infoLabel.text = "Bu Numara Zaten Kayıtlı"
                sself.reg.isEnabled = false
                return
            }
    }
    }
    
    @objc func isExist()
    {
        if userNumber.text!.count > 2 {
            guard let shortName = school?.shortName else { return }
            Utilities.checkUserNumberExist(usernumber: userNumber.text!, school: shortName) { (value) in
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
//    @objc func isExistUsername(){
//        if userName.text!.count > 2 {
//            Utilities.checkUserExist(username: userName.text!) { (value) in
//                if value {
//                    self.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Alınmış"
//                    self.isExistUserName = value
//                    return
//                }else{
//                    self.userName.infoLabel.text = ""
//                    self.isExistUserName = value
//                    return
//                }
//            }
//        }
//
//    }
    
    @objc func formValidations() {
        guard
            userNumber.hasText ,email.hasText , password.hasText  else {
            reg.isEnabled = false
            reg.backgroundColor = UIColor.mainColorTransparent()
            return
        }
        
        self.reg.isEnabled = true
        self.reg.backgroundColor = UIColor.mainColor()
        
    }
//    @objc func setUserName(){
//        let textInput = userName.text
//        let str2 = textInput!.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
//        let username = str2.removingAllWhitespaces.lowercased().stripped
//        userName.text  = "@" + username
//
//    }
    
    @objc func termsOfService(){
        let vc = KullanımKosulları()
        self.rootController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func gizlilikPolitikasi(){
        let vc = GizlilikPolitikasi()
        self.rootController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func goBack(){
        let vc = LoginVC()
        vc.modalPresentationStyle = .fullScreen
        self.rootController?.present(vc, animated: true, completion: nil)
    }
    
}

enum SchoolShortName {
    case ISTE
    var description : String{
        switch self{
        
        case .ISTE:
            return "İSTE"
        }
    }
}
