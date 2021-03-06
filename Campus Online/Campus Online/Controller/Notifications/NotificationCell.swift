//
//  NotificationCell.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 6.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//
import UIKit
import SwipeCellKit
import SDWebImage
import ActiveLabel
class NotificationCell: SwipeCollectionViewCell {
    weak var model : NotificationModel?{
        didSet{
            configure()
        }
    }
    weak var currentUser : CurrentUser?{
        didSet{
            
        }
    }
    weak var actionDelegate : NotificationActionDelegate?
    let profile_image : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.backgroundColor = .white
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.borderWidth = 0.75
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        return img
    }()
    lazy var msgText : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
  
    let mainText : UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    lazy var lineView : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profile_image)
        profile_image.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 6, marginBottom: 0, marginRigth: 0, width: 35, heigth: 35)
        profile_image.layer.cornerRadius = 35 / 2
        
        contentView.addSubview(mainText)
        
        contentView.addSubview(lineView)
        lineView.anchor(top: nil, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, rigth: contentView.rightAnchor, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 8, width: 0, heigth: 0.4)
        
        profile_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func showProfile(){
        actionDelegate?.imageClick(for : self)
    }
    private func configure(){
        guard let model = model else { return }
        msgText = NSMutableAttributedString(string: "\(model.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        msgText.append(NSAttributedString(string: " \(model.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        if let time = model.time {
            msgText.append(NSAttributedString(string: " \(time.dateValue().timeAgoDisplay()) \n", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

        }else{
            msgText.append(NSAttributedString(string: " şimdi \n", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

        }
        if getTypeDescribing(type: model.type) == Notification_description.comment_home.desprition ||
            getTypeDescribing(type: model.type) == NotificationType.comment_mention.desprition ||
            getTypeDescribing(type: model.type) == Notification_description.notice_mention_comment.desprition ||
            getTypeDescribing(type: model.type) == Notification_description.reply_comment.desprition {
            msgText.append(NSAttributedString(string:"\(getTypeDescribing(type: model.type)) : ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
            msgText.append(NSAttributedString(string: model.text, attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
            
        }else{
            msgText.append(NSAttributedString(string: getTypeDescribing(type: model.type), attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
        }
        mainText.attributedText = msgText
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: model.senderImage!))
        
    }
    
    
    func getTypeDescribing(type : String) -> String {
        if type == NotificationType.home_like.desprition {
            return Notification_description.like_home.desprition
        }
        else if type == NotificationType.comment_home.desprition {
            return Notification_description.comment_home.desprition
        }
        else if type == NotificationType.reply_comment.desprition {
            return Notification_description.reply_comment.desprition
        }
        else if type == NotificationType.comment_like.desprition {
            return Notification_description.comment_like.desprition
        }
        else if type == NotificationType.comment_mention.desprition {
            return Notification_description.comment_mention.desprition
        }
        else if type == NotificationType.following_you.desprition {
            return Notification_description.following_you.desprition
        }
        else if type == NotificationType.home_new_post.desprition {
            return Notification_description.home_new_post.desprition
        }
        else if type == NotificationType.home_new_mentions_post.desprition {
            return Notification_description.home_new_mentions_post.desprition
        }
        else if type == NotificationType.new_ad.desprition {
            return Notification_description.new_ad.desprition
        }
        else if type == NotificationType.like_sell_buy.desprition {
            return Notification_description.like_sell_buy.desprition
        }
        else if type == NotificationType.new_food_me.desprition {
            return Notification_description.new_food_me.desprition
        }
        else if type == NotificationType.like_food_me.desprition {
            return Notification_description.like_food_me.desprition
        }
        else if type == NotificationType.new_camping.desprition {
            return Notification_description.new_camping.desprition
        }
        else if type == NotificationType.like_camping.desprition {
            return Notification_description.like_camping.desprition
        }
        else if type == NotificationType.notices_comment_like.desprition {
            return Notification_description.notices_comment_like.desprition
        }
        
        else if type == NotificationType.notices_replied_comment_like.desprition{
        return Notification_description.notices_replied_comment_like.desprition
        }
        
        else if type == NotificationType.notices_post_like.desprition {
            return Notification_description.notices_post_like.desprition
        }
        
        else if type == NotificationType.notices_new_comment.desprition {
            return Notification_description.notices_new_comment.desprition
        }
        
        else if type == NotificationType.notice_mention_comment.desprition {
            return Notification_description.notice_mention_comment.desprition
        }
        
        else if type == NotificationType.notices_new_post.desprition {
            return Notification_description.notices_new_post.desprition
        }
        
        
        return ""
    }
    
}
