//
//  EditProfile.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SVProgressHUD
import TweeTextField
class EditProfile: UIViewController {
    var currentUser : CurrentUser
    var barTitle : String?
    
    
    //MARK: -init
    let twitter : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "twitter")
        return img
    }()
    let instagram : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "ig")
        return img
    }()
    let linkedin : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "linkedin")
        return img
    }()
    let username : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "username")
        return img
    }()
    let github : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "github")
        return img
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
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        return txt
    }()
    let _github : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "@github"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        return txt
    }()
    
    let _instagram : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "@instagram"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        return txt
    }()
    
    let _twitter : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "@twitter"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        return txt
    }()
    
    let _linkedin : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Linked.in profil linki"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        txt.animationDuration = 0.7
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        return txt
    }()
    
    
    //  MARK: - lifeCycle
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.title = barTitle ?? ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismis))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .plain, target: self, action: #selector(saveDatabase))
        configureUI()
        
        userName.text = currentUser.username
        userName.becomeFirstResponder()
        load()
    }
    
    private func  load() {
        if currentUser.instagram != ""{
            _instagram.text = currentUser.instagram
        }
        if currentUser.github != ""{
            _github.text = currentUser.github
        }
        if currentUser.twitter != ""{
            _twitter.text = currentUser.twitter
        }
        if currentUser.linkedin != ""{
            _linkedin.text = currentUser.linkedin
        }
    }
    
    private func configureUI()
    {
        view.addSubview(username)
        username.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        view.addSubview(userName)
        userName.anchor(top: nil, left: username.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        userName.centerYAnchor.constraint(equalTo: username.centerYAnchor).isActive = true
        
        view.addSubview(github)
        github.anchor(top: username.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 30, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        view.addSubview(_github)
        _github.anchor(top: nil, left: username.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        _github.centerYAnchor.constraint(equalTo: github.centerYAnchor).isActive = true
        
        view.addSubview(linkedin)
        linkedin.anchor(top: github.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 30, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        view.addSubview(_linkedin)
        _linkedin.anchor(top: nil, left: linkedin.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        _linkedin.centerYAnchor.constraint(equalTo: linkedin.centerYAnchor).isActive = true
        
        view.addSubview(instagram)
        instagram.anchor(top: linkedin.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 30, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        view.addSubview(_instagram)
        _instagram.anchor(top: nil, left: instagram.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        _instagram.centerYAnchor.constraint(equalTo: instagram.centerYAnchor).isActive = true
        
        
        view.addSubview(twitter)
        twitter.anchor(top: instagram.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 30, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        view.addSubview(_twitter)
        _twitter.anchor(top: nil, left: twitter.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        _twitter.centerYAnchor.constraint(equalTo: twitter.centerYAnchor).isActive = true
        
        
        
    }
    
    func updateUsername(){
        guard  userName.text  != nil else {
            Utilities.dismissProgress()
            return
        }
        if currentUser.username == userName.text {
            Utilities.dismissProgress()
            Utilities.succesProgress(msg: "Güncellendi")
            dismiss(animated: true, completion: nil)
            return
        }
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        setUserName()
        let db = Firestore.firestore().collection("username")
        db.getDocuments {[weak self] (querySnap, err) in
            if err == nil {
                for doc in querySnap!.documents {
                    if doc.documentID == self?.userName.text {
                        self?.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Kullanılıyor"
                        Utilities.dismissProgress()
                        return
                    }else{
                        let dic = ["email":(self?.currentUser.email)! as String,
                                   "uid":(self?.currentUser.uid)! as String,
                                   "username":(self?.userName.text)! as String] as [String:Any]
                        db.document((self?.currentUser.username)!).delete { (err) in
                            if err == nil {
                                db.document((self?.userName.text)!).setData(dic, merge: true) { (err) in
                                    if err == nil {
                                        let db = Firestore.firestore().collection("user")
                                            .document(Auth.auth().currentUser!.uid)
                                        db.setData(["username":(self?.userName.text)! as String], merge: true) { (err) in
                                            if err == nil {
                                                Utilities.dismissProgress()
                                                SVProgressHUD.showSuccess(withStatus: "Güncellendi")
                                                self?.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    
                    }
                }
            }
        }
        
    }
    func setUserName() {
        guard let text = userName.text else { return }
        let textInput = text
        let str2 = textInput.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        userName.text  = "@" + username
        self.currentUser.username = userName.text
        
        
    }
    func setGithub() ->String{
        guard let text = _github.text else {
            return ""
        }
        
        if text.isEmpty {
            self.currentUser.github = ""
            return ""
        }
        
        let textInput = text
        let str2 = textInput.replacingOccurrences(of: "@,\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        _github.text  = "@" + username
        self.currentUser.github = _github.text
        return "@" + username
    }
    func setTwitter() -> String{
        guard let text = _twitter.text else { return ""}
        if text.isEmpty {
            self.currentUser.twitter = ""
            return ""
        }
        let textInput = text
        let str2 = textInput.replacingOccurrences(of: "@,\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        _twitter.text  = "@" + username
        self.currentUser.twitter = _twitter.text
        return "@" + username
    }
    func setInstagram() -> String{
        guard let text = _instagram.text else { return ""}
        if text.isEmpty {
            self.currentUser.instagram = ""
            return ""
        }
        let textInput = text
        let str2 = textInput.replacingOccurrences(of: "@,\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        _instagram.text  = "@" + username
        self.currentUser.instagram = _instagram.text
        return "@" + username
    }
    func setLinkendin() -> String {
        guard let url = _linkedin.text else { return ""}
        if url.isEmpty {
            self.currentUser.linkedin = ""
            return ""
        }
        self.currentUser.linkedin = url
        return url
    }
    
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func saveDatabase()
    {
        Utilities.waitProgress(msg: "Güncelleniyor")
        let dic = ["instagram":setInstagram() , "twitter": setTwitter()  ,"github":setGithub() ,"linkedin":setLinkendin()] as [String:Any]
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
        db.setData(dic, merge: true) { (err) in
            if err != nil {
                Utilities.errorProgress(msg: "Hata Oluştu")
                print("profile update err : \(err?.localizedDescription as Any)")
                return
            }else {
                self.updateUsername()
               
            }
            
        }
    }
    
}


