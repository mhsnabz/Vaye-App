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
        
        userNumber.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width - 80, heigth: 50)
        userNumber.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        userNumber.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(reg)
        reg.anchor(top: userNumber.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width - 80, heigth: 50)
        reg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
                let dic = ["number":self.userNumber.text!] as [String:Any]
                db.setData(dic, merge: true) { (err) in
                    if err == nil {
                        
                        let cont = UINavigationController(rootViewController: SetFakulte(taskUser: self.taskUser))
                        cont.modalPresentationStyle = .fullScreen
                        self.present(cont, animated: true)
                    
                    }
                }
           
            }
        }
    }
}
