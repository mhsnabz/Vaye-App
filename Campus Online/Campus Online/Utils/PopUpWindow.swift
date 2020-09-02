//
//  PopUpWindow.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import TweeTextField

class PopUpWindow : UIView {
    // MARK: - Properties
    
   weak var delegate: PopUpDelegate?
    var target : String? {
        didSet {
            guard let target = target else { return }
            configure(val : target)
            
            if target == DriveLinks.googleDrive.descrpiton{
                btnGo.setTitle("Google Drive Git", for: .normal)
            }else if target == DriveLinks.onedrive.descrpiton{
                   btnGo.setTitle("OneDrive Git", for: .normal)
            }else if target == DriveLinks.yandex.descrpiton{
                   btnGo.setTitle("Yandex Disk'e Git", for: .normal)
            }else if target == DriveLinks.dropbox.descrpiton{
                   btnGo.setTitle("Dropbox'a Git", for: .normal)
            }else if target == DriveLinks.icloud.descrpiton{
                   btnGo.setTitle("iClould'a Git", for: .normal)
            }
            btnAdd.addTarget(self, action: #selector(addLink), for: .touchUpInside)
            btnGo.addTarget(self, action: #selector(go), for: .touchUpInside)
        }
    }
    var showSuccessMessage: Bool?
    
    let link : TweeAttributedTextField = {
         let txt = TweeAttributedTextField()
         txt.placeholder = "Linki Buraya Yapıştırın"
         txt.font = UIFont(name: Utilities.font, size: 14)!
         txt.activeLineColor =   UIColor.mainColor()
         txt.lineColor = .lightGray
         txt.textAlignment = .left
         txt.activeLineWidth = 1.5
         
         txt.animationDuration = 0.7
         // txt.hideInfo(animated: true)
         txt.infoFontSize = UIFont.smallSystemFontSize
         txt.infoTextColor = .red
         txt.infoAnimationDuration = 0.4
            txt.textContentType = .URL
         txt.autocorrectionType = .no
         txt.autocapitalizationType = .none
         txt.returnKeyType = .continue
//         txt.addTarget(self, action: #selector(setUserName), for: .editingDidEnd)
//         txt.addTarget(self, action: #selector(isExistUsername), for: .editingDidEnd)
         
         return txt
     }()
  
    let btnCancel : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "x") ,for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return btn
    }()
   
    let  btnGo : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Drive Git", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        btn.setTitleColor(.white, for: .normal)
     
        return btn
    }()
    let btnAdd : UIButton = {
         let btn = UIButton(type: .system)
         btn.setTitle("Ekle", for: .normal)
         btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
         btn.clipsToBounds = true
         btn.layer.cornerRadius = 5
         btn.setBackgroundColor(color: .lightRed, forState: .normal)
         btn.setTitleColor(.white, for: .normal)
      
         return btn
     }()
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        
   
        
    }
  
    private func configure(val : String!){
        
        addSubview(btnCancel)
        btnCancel.anchor(top: topAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 30, heigth: 30)
        
        addSubview(link)
        
        link.anchor(top: btnCancel.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 50)
  
      
        let stack = UIStackView(arrangedSubviews: [btnGo,btnAdd])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.anchor(top: link.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 35)
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    @objc func addLink(){
        guard let _target = target else { return }
        delegate?.addTarget(_target)
      }
    @objc func go(){
          guard let _target = target else { return }
        delegate?.goDrive(_target)
      }
}
