//
//  TeacherSignUp.swift
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

class TeacherSignUp: UICollectionViewCell
{
    
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var unvanlar = [String]()
    var is_Selected = false
    
    weak var rootController : SignUp?
    var school : SchoolModel?
    lazy var unvan : UIButton = {
        let btn = UIButton()
        btn.setTitle("Unvan Seçinizi", for: .normal)
        btn.backgroundColor = .lightGray
        btn.addTarget(self, action: #selector(unvanSec), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        return btn
    }()
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
    lazy var name : TweeAttributedTextField = {
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
        
        
        return txt
    }()
    lazy var email : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Kurumsal E-Posta Adresiniz"
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
        
        return txt
    }()
    lazy var reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Hesap Oluştur", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
        
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(unvanCell.self, forCellReuseIdentifier: "id")
        addSubview(unvan)
        unvan.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 20, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 40)
        addSubview(name)
        
        name.anchor(top: unvan.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
        addSubview(email)
        email.anchor(top: name.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 16, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
        addSubview(password)
        password.anchor(top: email.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 16, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
        addSubview(reg)
        reg.anchor(top: password.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 12, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        reg.isEnabled = false
        reg.backgroundColor = .mainColorTransparent()
        Utilities.styleFilledButton(reg)
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
        
        addDoneButtonOnKeyboard()
        password.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        email.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        name.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        reg.addTarget(self, action: #selector(setNewUser), for: .touchUpInside)
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
        
        name.inputAccessoryView = doneToolbar
        password.inputAccessoryView = doneToolbar
        email.inputAccessoryView = doneToolbar
        
    }
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
    @objc func termsOfService(){
        let vc = KullanımKosulları()
        self.rootController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func gizlilikPolitikasi(){
        let vc = GizlilikPolitikasi()
        self.rootController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    @objc func doneButtonAction(){
        name.resignFirstResponder()
        password.resignFirstResponder()
        
        email.resignFirstResponder()
        
    }
    @objc func goBack(){
        let vc = LoginVC()
        vc.modalPresentationStyle = .fullScreen
        self.rootController?.present(vc, animated: true, completion: nil)
    }
    @objc func unvanSec(){
        unvanlar = ["Asistan","Arastırma Görevlisi","Öğretim Görevlisi","Doktor","Doçent Doktor","Profesör Doktor"]
        selectedButton = unvan
        addTransparentView(frame: unvan.frame)
    }
    func addTransparentView(frame : CGRect)  {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        transparentView.frame = window?.frame ?? frame
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        transparentView.alpha = 0
        addSubview(transparentView)
        tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
        addSubview(tableView)
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
}
extension TeacherSignUp : UITableViewDelegate , UITableViewDataSource {
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
        is_Selected = true
        self.removeTransparentView()
    }
    
    @objc func formValidations(){
        guard name.hasText , email.hasText , password.hasText  else{
            reg.isEnabled = false
            reg.backgroundColor = .mainColorTransparent()
            return
        }
        reg.isEnabled = true
        reg.backgroundColor = .mainColor()
    }
    
    @objc func setNewUser(){
        if is_Selected {
            Utilities.waitProgress(msg: "Lütfen Bekleyin")
            email.infoLabel.text = ""
            name.infoLabel.text = ""
            password.infoLabel.text = ""
            
            let userEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let _name = ("\(getUnvan())\(name.text!)")
            let _unvan = getUnvan()
            guard let schooll = school else {
                Utilities.dismissProgress()
                return
            }
            
            if !name.hasText {
                name.infoLabel.text = "Lütfen Adınızı ve Soyadınızı Giriniz"
                Utilities.dismissProgress()
                
                return
            }
            if schooll.shortName == "İSTE"{
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
            
            Auth.auth().createUser(withEmail: userEmail!, password: pass!) { (result, error) in
                guard let result = result else { return }
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
                }else{
                    
                    Utilities.waitProgress(msg: "Hesap Oluşturuluyor...")
                    var dic = Dictionary<String,Any>()
                    dic = ["number":""
                           ,"schoolName":schooll.name as String,
                           "short_school":schooll.shortName as Any 
                           ,"name":_name,
                           "isValid":false,
                           "slient":[],
                           "profileImage":""
                           ,"unvan":_unvan,
                           "thumb_image":"",
                           "email":result.user.email! as String,
                           "priority":"teacher"
                           ,"uid":result.user.uid as String
                           ,"username":"" as Any
                           , "instagram": "",
                           "twitter":""
                           ,"linkedin":""
                           ,"github":""] as [String : Any]
                    
                    let db = Firestore.firestore().collection("task-teacher")
                        .document(result.user.uid)
                    db.setData(dic, merge: true) { [weak self] (err) in
                        guard let sself = self else { return }
                        if err == nil {
                            let dbc = Firestore.firestore()
                            dbc.collection("priority").document(Auth.auth().currentUser!.uid)
                                .setData(["priority" : "teacher"], merge: true) { (err) in
                                    if err == nil {
                                        dbc.collection("status").document(result.user.uid).setData(["status":false] , merge: true) { (err) in
                                            if err == nil {
                                                Utilities.dismissProgress()
                                                
                                                
                                                if let email = result.user.email {
                                                    result.user.sendEmailVerification { (err) in
                                                        if err == nil {
                                                            let alert = UIAlertController(title: "Kayıt Tamamlandı", message: "\(email.description) adresine Bir Tane Doğrulama E-Postası Gönderdik. Lütfen E-Posta Adresinizi Doğrulayınız", preferredStyle: UIAlertController.Style.alert)
                                                            do {
                                                            
                                                                try  Auth.auth().signOut()
                                                               
                                                            }
                                                            catch {
                                                                print("err : \(error.localizedDescription.description)")
                                                            }
                                                            alert.addAction(UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.default, handler: {
                                                            action in
                                                                
                                                                let alert2 = UIAlertController(title: "Sayın \(_name)", message: "Üniversitenizin kurumsal web sitesinden \(_name) araştıracağız. Size destek@vaye.app'den en geç 24 saat içinde onay mesajı göndereceğiz \n\n Bize destek@vaye.app'den ulaşabilirsiniz" , preferredStyle: UIAlertController.Style.alert)
                                                                alert2.addAction(UIAlertAction(title: "TAMAM", style: .default, handler: { (action) in
                                                                    let vc = LoginVC()
                                                                    vc.modalPresentationStyle = .fullScreen

                                                                    sself.rootController?.present(vc, animated: true, completion: {
                                                                       
                                                                    })
                                                                }))
                                                                
                                                                sself.rootController?.present(alert2, animated: true, completion: nil)
                                                            }))
                                                     
                                                         sself.rootController?.present(alert, animated: true, completion: nil)
                                                        }
                                                    }
                                                   
                                                }
                                                
//                                                let alert = UIAlertController(title: "Kayıt Tamamlandı", message: "Hesabınız Onay Aldıktan Sonra Kayıtlı E-Posta Adresinize En Geç 24 saat İçinde Doğrulama E-Postası Göndereceğiz.", preferredStyle: UIAlertController.Style.alert)
//
//                                                // add an action (button)
//                                                alert.addAction(UIAlertAction(title: "TAMAM", style: UIAlertAction.Style.default, handler: {
//                                                    action in
//                                                    let vc = LoginVC()
//                                                    vc.modalPresentationStyle = .fullScreen
//
//                                                    sself.rootController?.present(vc, animated: true, completion: {
//
//                                                    })
//                                                }))
//
//                                                sself.rootController?.present(alert, animated: true, completion: nil)
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
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
                            Utilities.errorProgress(msg: err?.localizedDescription)
                            sself.reg.isEnabled = false
                            return
                        }
                    }
                    
                    
                }
            }
        }else{
            Utilities.errorProgress(msg: "Lütfen Ünvan Seçiniz")
        }
        
        
    }
}
