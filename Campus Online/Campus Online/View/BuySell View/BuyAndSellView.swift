//
//  BuyAndSellView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 18.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
import ActiveLabel
import FirebaseFirestore
class BuyAndSellView: UICollectionViewCell {
    //MARK: - variables
    weak var delegate : BuySellVCDelegate?
    
    var currentUser : CurrentUser?
    weak var mainPost : MainPostModel?{
        didSet{
            configure()
            guard let currentUser = currentUser else { return }
            checkIsDisliked(user: currentUser, post: mainPost) {[weak self] (_val) in
                guard let s = self else { return }
                if _val {
                    s.dislike.setImage(#imageLiteral(resourceName: "dislike-selected").withRenderingMode(.alwaysOriginal), for: .normal)
                }else{
                    s.dislike.setImage(#imageLiteral(resourceName: "dislike-unselected").withRenderingMode(.alwaysOriginal), for: .normal)
                    
                }
            }
            checkIsLiked(user: currentUser, post: mainPost) {[weak self] (_val) in
                   guard let s = self else { return }
                if _val{
                    s.like.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }else{
                    s.like.setImage(UIImage(named: "like-unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
        }
        
    }
    
    
    //MARK: -properties
    
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
    
    let linkBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(#imageLiteral(resourceName: "location-orange").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return btn
    }()
    let priceLbl : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    var price : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    
    
    //MARK: -lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerView)
        headerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 60)
//        configure()
        addSubview(msgText)
        addSubview(priceLbl)
        priceLbl.text = "fiyat : 20 tl"
        addSubview(bottomBar)
        addSubview(linkBtn)
        linkBtn.anchor(top: headerView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 28, marginBottom: 10, marginRigth: 0, width: 25, heigth: 25)
        
        
        linkBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        linkBtn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        linkBtn.layer.shadowOpacity = 1.0
        linkBtn.layer.shadowRadius = 3.0
        linkBtn.layer.masksToBounds = false
        
        comment.addTarget(self, action: #selector(commentClick), for: .touchUpInside)
        like.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        dislike.addTarget(self, action: #selector(dislikeClick), for: .touchUpInside)

        optionsButton.addTarget(self, action: #selector(optionsClick), for: .touchUpInside)
        linkBtn.isHidden = false
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        profileImage.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-selectors
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
    @objc func showProfile(){
        print("click")
        delegate?.showProfile(for : self)
    }
    //MARK: -functions
    private func checkIsFav(user : CurrentUser , post : MainPostModel? , completion : @escaping(Bool) ->Void)
    {
        guard let post = post else { return }
        if post.favori.contains(user.uid){
            completion(true)
        }else{
            completion(false)
        }
    }
    
    private func checkIsLiked(user : CurrentUser, post : MainPostModel? , completion : @escaping(Bool) ->Void)
      {
      
          guard let post = post else { return }
          if post.likes.contains(user.uid){
              completion(true)
          }else{
              completion(false)
          }
      }
      
    private func checkIsDisliked(user : CurrentUser ,post : MainPostModel? , completion : @escaping(Bool) ->Void)
    {
             guard let post = post else { return }
             if post.dislike.contains(user.uid){
                 completion(true)
             }else{
                 completion(false)
             }
         }
    private func configure(){
        guard let post = mainPost else { return }
        
        name = NSMutableAttributedString(string: "\(post.senderName!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(post.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        name.append(NSAttributedString(string: " \(post.postTime!.dateValue().timeAgoDisplay())", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: post.thumb_image))
        mentionClick()
        lessonName.text = post.lessonName
        msgText.text = post.text
        like_lbl.text = post.likes.count.description
        dislike_lbl.text = post.dislike.count.description
        comment_lbl.text = post.comment.description
        linkBtn.addTarget(self, action: #selector(linkClick), for: .touchUpInside)
        price = NSMutableAttributedString(string: "Fiyat : ", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        if post.value.isEmpty {
            price.append(NSAttributedString(string: " Fiyat Belirtilmemiş", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.red ]))
        }else{
            price.append(NSAttributedString(string: " \(post.value.description)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.red ]))
        }
       
        priceLbl.attributedText = price
//        if post.link.isEmpty {
//            linkBtn.isHidden = true
//            
//        }else{
//            linkBtn.isHidden = false
////            detectLink(post.link)
//        }
    }
    private func mentionClick(){
        msgText.handleMentionTap {[weak self] (username) in
            guard let sself = self else { return }
            sself.delegate?.goProfileByMention(userName : username)
        }
    }
}
