//
//  NewPostHomeVCData.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import ActiveLabel
import FirebaseFirestore
import SDWebImage
class NewPostHomeVCData : UICollectionViewCell{
    var filterView = DataView()
    weak var delegate : NewPostHomeVCDataDelegate?
    var lessonPostModel : LessonPostModel?{
        didSet {
            configure()
            guard let post = lessonPostModel else { return }
            if !post.data.isEmpty{
                filterView.arrayOfUrl = post.data
            }
        }
    }
    //MARK:- properties
    let profileImage : UIImageView = {
        let imagee = UIImageView()
        imagee.clipsToBounds = true
        imagee.contentMode = .scaleAspectFit
        imagee.layer.borderColor = UIColor.lightGray.cgColor
        imagee.layer.borderWidth = 0.5
        return imagee
        
    }()
    let userName : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    
    let lessonName : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: Utilities.font, size: 10)
        lbl.textColor = .darkGray
        return lbl
    }()
    let optionsButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "down-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let msgText : ActiveLabel = {
        let lbl = ActiveLabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.mentionColor = .systemBlue
        lbl.URLColor = .systemBlue
        lbl.textColor = .black
        return lbl
    }()
    
    let like : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "like-unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let like_lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.text = "24"
        lbl.textColor = .darkGray
        return lbl
    }()
    let dislike : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "dislike-unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let dislike_lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.textColor = .darkGray
        
        
        return lbl
    }()
    let comment : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        return btn
    }()
    let comment_lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.textColor = .darkGray
        
        return lbl
    }()
    let addfav : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "fav-unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn }()
    
    lazy var headerView : UIView = {
        let view = UIView()
        view.addSubview(profileImage)
        profileImage.anchor(top: nil, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        profileImage.layer.cornerRadius = 45 / 2
        profileImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(userName)
        userName.anchor(top: profileImage.topAnchor, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 5, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 18)
        view.addSubview(lessonName)
        lessonName.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: userName.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 14)
        
        view.addSubview(optionsButton)
        optionsButton.anchor(top: profileImage.topAnchor, left: nil, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 8, width: 20, heigth: 20)
        
        
        return view
    }()
    
    
    lazy var bottomBar : UIView = {
        let view = UIView()
        
        
        let stackLike = UIStackView(arrangedSubviews: [like,like_lbl])
        stackLike.axis = .horizontal
        stackLike.spacing = 2
        stackLike.distribution = .fillEqually
        
        let stackDisLike = UIStackView(arrangedSubviews: [dislike,dislike_lbl])
        stackDisLike.axis = .horizontal
        stackDisLike.spacing = 2
        stackDisLike.distribution = .fillEqually
        let stackComment = UIStackView(arrangedSubviews: [comment,comment_lbl])
        stackComment.axis = .horizontal
        stackComment.spacing = 2
        stackComment.distribution = .fillEqually
        
        let toolbarStack = UIStackView(arrangedSubviews: [stackLike,stackDisLike,stackComment,addfav])
        toolbarStack.axis = .horizontal
        toolbarStack.distribution = .fillEqually
        view.addSubview(toolbarStack)
        
        toolbarStack.anchor(top: nil, left: view.leftAnchor, bottom: nil , rigth: view.rightAnchor, marginTop: 0 , marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        toolbarStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    let line : UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    let linkBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "google-drive")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    
    //MARK: -lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerView)
        headerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 60)
        configure()
        addSubview(msgText)
        addSubview(bottomBar)
        addSubview(filterView)
        //
        comment.addTarget(self, action: #selector(commentClick), for: .touchUpInside)
        like.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        dislike.addTarget(self, action: #selector(dislikeClick), for: .touchUpInside)
        addfav.addTarget(self, action: #selector(addFavClick), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(optionsClick), for: .touchUpInside)
        filterView.isUserInteractionEnabled = true
        filterView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(showData)))
        addSubview(linkBtn)
        linkBtn.anchor(top: headerView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 8, marginBottom: 10, marginRigth: 0, width: 50, heigth: 50)
        
        linkBtn.layer.cornerRadius = 25
        linkBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        linkBtn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        linkBtn.layer.shadowOpacity = 1.0
        linkBtn.layer.shadowRadius = 5.0
        linkBtn.layer.masksToBounds = false
        linkBtn.isHidden = true
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-selectors
    @objc func showData(){
        print("data click")
    }
    
    @objc func commentClick() {
        delegate?.comment(for: self)
    }
    @objc func likeClick(){
        delegate?.like(for: self)
    }
    @objc func dislikeClick(){
        delegate?.dislike(for: self)
    }
    @objc func addFavClick(){
        delegate?.fav(for: self)
    }
    @objc func optionsClick(){
        delegate?.options(for: self)
    }
    @objc func linkClick(){
        delegate?.linkClick(for : self)
    }
    //MARK:- functions
    private func getTimesamp(time : Timestamp) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second , .minute , .hour , .day , .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: time.dateValue(), to: now) ?? "0s"
    }
    private func configure(){
        guard let post = lessonPostModel else { return }
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " \(post.postTime.dateValue().timeAgoDisplay())", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: post.thumb_image))
        lessonName.text = post.lessonName
        msgText.text = post.text
        like_lbl.text = post.likes.description
        dislike_lbl.text = post.dislike.description
        comment_lbl.text = post.comment.description
        linkBtn.addTarget(self, action: #selector(linkClick), for: .touchUpInside)
        if post.link.isEmpty{
            linkBtn.isHidden = true
            
        }else{
            linkBtn.isHidden = false
            detectLink(post.link)
        }
        
    }
    private func detectLink(_ link : String){
           let url = NSURL(string: link)
           let domain = url?.host
           guard let link = domain else { return }
           print(link)
           if link == "drive.google.com" || link == "www.drive.google.com" {
               linkBtn.setImage(UIImage(named: "google-drive")?.withRenderingMode(.alwaysOriginal), for: .normal)
               
           }else if link == "dropbox.com" || link == "www.dropbox.com"{
               linkBtn.setImage(UIImage(named: "dropbox")?.withRenderingMode(.alwaysOriginal), for: .normal)
               
           }else if link == "icloud.com" || link == "www.icloud.com"{
               linkBtn.setImage(UIImage(named: "icloud")?.withRenderingMode(.alwaysOriginal), for: .normal)
               
           }else if link == "disk.yandex.com.tr" || link == "disk.yandex.com" || link == "yadi.sk"{
               linkBtn.setImage(UIImage(named: "yandex-disk")?.withRenderingMode(.alwaysOriginal), for: .normal)
               
           }else if link == "onedrive.live.com" || link == "www.onedrive.live.com" || link == "1drv.ms"{
               linkBtn.setImage(UIImage(named: "onedrive")?.withRenderingMode(.alwaysOriginal), for: .normal)
               
           }else if link == "mega.nz" || link == "www.mega.nz"{
               
               linkBtn.setImage( UIImage(named: "mega")?.withRenderingMode(.alwaysOriginal), for: .normal)
           }else{
               self.line.isHidden = true
           }
           
       }
}
