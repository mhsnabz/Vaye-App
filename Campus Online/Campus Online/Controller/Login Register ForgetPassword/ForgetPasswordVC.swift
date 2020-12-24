//
//  ForgetPasswordVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import TweeTextField
import FirebaseAuth
import SVProgressHUD
import PopupDialog

class ForgetPasswordVC: UIViewController {
    
    
    let email : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "Sisteme Kayıtlı E-Posta Adresiniz"
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
        // txt.addTarget(self, action: #selector(formValidations), for: .editingChanged)
        
        return txt
    }()
    let resetPassword : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Şifreni Değiştir", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
        
        btn.addTarget(self, action: #selector(resetPassWord), for: .touchUpInside)
        
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Şifreni Sıfırla"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismis))
        view.backgroundColor = .white
        
        
        
        view.addSubview(email)
        email.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 40, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 50)
        
        
        view.addSubview(resetPassword)
        resetPassword.anchor(top: email.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
        
        Utilities.styleFilledButton(resetPassword)
        
    }
    
    @objc func dismis()
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func resetPassWord ()
    {
        Utilities.waitProgress(msg: nil )
        
        guard  email.hasText else {
            email.infoLabel.text = "Lütfen E-Posta Adresinizi Giriniz"
            Utilities.dismissProgress()
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email.text!) { (err) in
            if err != nil {
                if err!.localizedDescription == "The email address is badly formatted." {
                    self.email.infoLabel.text = "Lütfen Geçerli Bir E-Posta Adresi Giriniz"
                    Utilities.dismissProgress()
                    return
                }
                else if  err!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."{
                    self.email.infoLabel.text = "Sisteme Kayıtlı Böyle Bir E-Posta Adresi Yok"
                    Utilities.dismissProgress()
                    return
                    
                }
            }
            else
            {
                Utilities.dismissProgress()
                self.showStandardDialog(animated: true)
            }
        }
    }
    
    
    func showStandardDialog(animated: Bool = true) {
        
        // Prepare the popup
        let title = "E-Posta Gönderildi"
        let message = "Lütfen Gelen Kutunuzu, Spam yada Gereksiz E-postalarınızı \nKontrol Edin "
        
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
            print("Completed")
        }
        let buttonOne = CancelButton(title: "Tamam") {
            self.dismiss(animated: true, completion: nil)
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
}


