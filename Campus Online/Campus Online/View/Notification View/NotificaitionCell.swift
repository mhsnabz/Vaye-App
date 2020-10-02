//
//  NotificaitionCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class NotificaitionCell: UITableViewCell {

    
    weak var model : NotificationModel?{
        didSet {
            configure()
        }
    }
    
    let profile_image : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.75
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.backgroundColor = .white
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
    let type : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .darkGray
        return lbl
    }()
    let badge : UIView = {
       let v = UIView()
        v.clipsToBounds = true
        v.backgroundColor = .red
        return v
    }()
   

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        
        addSubview(profile_image)
        profile_image.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 50, heigth: 50)
        profile_image.layer.cornerRadius = 25
        addSubview(userName)
        userName.anchor(top: profile_image.topAnchor, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 25, width: 0, heigth: 25)
        addSubview(type)
        type.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 25, width: 0, heigth: 0)
        addSubview(badge)
        badge.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 5, marginBottom: 0, marginRigth: 5, width: 15, heigth: 15)
        badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        badge.layer.cornerRadius = 15 / 2
        badge.isHidden = true
    
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    private func configure(){
        guard let post = model else { return }
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username ?? "")", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " \(post.time!.dateValue().timeAgoDisplay())", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
       
        userName.attributedText = name
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: post.senderImage))
        
        type.text = post.type
        
        if post.isRead {
            badge.isHidden = true
        }else{
            badge.isHidden = false
        }
    }


}
