//
//  CompleteRegistration.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
class CompleteRegistration: UIViewController {

    var currentUser : CurrentUser!
    var _bolumName : String!{
        didSet{
            bolumName.text = _bolumName
        }
    }
    var _fakulteName : String!{
        didSet{
            fakulteName.text = _fakulteName
        }
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
    override func viewDidLoad() {
        super.viewDidLoad()

       setNavigationBar()
        navigationItem.title = "Bilgilerini Kontrol Et"
        view.backgroundColor = .white
        
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
        number.text = currentUser.number
        schoolSortName.text = currentUser.short_school
        
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
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        let dic = ["number":self.currentUser.number as String,"fakulte":_fakulteName as String,"bolum":_bolumName  as String] as [String:Any]
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
        db.setData(dic, merge: true) { (err) in
            if err == nil
            {
                Utilities.waitProgress(msg: "Kayıt Yapılıyor")
                let dbc = Firestore.firestore().collection(self.currentUser.short_school)
                    .document("students").collection("student-number").document(self.currentUser.number)
                let dict = ["name":self.currentUser.name as String,
                            "short_school":self.currentUser.short_school as String,
                            "uid":self.currentUser.uid as String,
                            "email":self.currentUser.email as String] as [String:Any]
                dbc.setData(dict, merge: true) { (err) in
                    if err == nil
                    {
                        let status = Firestore.firestore().collection("status")
                            .document(self.currentUser.uid)
                        status.setData(["status":true] as [String:Any], merge: true) { (err) in
                            if err == nil {
                                Utilities.dismissProgress()
                                let vc = MainTabbar()
                                vc.modalPresentationStyle = .fullScreen
                                vc.currentUser = self.currentUser
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }
        }
    }
    

    

}
