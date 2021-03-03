//
//  SwipeCommentCell.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 3.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SwipeCellKit
import SDWebImage

import ActiveLabel
class SwipeCommentCell: SwipeCollectionViewCell {
    
   
    
    weak var currentUser : CurrentUser?
    weak var commentDelegate : SwipeCommentCellDelegate?
    weak var comment : CommentModel?{
        didSet{
            configure()
            
            guard let currentUser = currentUser else { return }
            checkIsLiked(user: currentUser, post: comment) {[weak self] (val) in
                guard let sself = self else { return }
                if val {
                    sself.likeButton.setImage(#imageLiteral(resourceName: "like").withRenderingMode(.alwaysOriginal), for: .normal)
                }else{
                    sself.likeButton.setImage(#imageLiteral(resourceName: "like-unselected").withRenderingMode(.alwaysOriginal), for: .normal)

                }
            }
        }
    }
    
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
    lazy var likeCount  : UIButton = {
        let lbl = UIButton()
        lbl.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.backgroundColor = .clear
        lbl.setTitleColor(.lightGray, for: .normal)
        lbl.setTitle("100 Beğeni", for: .normal)
        return lbl
    }()
    lazy var lblReply : UIButton = {
        let lbl = UIButton()
        lbl.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.backgroundColor = .clear
        lbl.setTitleColor(.lightGray, for: .normal)
        lbl.isUserInteractionEnabled = true
        lbl.setTitle("Yanıtla", for: .normal)
        return lbl
    }()
   lazy var likeButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "like-unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.isUserInteractionEnabled = true
       
        return btn
        
    }()
    
    lazy var line : UIView = {
       let v = UIView()
        v.backgroundColor = .darkGray
        return v
    }()
    lazy var totalRepliedCount : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 10)

        lbl.textColor = .darkGray
        lbl.isUserInteractionEnabled = true
        
        return lbl
    }()
    
   
    lazy var headerView : UIView = {
       let view = UIView()
        view.addSubview(profile_image)
        profile_image.anchor(top: nil
                             , left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 35, heigth: 35)
        profile_image.layer.cornerRadius = 35 / 2
        profile_image.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(userName)
        userName.anchor(top: nil, left: profile_image.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop:0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 18)
        userName.centerYAnchor.constraint(equalTo: profile_image.centerYAnchor).isActive = true
        
        return view
    }()
    
    lazy var lineView : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
       
        
        addSubview(headerView)
        headerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 4, width: 0, heigth: 40)

        addSubview(msgText)
        addSubview(likeCount)
        likeCount.anchor(top: msgText.bottomAnchor, left: msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
        addSubview(lblReply)
        lblReply.anchor(top: msgText.bottomAnchor, left: likeCount.rightAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
        
        addSubview(likeButton)
        likeButton.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 15, heigth: 15)
        likeButton.centerYAnchor.constraint(equalTo: msgText.centerYAnchor).isActive = true

        
        addSubview(line)
        line.anchor(top: likeCount.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 30, heigth: 2)
        line.centerXAnchor.constraint(equalTo: likeCount.centerXAnchor).isActive = true
        
        addSubview(totalRepliedCount)
        totalRepliedCount.anchor(top: nil, left: line.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 150, heigth: 30)
        totalRepliedCount.centerYAnchor.constraint(equalTo: line.centerYAnchor).isActive = true
        
       
        lblReply.addTarget(self, action: #selector(replyMsg), for: .touchUpInside)
        totalRepliedCount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeAllReplies)))
        profile_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goProfile)))
        likeButton.addTarget(self, action: #selector(likeMsg), for: .touchUpInside)
        
        
        addSubview(lineView)
        lineView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 8, width: 0, heigth: 0.4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -selector
    @objc func likeMsg(){
        print("like msg")
        commentDelegate?.likeClik(cell: self)
    }
    @objc func replyMsg(){
        print("reply msg")
        commentDelegate?.replyClick(cell: self)
    }
    @objc func seeAllReplies(){
        print("see all replies")
        commentDelegate?.seeAllReplies(cell: self)
    }
    @objc func goProfile(){
        commentDelegate?.goProfile(cell : self)
    }
    private func configure(){
        guard let comment = comment else { return }
        name = NSMutableAttributedString(string: "\(comment.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(comment.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        if let time = comment.time {
            name.append(NSAttributedString(string: " \(time.dateValue().timeAgoDisplay())", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

        }else{
            name.append(NSAttributedString(string: " şimdi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

        }
        userName.attributedText = name
        msgText.text = comment.comment
        likeCount.setTitle("\(comment.likes!.count.description) Beğeni", for: .normal)
        totalRepliedCount.text = (comment.replies?.count.description ?? "0") + " yanıtı gör"
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: comment.senderImage!))
        mentionClick()
    }
    private func mentionClick(){
        msgText.handleMentionTap {[weak self] (username) in
            guard let sself = self else { return }
            sself.commentDelegate?.clickMention(username: username)
                
        }
    }
    private func checkIsLiked(user : CurrentUser, post : CommentModel? , completion : @escaping(Bool) ->Void)
    {
        
        guard let post = comment else { return }
        if post.likes!.contains(user.uid){
            completion(true)
        }else{
            completion(false)
        }
    }
}
