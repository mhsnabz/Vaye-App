//
//  CompleteSigingUp.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import PopupDialog

class CompleteSigingUp: UIViewController {

    
    var taskUser  : TaskUser
    var _bolumName : String
    var _fakulteName : String
    
    
    init(taskUser : TaskUser , _bolumName : String , _fakulteName : String) {
        self.taskUser = taskUser
        self._bolumName = _bolumName
        self._fakulteName = _fakulteName
        super.init(nibName: nil, bundle: nil)
    }
    let schoolSortName : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 16)
        lbl.textColor = .black
        return lbl
    }()
    let fakulteName : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .black
        return lbl
    }()
    let bolumName : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .black
        return lbl
    }()
    let number : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .black
        return lbl
    }()
    lazy var v : UIView = {
       let v = UIView()
        v.backgroundColor = UIColor(white: 0.95, alpha: 0.5)
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 0.4
        v.layer.borderColor = UIColor.darkGray.cgColor
    
        return v
    }()
    
    let reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Onayla ve Devam Et", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
     btn.addTarget(self, action: #selector(setNewUser), for: .touchUpInside)
        return btn
    }()
    let imageView : UIImageView = {
       let img = UIImageView()
        img.image = UIImage(named: "alert")!.withRenderingMode(.alwaysOriginal)
        return img
    }()
    let infoLbl : UILabel = {
       let lbl = UILabel ()
        lbl.font = UIFont(name: Utilities.italic, size: 12)
        lbl.textColor = .lightRed
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.text = "Lütfen Bilgilerinizin Doğru Olduğundan Emin Olun Daha Sonra Değiştirilemez!"
        return lbl
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
         navigationItem.title = "Bilgilerini Kontrol Et"
         view.backgroundColor = .white
        bolumName.text = _bolumName
        fakulteName.text = _fakulteName
         let stack = UIStackView(arrangedSubviews: [schoolSortName,fakulteName,bolumName,number])
             stack.axis = .vertical
             stack.distribution = .fillEqually
             stack.spacing = 8
             
             let size = stack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
             
             v.addSubview(stack)
             stack.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: size.width, heigth: size.height)
             stack.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
             stack.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
             
         
         view.addSubview(v)
         v.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: size.width + 20 , heigth: size.height + 20 )
         v.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
         number.text = taskUser.number
         schoolSortName.text = taskUser.short_school
         
         view.addSubview(imageView)
         imageView.anchor(top: v.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 25, heigth: 25)
         view.addSubview(infoLbl)
         infoLbl.anchor(top: v.bottomAnchor, left: imageView.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
         infoLbl.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
         
         view.addSubview(reg)
                reg.anchor(top: infoLbl.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width - 80, heigth: 50)
                reg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                Utilities.styleFilledButton(reg)
    }
    

    @objc func setNewUser()
    {
        Utilities.waitProgress(msg: "Kayıt Tamamlanıyor\n Lütfen Bekleyiniz...")
        var dic = Dictionary<String,Any>()
        dic = ["number":taskUser.number!
               ,"name":taskUser.name!,
               "slient":[]
               ,"profileImage":""
               ,"thumb_image":"",
               "mention":true,"comment":true,"like":true,"follow":true,"lessonNotices":true,
               "friendList":[],
               "email":taskUser.email!,
               "priority":"student",
               "uid":taskUser.uid!,
               "bolum":_bolumName,
               "fakulte":_fakulteName,
               "short_school":taskUser.short_school! ,
               "schoolName":taskUser.schoolName!,
               "username":taskUser.username!,"slientChatUser" : []
               , "instagram": "",
               "twitter":"",
               "linkedin":"",
               "github":""]
        let db = Firestore.firestore().collection("user")
            .document(taskUser.uid)
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                var dicUsername = Dictionary<String,Any>()
                dicUsername = ["username":sself.taskUser.username!,"email":sself.taskUser.email!,"uid":sself.taskUser.uid!]
                let a = Firestore.firestore().collection("username").document(sself.taskUser.username!)
                a.setData(dicUsername, merge: true) { (err) in
                    if err == nil {
                        let dbc = Firestore.firestore()
                        dbc.collection("priority").document(Auth.auth().currentUser!.uid)
                            .setData(["priority" : "student"], merge: true) { (err) in
                                if err == nil {
                                    dbc.collection("status").document(Auth.auth().currentUser!.uid)
                                        .setData(["status":true], merge: true) { (err) in
                                            if err == nil {
                                                //user/2YZzIIAdcUfMFHnreosXZOTLZat1/saved-task/task
                                                let dbTask = Firestore.firestore().collection("user")
                                                    .document(sself.taskUser.uid!).collection("saved-task")
                                                    .document("task")
                                                
                                                dbTask.setData(["data":[]], merge: true) { (err) in
                                                    if err == nil {
                                                        
                                                        let number = Firestore.firestore().collection(sself.taskUser.short_school)
                                                            .document("students").collection("student-number").document(sself.taskUser.number)
                                                        let dict = ["name":sself.taskUser.name as String,
                                                                    "short_school":sself.taskUser.short_school as String,
                                                                    "uid":sself.taskUser.uid as String,
                                                                    "email":sself.taskUser.email as String] as [String:Any]
                                                        number.setData(dict, merge: true) { (err) in
                                                            if err == nil {
                                                                
                                                                let db = Firestore.firestore().collection("task-user")
                                                                    .document(sself.taskUser.uid as String)
                                                                db.delete { (err) in
                                                                    if err == nil {
                                                                        let vc = SplashScreen()
                                                                        
                                                                        sself.navigationController?.pushViewController(vc, animated: true)
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
                                    Utilities.errorProgress(msg: err?.localizedDescription)
                                    sself.reg.isEnabled = false
                                    return
                                }
                            }
                    }else{
                        Utilities.errorProgress(msg: err?.localizedDescription)
                        sself.reg.isEnabled = false
                        return
                    }
                }
            }else{
                Utilities.errorProgress(msg: err?.localizedDescription)
                sself.reg.isEnabled = false
                return
            }
        }
        
    }

}
