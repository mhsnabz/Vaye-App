//
//  RegisterVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import PopupDialog

class RegisterVC: UIViewController {
    
    //MARK: -variables
    var isExistNumber = true
    var isExistUserName = true
    var school : SchoolModel!{
        didSet{
            navigationItem.title = school.shortName.description
        }
    }
    //   MARK: -init
    
    lazy var scroolView : UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.contentSize = CGSize(width: self.view.frame.width, height: 428)
        view.contentSize = .init(width: view.contentSize.width, height: contenViewSize.height)
        view.addSubview(contentView)
        contentView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: self.view.frame.width, heigth: 428)
        return view
    }()
    lazy var contenViewSize  = CGSize(width: self.view.frame.width, height: 428)
    lazy var contentView : UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        
        view.frame.size = contenViewSize
        
        let stackViewLogin = UIStackView(arrangedSubviews: [userName,userNumber,name,email,password,reg])
        stackViewLogin.distribution = .fillEqually
        stackViewLogin.spacing = 12
        stackViewLogin.axis = .vertical
        Utilities.styleTextField(userName)
        Utilities.styleTextField(userNumber)
        Utilities.styleTextField(name)
        Utilities.styleTextField(email)
        Utilities.styleTextField(password)
        Utilities.enabledButton(reg)
        view.addSubview(stackViewLogin)
        let size = stackViewLogin.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        print(size.width)
        print(size.height)
        stackViewLogin.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 286 + 12 + 50)
        
        
        
        //               view.addSubview(reg)
        
        //               reg.anchor(top: stackViewLogin.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
        
        return view
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
        let text1 = NSMutableAttributedString(string: "Zaten Bir Hesabım var ! ",attributes :[NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!
                                                                                               , NSAttributedString.Key.foregroundColor: UIColor.lightGray ])
        
        text1.append(NSAttributedString(string: "Giriş Yap ", attributes :[NSAttributedString.Key.font : UIFont(name:Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor:UIColor.mainColor() ]))
        btn.setAttributedTitle(text1, for: .normal)
        
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return btn
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
    
    let reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Hesap Oluştur", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
        btn.addTarget(self, action: #selector(setNewUser), for: .touchUpInside)
        return btn
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
        txt.autocorrectionType = .no
        txt.returnKeyType = .continue
        txt.autocapitalizationType = .none
        txt.keyboardType = UIKeyboardType.emailAddress
        txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        
        return txt
    }()
    let password :  TweeAttributedTextField = {
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
    let userNumber :  TweeAttributedTextField = {
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
        txt.addTarget(self, action: #selector(isExist), for: .editingDidEnd)
        return txt
    }()
    
    
    
    //    MARK: -lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        setNavigationBar()
        hideKeyboardWhenTappedAround()
        view.addSubview(forgetPassWrodBtn)
        forgetPassWrodBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 16, marginBottom: 12, marginRigth: 16, width: 0, heigth: 0)
        
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
        view.addSubview(scroolView)
        scroolView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: stackViewTerms.topAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width:0, heigth: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - handelers
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroolView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scroolView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroolView.contentInset = contentInset
    }
    
    @objc func isExist()
    {
        if userNumber.text!.count > 2 {
            Utilities.checkUserNumberExist(usernumber: userNumber.text!, school: school.shortName) { (value) in
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
            userNumber.hasText, name.hasText ,email.hasText , password.hasText  else {
            reg.isEnabled = false
            reg.backgroundColor = UIColor.mainColorTransparent()
            return
        }
        
        self.reg.isEnabled = true
        self.reg.backgroundColor = UIColor.mainColor()
        
    }
    @objc func setNewUser (){
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        email.infoLabel.text = ""
        userNumber.infoLabel.text = ""
        password.infoLabel.text = ""
        userName.infoLabel.text = ""
        let username = userName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = userNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let userEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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
            
            if school.shortName == "İSTE"{
                let myStringArr = userEmail!.components(separatedBy: "@")
                
                if myStringArr.count > 1 {
                    print(myStringArr[1])
                    if myStringArr[1] != "iste.edu.tr"{
                        email.infoLabel.text = "@iste.edu.tr Hesabınızla Kaydolmanız Gerekiyor"
                        reg.isHidden = false
                        Utilities.dismissProgress()
                        return
                    }
                }else{
                    email.infoLabel.text = "@iste.edu.tr Hesabınızla Kaydolmanız Gerekiyor"
                    reg.isHidden = false
                    Utilities.dismissProgress()
                    return
                }
            }
            
            
            
            
            let cleanedPass = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedPass.count < 5{
                self.password.infoLabel.text = "En az 6 Karakter Olmalıdır"
                reg.isHidden = false
                Utilities.dismissProgress()
                return
            }
            if isExistNumber{
                reg.isHidden = false
                Utilities.dismissProgress()
                return
            }
            
            
            
            Auth.auth().createUser(withEmail: userEmail!, password: pass!) { (result, error) in
                
                if error != nil {
                    if error?.localizedDescription == "The email address is already in use by another account."{
                        Utilities.errorProgress(msg: "Hata Oluştu")
                        self.reg.isHidden = false
                        self.email.infoLabel.text = "Bu E-Posta Adresi Zaten Kayıtlı "
                        self.reg.isEnabled = false
                        return
                    }
                    if error?.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred."{
                        
                        self.password.infoLabel.text = ""
                        self.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                        self.password.infoLabel.text = ""
                        self.email.infoLabel.text = "Internet Bağlantınızı Kontrol Ediniz"
                        self.reg.isEnabled = false
                        Utilities.errorProgress(msg: nil)
                        return
                    }
                    
                }
                else
                {
                    if result != nil {
                        Utilities.waitProgress(msg: "Kayıt Yapılıyor")
                        var dic = Dictionary<String,Any>()
                        dic = ["number":number!,"name":_name!,"slient":[],"profileImage":"","thumb_image":"","email":result!.user.email!,"priority":"student","uid":result!.user.uid,"short_school":self.school.shortName! ,"schoolName":self.school.name!,"username":username! , "instagram": "", "twitter":"","linkedin":"","github":""]
                        let db = Firestore.firestore().collection("user")
                            .document(result!.user.uid)
                        db.setData(dic, merge: true) { (err) in
                            if err == nil
                            {
                                var dicUsername = Dictionary<String,Any>()
                                dicUsername = ["username":username!,"email":userEmail!,"uid":result!.user.uid]
                                let a = Firestore.firestore().collection("username").document(username!)
                                a.setData(dicUsername, merge: true) { (err) in
                                    if err == nil
                                    {
                                        let dbc = Firestore.firestore()
                                        dbc.collection("priority").document(Auth.auth().currentUser!.uid)
                                            .setData(["priority" : "student"]){ (err) in
                                                
                                                dbc.collection("status").document(Auth.auth().currentUser!.uid)
                                                    .setData(["status":false], merge: true) { (err) in
                                                        if err == nil {
                                                            //user/2YZzIIAdcUfMFHnreosXZOTLZat1/saved-task/task
                                                            let dbTask = Firestore.firestore().collection("user")
                                                                .document(result!.user.uid).collection("saved-task")
                                                                .document("task")
                                                            dbTask.setData(["data":[]] as [String:Any], mergeFields: true) { (err) in
                                                                if err == nil {
                                                                    let vc = SplashScreen()
                                                                    self.navigationController?.pushViewController(vc, animated: true)
                                                                    Utilities.dismissProgress()
                                                                }
                                                            }
                                                            
                                                            
                                                            
                                                        }
                                                    }
                                                
                                                
                                                
                                            }
                                        
                                    }
                                    else{
                                        
                                        Utilities.errorProgress(msg: err?.localizedDescription)
                                        self.reg.isEnabled = false
                                        return
                                    }
                                }
                                
                                
                                
                                
                            }else{
                                Utilities.errorProgress(msg: err?.localizedDescription)
                                self.reg.isEnabled = false
                                return
                            }
                        }
                        
                        
                        
                    }else{
                        Utilities.errorProgress(msg: "Hata Oluştu")
                        self.reg.isEnabled = false
                        return
                    }
                    
                    
                }
                
            }
            
        }
        else{
            reg.isEnabled = false
        }
    }
    
    
    @objc func setUserName(){
        let textInput = userName.text
        let str2 = textInput!.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        userName.text  = "@" + username
        
    }
    @objc func termsOfService(){
        let vc = KullanımKosulları()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func gizlilikPolitikasi(){
        let vc = GizlilikPolitikasi()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func goBack(){
        let vc = LoginVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
