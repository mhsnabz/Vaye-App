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

    
    weak var comment : CommentModel? {
        didSet {
            configure()
        }
    }
    
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
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.mentionColor = .systemBlue
        lbl.URLColor = .systemBlue
        lbl.textColor = .black
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
        profile_image.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 35, heigth: 35)
        profile_image.layer.cornerRadius = 35 / 2

        addSubview(userName)
        userName.anchor(top: nil, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 40, width: 0, heigth: 30)
        userName.centerYAnchor.constraint(equalTo: profile_image.centerYAnchor).isActive = true
        
        addSubview(msgText)
        msgText.anchor(top: profile_image.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        
   
        addSubview(likeCount)
        likeCount.anchor(top: msgText.bottomAnchor, left: msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 10)
        addSubview(lblReply)
        lblReply.anchor(top: msgText.bottomAnchor, left: likeCount.rightAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 10)
        
//        addSubview(likeButton)
//        likeButton.anchor(top: profile_image.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 15, heigth: 15)
//       
//        likeButton.centerXAnchor.constraint(equalTo: profile_image.centerXAnchor).isActive = true
//        likeButton.centerYAnchor.constraint(equalTo: msgText.centerYAnchor).isActive = true
        configure()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        guard let comment = comment else { return }
        
        name = NSMutableAttributedString(string: "\(comment.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(comment.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " 12 dk", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        msgText.text = comment.comment
        likeCount.setTitle("\(comment.likes!.count.description) Beğeni", for: .normal)
            
    }
    
}
