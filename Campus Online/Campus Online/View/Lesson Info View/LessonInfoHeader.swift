//
//  LessonInfoHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class LessonInfoHeader: UICollectionViewCell
{
    
    lazy var headerOne : UIView = {
       let view = UIView()
        view.addSubview(img)
        
        img.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 75, heigth: 75)
        img.layer.cornerRadius = 75 / 2
        
        let stack = UIStackView(arrangedSubviews: [name,username])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        view.addSubview(stack)
        stack.anchor(top: nil, left: img.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        stack.centerYAnchor.constraint(equalTo: img.centerYAnchor).isActive = true
        view.addSubview(fallowerLbl_one)
        fallowerLbl_one.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
      
        return view
    }()
    
    lazy var headerTwo : UIView = {
        let view = UIView()
        view.addSubview(label_header_two)
        label_header_two.anchor(top: view.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
       
        label_header_two.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addSubview(fallowerLbl)
        fallowerLbl.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12,marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
//        view.addSubview(line)
//        line.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.3)
        return view
            
    }()
    
    let line_one : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    let line : UIView = {
          let v = UIView()
           v.backgroundColor = .lightGray
           return v
       }()
    let label_header_two : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 15)
        lbl.text = "Bu Ders Kayıtlı Eğitmen Yok"
        return lbl
    }()
    
    let fallowerLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        lbl.text = "Dersi Takip Edenler"
        return lbl
    }()
    let fallowerLbl_one : UILabel = {
           let lbl = UILabel()
           lbl.font = UIFont(name: Utilities.font, size: 12)
           lbl.textColor = .lightGray
           lbl.textAlignment = .left
           lbl.text = "Dersi Takip Edenler"
           return lbl
       }()
    
     let img : UIImageView = {
           let img = UIImageView()
           img.contentMode = .scaleAspectFit
           img.clipsToBounds = true
           img.backgroundColor = .white
           img.layer.borderColor = UIColor.lightGray.cgColor
           img.layer.borderWidth = 0.4
           return img
       }()
       let name : UILabel = {
           let lbl = UILabel()
           lbl.font = UIFont(name: Utilities.font, size: 15)
           lbl.textColor = .black
            lbl.text = "Prof.Dr.Test Test"
           return lbl
       }()
       let username : UILabel = {
           let lbl = UILabel()
            lbl.text = "@username"
           lbl.font = UIFont(name: Utilities.font, size: 12)
           lbl.textColor = .lightGray
           return lbl
       }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerOne)
        addSubview(headerTwo)
        headerTwo.isHidden = true
        headerOne.isHidden = true
        
             
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
