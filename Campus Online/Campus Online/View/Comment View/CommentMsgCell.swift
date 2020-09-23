//
//  CommentMsgCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 23.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import ActiveLabel
class CommentMsgCell: UICollectionViewCell
{

    
    let profile_image : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.backgroundColor = .white
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.borderWidth = 0.75
        return img
    }()
    lazy var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    let userName : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    let msgText : ActiveLabel = {
        let lbl = ActiveLabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.mentionColor = .systemBlue
        lbl.URLColor = .systemBlue
        lbl.textColor = .darkGray
        lbl.text = "602504+0300 Campus Online[3264:622424] WF: _WebFilterIsActive returning: NO "
        return lbl
    }()
  
    
    
    //MARK: -lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    
       addSubview(profile_image)
        profile_image.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        profile_image.layer.cornerRadius = 15
        addSubview(userName)
        userName.anchor(top: nil, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        userName.centerYAnchor.constraint(equalTo: profile_image.centerYAnchor).isActive = true
        
        addSubview(msgText)
        msgText.anchor(top: profile_image.bottomAnchor, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 10, width: 0, heigth: 25)
        
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        name = NSMutableAttributedString(string: "Mahsun Abuzeyitoğle", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " @mhsnabz", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " 12 dk", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
    }
    
}
