//
//  NotificaitionCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
import ActiveLabel
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
    lazy var notification : NSMutableAttributedString = {
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
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.numberOfLines = 0
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
        
        if post.type == NotificationType.home_like.desprition{
            type.text = Notification_description.like_home.desprition
            
        }else if post.type == NotificationType.comment_home.desprition{
            notification =  NSMutableAttributedString(string: "\(Notification_description.comment_home.desprition):", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            notification.append(NSAttributedString(string: " \(post.text.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            print(notification)
            type.attributedText = notification
            
        }else if post.type == NotificationType.reply_comment.desprition{
            notification =  NSMutableAttributedString(string: "\(Notification_description.reply_comment.desprition):", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            notification.append(NSAttributedString(string: " \(post.text.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            print(notification)
            type.attributedText = notification
        }else if post.type == NotificationType.comment_like.desprition{
            type.text = Notification_description.comment_like.desprition
        }else if post.type == NotificationType.comment_mention.desprition{
            notification =  NSMutableAttributedString(string: "\(Notification_description.comment_mention.desprition):", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            notification.append(NSAttributedString(string: " \(post.text.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            type.attributedText = notification
        }else if post.type == NotificationType.following_you.desprition{
            
            type.text = post.text
           
            type.textColor = .black
        } else if post.type == NotificationType.home_new_post.desprition{
            notification =  NSMutableAttributedString(string: "\(post.lessonName.description):", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            notification.append(NSAttributedString(string: " \(post.text.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            type.attributedText = notification
            
        } else if post.type == NotificationType.new_ad.desprition{
            notification =  NSMutableAttributedString(string: "\(post.lessonName.description):", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            notification.append(NSAttributedString(string: " \(post.text.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            type.attributedText = notification
        }
        
        
        
        
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username ?? "")", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " \(post.time!.dateValue().timeAgoDisplay())", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
       
        userName.attributedText = name
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: post.senderImage))
        if post.isRead {
            badge.isHidden = true
        }else{
            badge.isHidden = false
        }
    }


}
