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
            msgText.append(NSAttributedString(string:"\(getMainText(model: model)) : ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
            msgText.append(NSAttributedString(string: model.text, attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
        
    
        mainText.attributedText = msgText
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: model.senderImage!))
        
    }
    private func getMainText(model : NotificationModel) ->String {
        var text : String = ""
        if model.postType == NotificationPostType.lessonPost.name {
            if model.type == MajorPostNotification.comment_like.type{
                text = MajorPostNotification.comment_like.descp
            }else if model.type == MajorPostNotification.new_comment.type{
                text = MajorPostNotification.new_comment.descp
            }else if model.type == MajorPostNotification.new_mentioned_comment.type{
                text = MajorPostNotification.new_mentioned_comment.descp
            }else if model.type == MajorPostNotification.new_post.type{
                text = MajorPostNotification.new_post.descp
            }else if model.type ==  MajorPostNotification.new_mentioned_post.type{
                text = MajorPostNotification.new_mentioned_post.descp
            }else if model.type == MajorPostNotification.post_like.type{
                text = MajorPostNotification.post_like.descp
            }else if model.type == MajorPostNotification.new_replied_comment.type{
                text = MajorPostNotification.new_replied_comment.descp
            }else if model.type == MajorPostNotification.new_replied_mentioned_comment.type{
                text = MajorPostNotification.new_replied_mentioned_comment.descp
            }
        }else if model.postType == NotificationPostType.notices.name{
            if model.type == NoticesPostNotification.comment_like.type{
                text = NoticesPostNotification.comment_like.descp
            }else if model.type == NoticesPostNotification.new_comment.type{
                text = NoticesPostNotification.new_comment.descp
            }else if model.type == NoticesPostNotification.new_mentioned_comment.type{
                text = NoticesPostNotification.new_mentioned_comment.descp
            }else if model.type == NoticesPostNotification.new_post.type{
                text = NoticesPostNotification.new_post.descp
            }else if model.type ==  NoticesPostNotification.new_mentioned_post.type{
                text = NoticesPostNotification.new_mentioned_post.descp
            }else if model.type == NoticesPostNotification.post_like.type{
                text = NoticesPostNotification.post_like.descp
            }else if model.type == NoticesPostNotification.new_replied_comment.type{
                text = NoticesPostNotification.new_replied_comment.descp
            }else if model.type == NoticesPostNotification.new_replied_mentioned_comment.type{
                text = NoticesPostNotification.new_replied_mentioned_comment.descp
            }
        }else if model.postType == NotificationPostType.mainPost.name{
            if model.type == MainPostNotification.comment_like.type{
                text = MainPostNotification.comment_like.descp
            }else if model.type == MainPostNotification.new_comment.type{
                text = MainPostNotification.new_comment.descp
            }else if model.type == MainPostNotification.new_mentioned_comment.type{
                text = MainPostNotification.new_mentioned_comment.descp
            }else if model.type == MainPostNotification.new_post.type{
                text = MainPostNotification.new_post.descp
            }else if model.type ==  MainPostNotification.new_mentioned_post.type{
                text = MainPostNotification.new_mentioned_post.descp
            }else if model.type == MainPostNotification.post_like.type{
                text = MainPostNotification.post_like.descp
            }else if model.type == MainPostNotification.new_replied_comment.type{
                text = MainPostNotification.new_replied_comment.descp
            }else if model.type == MainPostNotification.new_replied_mentioned_comment.type{
                text = MainPostNotification.new_replied_mentioned_comment.type
            }
        }else if model.postType == NotificationPostType.follow.name{
            if model.type == FollowNotification.follow_you.type {
                text = FollowNotification.follow_you.desp
            }
        }
        
        return text
    }
  
}
