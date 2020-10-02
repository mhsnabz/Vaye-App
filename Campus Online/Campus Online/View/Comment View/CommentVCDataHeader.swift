//
//  CommentVCDataHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 1.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import ActiveLabel
import SDWebImage
class CommentVCDataHeader : UITableViewHeaderFooterView{
    
    weak var delegate : CommentVCDataDelegate?
    
    //MARK: -properties
    lazy var filterView = DataView()
    var currentUser : CurrentUser!
    var post : LessonPostModel?{
        didSet {
            configure()
            guard let post = post else { return }
            if !post.data.isEmpty{
                filterView.arrayOfUrl = post.thumbData
                filterView.datasUrl = post.data
                filterView.collectionView.reloadData()
            }
            
            guard let currentUser = currentUser else { return }
            checkIsDisliked(user: currentUser, post: post) {[weak self] (_val) in
                guard let s = self else { return }
                if _val {
                    s.dislike.setImage(#imageLiteral(resourceName: "dislike-selected").withRenderingMode(.alwaysOriginal), for: .normal)
                    
                }else{
                    s.dislike.setImage(#imageLiteral(resourceName: "dislike-unselected").withRenderingMode(.alwaysOriginal), for: .normal)
                    
                }
            }
            checkIsLiked(user: currentUser, post: post) {[weak self] (_val) in
                guard let s = self else { return }
                if _val{
                    s.like.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }else{
                    s.like.setImage(UIImage(named: "like-unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
            checkIsFav(user: currentUser, post: post) {[weak self] (_val) in
                guard let s = self else {  return }
                if _val {
                    s.addfav.setImage(#imageLiteral(resourceName: "fav-selected").withRenderingMode(.alwaysOriginal), for: .normal)
                    
                }else{
                    s.addfav.setImage(#imageLiteral(resourceName: "fav-unselected").withRenderingMode(.alwaysOriginal), for: .normal)
                    
                }
            }
        }
    }
    let profile_image : UIImageView = {
       let image = UIImageView()
        image.clipsToBounds = true
        image.layer.borderWidth = 0.75
        image.layer.borderColor = UIColor.lightGray.cgColor
        image.backgroundColor = .white
        return image
    }()
    
    let nameLbl : UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    var name : NSMutableAttributedString = {
       let name = NSMutableAttributedString()
        return name
    }()
    let lessonName : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray
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
    
    let line : UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    let linkBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    let timeLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.textColor = .lightGray
        return lbl
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
        
        let toolbarStack = UIStackView(arrangedSubviews: [linkBtn,stackLike,stackDisLike,stackComment,addfav])
        toolbarStack.axis = .horizontal
        toolbarStack.distribution = .fillEqually
        view.addSubview(toolbarStack)
        
        toolbarStack.anchor(top: nil, left: view.leftAnchor, bottom: nil , rigth: view.rightAnchor, marginTop: 0 , marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        toolbarStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
      
        
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(profile_image)
        profile_image.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 50, heigth: 50)
        profile_image.layer.cornerRadius = 25
        
        addSubview(nameLbl)
        nameLbl.anchor(top: profile_image.topAnchor, left: profile_image.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        addSubview(lessonName)
        lessonName.anchor(top: nameLbl.bottomAnchor, left: nameLbl.leftAnchor, bottom: nil, rigth: nameLbl.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        
        addSubview(msgText)
        addSubview(filterView)
        filterView.anchor(top: msgText.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 8, marginLeft: 20 ,  marginBottom: 0, marginRigth: 20, width: 0, heigth: 100)
        
        addSubview(timeLbl)
        timeLbl.anchor(top: filterView.bottomAnchor, left: msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 0 ,  marginBottom: 0, marginRigth: 0, width: 0, heigth: 15)
        addSubview(bottomBar)
        
        bottomBar.anchor(top: timeLbl.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 8, marginLeft: 8, marginBottom: 0, marginRigth: 8, width: 0, heigth: 30)
        
        addSubview(line)
        line.anchor(top: bottomBar.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 0.40)
        
        

        like.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        dislike.addTarget(self, action: #selector(dislikeClick), for: .touchUpInside)
        addfav.addTarget(self, action: #selector(addFavClick), for: .touchUpInside)
        profile_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        profile_image.isUserInteractionEnabled = true
    }
    
    
    //MARK:-selectors
    @objc func showData(){
        print("data click")
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
    
    @objc func linkClick(){
        delegate?.linkClick(for : self)
    }
    @objc func showProfile(){
        delegate?.showProfile(for : self)
    }
    
    //MARK: -functions

    private func mentionClick(){
        msgText.handleMentionTap {[weak self] (username) in
            guard let sself = self else { return }
            sself.delegate?.goProfileByMention(userName : username)
        }
    }
    private func checkIsFav(user : CurrentUser , post : LessonPostModel? , completion : @escaping(Bool) ->Void)
    {
        guard let post = post else { return }
        if post.favori.contains(user.uid){
            completion(true)
        }else{
            completion(false)
        }
    }
    private func checkIsLiked(user : CurrentUser, post : LessonPostModel? , completion : @escaping(Bool) ->Void)
    {
        
        guard let post = post else { return }
        if post.likes.contains(user.uid){
            completion(true)
        }else{
            completion(false)
        }
    }
    
    private func checkIsDisliked(user : CurrentUser ,post : LessonPostModel? , completion : @escaping(Bool) ->Void)
    {
        guard let post = post else { return }
        if post.dislike.contains(user.uid){
            completion(true)
        }else{
            completion(false)
        }
    }
    private func configure(){
        guard let post = post else { return }
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yy HH:mm"
        dateFormatterPrint.timeZone = NSTimeZone(name: "UTC + 3") as TimeZone?
        let date =  Date(timeIntervalSince1970: TimeInterval(post.postTime!.seconds))
       
            print(dateFormatterPrint.string(from: date))
            timeLbl.text = dateFormatterPrint.string(from: date)
        
     
        nameLbl.attributedText = name
        profile_image.sd_imageIndicator = SDWebImageActivityIndicator.white
        profile_image.sd_setImage(with: URL(string: post.thumb_image))
        mentionClick()
        lessonName.text = post.lessonName
        msgText.text = post.text
        like_lbl.text = post.likes.count.description
        dislike_lbl.text = post.dislike.count.description
        comment_lbl.text = post.comment.description
        linkBtn.addTarget(self, action: #selector(linkClick), for: .touchUpInside)
        if post.link.isEmpty {
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
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}