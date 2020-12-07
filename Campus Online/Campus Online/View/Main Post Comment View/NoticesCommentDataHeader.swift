//
//  NoticesCommentDataHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import ActiveLabel
import SDWebImage
class NoticesCommentDataHeader: UITableViewHeaderFooterView {
    weak var delegate :  NoticesCommenDataHeaderDelegate?
    lazy var filterView = ImageDataView()
    var currentUser : CurrentUser?
    weak var post : NoticesMainModel?{
        didSet{
            configure()
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
        }
    }
    
    
    
    //MARK:-properties
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
        btn.setImage(#imageLiteral(resourceName: "more").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
     lazy var msgText : ActiveLabel = {
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
        
        let toolbarStack = UIStackView(arrangedSubviews: [stackLike,stackDisLike,stackComment])
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
    
  
   
    let timeLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    
    //MARK:- lifeCycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(headerView)
        addSubview(headerView)
        headerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 60)

        addSubview(msgText)
   
        addSubview(bottomBar)
        addSubview(filterView)
        addSubview(timeLbl)
        timeLbl.anchor(top: filterView.bottomAnchor, left: msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 0 ,  marginBottom: 0, marginRigth: 0, width: 0, heigth: 15)
        //
        like.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        dislike.addTarget(self, action: #selector(dislikeClick), for: .touchUpInside)

        
     
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        profileImage.isUserInteractionEnabled = true
        
        addSubview(line)
        line.anchor(top: bottomBar.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 0.40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:-selectors
    
   
    @objc func likeClick(){
        delegate?.like(for: self)
    }
    @objc func dislikeClick(){
        delegate?.dislike(for: self)
    }
    
   
    @objc func showProfile(){
        delegate?.showProfile(for : self)
    }
 
    //MARK:-functions
    private func checkIsLiked(user : CurrentUser, post : NoticesMainModel? , completion : @escaping(Bool) ->Void)
      {
      
          guard let post = post else { return }
          if post.likes.contains(user.uid){
              completion(true)
          }else{
              completion(false)
          }
      }
      
    private func checkIsDisliked(user : CurrentUser ,post : NoticesMainModel? , completion : @escaping(Bool) ->Void)
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
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
       
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: post.thumb_image))
        mentionClick()
        lessonName.text = post.clupName
        msgText.text = post.text
        like_lbl.text = post.likes.count.description
        dislike_lbl.text = post.dislike.count.description
        comment_lbl.text = post.comment.description
       
        
     
        if !post.data.isEmpty{
            filterView.arrayOfUrl = post.thumbData
            filterView.datasUrl = post.data
            filterView.collectionView.reloadData()
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yy HH:mm"
        dateFormatterPrint.timeZone = NSTimeZone(name: "UTC + 3") as TimeZone?
        let date =  Date(timeIntervalSince1970: TimeInterval(post.postTime!.seconds))
       
            print(dateFormatterPrint.string(from: date))
            timeLbl.text = dateFormatterPrint.string(from: date)
        
    }
    private func mentionClick(){
        msgText.handleMentionTap {[weak self] (username) in
            guard let sself = self else { return }
            sself.delegate?.clickMention(username: username)
                
        }
    }
}
