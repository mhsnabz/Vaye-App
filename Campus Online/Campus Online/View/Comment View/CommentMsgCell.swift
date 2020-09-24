//
//  CommentMsgCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 23.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import ActiveLabel
import SwipeCellKit

class CommentMsgCell: UITableViewCell
{

    let profile_image : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.backgroundColor = .white
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.borderWidth = 0.75
        img.contentMode = .scaleAspectFit
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
        lbl.font = UIFont(name: Utilities.font, size: 10)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.mentionColor = .systemBlue
        lbl.URLColor = .systemBlue
        lbl.textColor = .black
        lbl.text = "Deneme yazılar yazılar falan filanlar @mhsnabz\n 2020-09-24 13:10:43.896020+0300 Campus Online[41689:1631535] TIC Read Status [1:0x0]: 1:57 2020-09-24 13:10:45.254753+0300 Campus Online[41689:1631405] <Google> To get test ads on this device, set: GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ kGADSimulatorID ];"
        return lbl
    }()
  
    let likeCount  : UIButton = {
        let lbl = UIButton()
        lbl.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.backgroundColor = .clear
        lbl.setTitleColor(.lightGray, for: .normal)
        lbl.setTitle("100 Beğeni", for: .normal)
        
        return lbl
    }()
    let lblReply : UIButton = {
        let lbl = UIButton()
        lbl.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.backgroundColor = .clear
        lbl.setTitleColor(.lightGray, for: .normal)
        lbl.setTitle("Yanıtla", for: .normal)
        return lbl
    }()
    let likeButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "like-unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
        
    }()
    
    //MARK: -lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        backgroundColor = .white
       
       addSubview(profile_image)
        profile_image.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        profile_image.layer.cornerRadius = 15

        addSubview(userName)
        userName.anchor(top: nil, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        userName.centerYAnchor.constraint(equalTo: profile_image.centerYAnchor).isActive = true
        
        addSubview(msgText)
        msgText.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        
   
        addSubview(likeCount)
        likeCount.anchor(top: msgText.bottomAnchor, left: msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 0, heigth: 13)
        addSubview(lblReply)
        lblReply.anchor(top: msgText.bottomAnchor, left: likeCount.rightAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 13)
        
        addSubview(likeButton)
        likeButton.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 8, width: 15, heigth: 15)
        likeButton.centerYAnchor.constraint(equalTo: msgText.centerYAnchor).isActive = true
        
        configure()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        name = NSMutableAttributedString(string: "Mahsun Abuzeyitoğlu", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " @mhsnabz", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " 12 dk", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profile_image.image = #imageLiteral(resourceName: "m")
    }
    
}
