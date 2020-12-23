//
//  SetTeacherVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 23.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import JDropDownAlert
import FirebaseAuth
import Firebase
import FirebaseStorage
import SVProgressHUD

class SetTeacherVC: UIViewController {

    var currentUser : TaskUser
    var isExistUserName = true
    var isSelected = false
    let name : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    let school : UILabel = {
        let lbl = UILabel()
         lbl.font = UIFont(name: Utilities.font, size: 12)
         lbl.textColor = .black
         lbl.numberOfLines = 0
        lbl.textAlignment = .center

         return lbl
    }()
    lazy var userName : TweeAttributedTextField = {
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
        
        return txt
    }()
    let devamEtButton : UIButton = {
        
        let btn = UIButton(type: .system)
        btn.setTitle("Devam Et", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
       
       btn.addTarget(self, action: #selector(setTeacherInfo), for: .touchUpInside)

        return btn
   
        }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Kaydınızı Tamamlayın"
        setNavigationBar()
        view.backgroundColor = .white
        view.addSubview(name)
        name.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 40, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 16)
        view.addSubview(school)
        school.anchor(top: name.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 14)
        school.text = currentUser.schoolName
        name.text = currentUser.name
        
        
        view.addSubview(userName)
        userName.anchor(top: school.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        view.addSubview(devamEtButton)
        devamEtButton.anchor(top: userName.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        Utilities.styleFilledButton(devamEtButton)
    }
    

    init(currentUser : TaskUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-selectors
    @objc func setUserName(){
        let textInput = userName.text
        let str2 = textInput!.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        userName.text  = "@" + username
        
    }
    func isExistUsername(completion : @escaping(Bool) ->Void){
        if userName.text!.count > 2 {
            Utilities.checkUserExist(username: userName.text!) { (value) in
                if value {
                    self.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Alınmış"
                    self.isExistUserName = value
                    completion(value)
                }else{
                    self.userName.infoLabel.text = ""
                    self.isExistUserName = value
                    completion(value)
                }
            }
        }else{
            self.userName.infoLabel.text = "Kullanıcı Adı Çok Kısa"
            Utilities.dismissProgress()
            return
        }
        
    }
    @objc func setTeacherInfo(){
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        setUserName()
        isExistUsername {[weak self] (val) in
            guard let sself = self else { return }
            if val {
                sself.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Alınmış"
                Utilities.dismissProgress()
                return
            }else{
                sself.userName.infoLabel.text = ""
                sself.currentUser.username = sself.userName.text!
                let controller = UINavigationController(rootViewController: TeacherFakulte(currentUser: sself.currentUser))
                controller.modalPresentationStyle = .fullScreen
                sself.present(controller, animated: true) {
                    Utilities.dismissProgress()
                }
            }
        }
    }
    @objc func formValidations() {

        guard  userName.hasText else {
                   devamEtButton.isEnabled = false
                   devamEtButton.backgroundColor = UIColor.mainColorTransparent()
                   return
           }
        devamEtButton.isEnabled = true
        devamEtButton.backgroundColor = UIColor.mainColor()
     }
}
