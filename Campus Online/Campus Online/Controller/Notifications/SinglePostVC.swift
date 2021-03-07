//
//  SinglePostVC.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 6.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MapKit

import CoreLocation
import FirebaseFirestore
private let home_post_cell = "home_post_cell"
private let home_post_data_cell = "home_post_data_cell"

private let school_post_cell = "school_post_cell"
private let school_post_data_cell = "school_post_data_cell"

private let buy_sell_post = "buy_sell_post"
private let buy_sell_post_data = "buy_sell_post_data"

private let foodme_post = "foodme_post"
private let foodme_post_data = "foodme_post_data"

private let camping_post = "camping_post"
private let camping_post_data = "camping_post_data"

class SinglePostVC: UIViewController {
   
    
    
    let indexPath = IndexPath(item: 0, section: 0)
    var lessonPost : LessonPostModel?{
        didSet{
            guard let lessonPost = lessonPost else { return }
            
            self.navigationItem.title = lessonPost.lessonName
            self.collecitonView.reloadData()
            
        }
    }
    var noticesPost : NoticesMainModel?{
        didSet{
            guard let noticesPost = noticesPost else { return }
            self.navigationItem.title = noticesPost.clupName
            self.collecitonView.reloadData()
        }
    }
    var mainPost : MainPostModel?{
        didSet{
            self.navigationItem.title = "VayeApp"
            self.collecitonView.reloadData()
        }
    }
    
    var currentUser : CurrentUser
    
    
    var actionSheetCurrentUser : ActionSheetMainPost?{
        didSet{
            collecitonView.reloadData()
        }
    }
    var actionSheetOtherUser : ASMainPostOtherUser?{
        didSet{
            collecitonView.reloadData()
        }
    }
    
    
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    
    //MARK:-lifeCycle
    init( currentUser : CurrentUser ) {
        self.currentUser = currentUser
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureUI()
        
        
    }
    
    //MARK:-functions
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0 , width: 0, heigth: 0)
        collecitonView.register(NewPostHomeVC.self, forCellWithReuseIdentifier: home_post_cell)
        collecitonView.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: home_post_data_cell)
        
        collecitonView.register(NoticesCell.self, forCellWithReuseIdentifier: school_post_cell)
        collecitonView.register(NoticesDataCell.self, forCellWithReuseIdentifier: school_post_data_cell)
        
        collecitonView.register(BuyAndSellView.self, forCellWithReuseIdentifier: buy_sell_post)
        collecitonView.register(BuyAndSellDataView.self , forCellWithReuseIdentifier: buy_sell_post_data)
        
        collecitonView.register(FoodMeView.self, forCellWithReuseIdentifier: foodme_post)
        collecitonView.register(FoodMeViewData.self , forCellWithReuseIdentifier: foodme_post_data)
        
        collecitonView.register(CampingView.self, forCellWithReuseIdentifier: camping_post)
        collecitonView.register(CampingDataView.self , forCellWithReuseIdentifier: camping_post_data)
        
        
        
    }
    
    
    
    
    
}
extension SinglePostVC : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let post = lessonPost {
            if post.data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_cell, for: indexPath) as! NewPostHomeVC
                cell.lessonPostModel  = post
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                return cell
                
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_data_cell, for: indexPath) as! NewPostHomeVCData
                cell.lessonPostModel = post
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: view.frame.width - 78, height: 200)
                cell.onClickListener = self
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                return cell
            }
        }
        else if let post = noticesPost {
            if post.data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: school_post_cell, for: indexPath) as! NoticesCell
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = post
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: school_post_data_cell, for: indexPath) as! NoticesDataCell
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                
                cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: view.frame.width - 78, height: 200)
                cell.onClickListener = self
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = post
                return cell
            }
        }
        else if let post = mainPost{
            if post.postType == PostType.buySell.despription {
                if post.data.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buy_sell_post, for: indexPath) as! BuyAndSellView
                    cell.delegate = self
                    cell.currentUser = currentUser
                    cell.backgroundColor = .white
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)

                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buy_sell_post_data, for: indexPath) as! BuyAndSellDataView
                    
                    cell.backgroundColor = .white
                    cell.delegate = self
                    cell.currentUser = currentUser
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)

                    cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: view.frame.width - 78, height: 200)
                    cell.onClickListener = self
                    
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }
            }
            else if post.postType == PostType.camping.despription{
                if post.data.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: camping_post, for: indexPath) as! CampingView
                    cell.delegate = self
                    cell.currentUser = currentUser
                    cell.backgroundColor = .white
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                   
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: camping_post_data, for: indexPath) as! CampingDataView
                    
                    cell.backgroundColor = .white
                    cell.delegate = self
                    cell.currentUser = currentUser
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    
                    cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: view.frame.width - 78, height: 200)
                    cell.onClickListener = self
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }
            }
            else{
                if post.data.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: foodme_post, for: indexPath) as! FoodMeView
                    cell.delegate = self
                    cell.currentUser = currentUser
                    cell.backgroundColor = .white
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: foodme_post_data, for: indexPath) as! FoodMeViewData
                    
                    cell.backgroundColor = .white
                    cell.delegate = self
                    cell.currentUser = currentUser
                    let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    
                    cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: view.frame.width - 78, height: 200)
                    cell.onClickListener = self
                    
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = post
                    return cell
                }
            }
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_cell, for: indexPath) as! NewPostHomeVC
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let post = lessonPost {
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            if post.data.isEmpty {
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
            }else {
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 200 + 30)
            }
            
            
        }else if let post = noticesPost {
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            if post.data.isEmpty{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30 )
            }
            else{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 200 + 30)
            }
        } else if let post = mainPost {
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            if post.postType == PostType.buySell.despription {
                if post.data.isEmpty {
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 50 + 5 )
                }else{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 200 + 50 + 5)
                }
            }else{
                if post.data.isEmpty {
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 30 + 5 )
                }else {
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 200 + 30 + 5)
                }
            }
            
        }
        
        else{
            return .zero
        }
    }
    
    
}

extension SinglePostVC : NewPostHomeVCDataDelegate {
    func showProfile(for cell: NewPostHomeVCData) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser:self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
    func options(for cell: NewPostHomeVCData) {
        //        guard let post = cell.lessonPostModel else { return }
        //        guard let currentUser = currentUser else { return }
        //        guard let actionSheet  = actionSheet else { return}
        //        guard let actionOtherUserSheet = actionOtherUserSheet else { return }
        //        if cell.lessonPostModel?.senderUid == currentUser.uid
        //        {
        //            actionSheet.delegate = self
        //            actionSheet.show(post: post)
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = lessonPost[index.row].postId
        //        }else{
        //            Utilities.waitProgress(msg: nil)
        //            actionOtherUserSheet.delegate = self
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = lessonPost[index.row].postId
        //            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
        //
        //                Utilities.dismissProgress()
        //                actionOtherUserSheet.show(post: post, otherUser: user)
        //
        //            }
        //
        //
        //        }
        
    }
    
    func like(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setLike(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
        
        
        
    }
    
    func dislike(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setDislike(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
        
    }
    
    func fav(for cell: NewPostHomeVCData) {
        
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setFav(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
        
    }
    
    func comment(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: post, noticesPost: nil, mainPost: nil)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    func goProfileByMention(userName: String) {
        
        if "@\(userName)" == currentUser.username {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
            }
        }
        
        
    }
    
    
    
}
extension SinglePostVC : NewPostHomeVCDelegate {
    func clickMention(username: String) {
        
        if "@\(username)" == currentUser.username {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let sself = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: sself.currentUser, width: 285)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: sself.currentUser, width: 235)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
    func showProfile(for cell: NewPostHomeVC) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let sself = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: sself.currentUser, width: 285)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: sself.currentUser, width: 235)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }
            }
            //            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
            }
        }
        
        
    }
    func linkClick(for cell: NewPostHomeVC) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func options(for cell: NewPostHomeVC) {
        //        guard  let post = cell.lessonPostModel else {
        //            return
        //        }
        //        guard let currentUser = currentUser else { return }
        //        guard let actionSheet = actionSheet else { return }
        //        guard let actionOtherUserSheet = actionOtherUserSheet else { return }
        //        if cell.lessonPostModel?.senderUid == currentUser.uid
        //        {
        //            actionSheet.delegate = self
        //            actionSheet.show(post: post)
        //            guard let  index = collecitonView.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = lessonPost[index.row].postId
        //        }else{
        //            Utilities.waitProgress(msg: nil)
        //            actionOtherUserSheet.delegate = self
        //            guard let  index = collecitonView.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = lessonPost[index.row].postId
        //            UserService.shared.getOtherUser(userId: post.senderUid) {(user) in
        //
        //                Utilities.dismissProgress()
        //                actionOtherUserSheet.show(post: post, otherUser: user)
        //
        //            }
        //        }
        
    }
    
    func like(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setLike(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
    }
    
    func dislike(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setDislike(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
    }
    
    func fav(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        PostService.shared.setFav(post: post, collectionView: collecitonView, currentUser: currentUser) { (_) in
            
        }
    }
    
    func comment(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: post, noticesPost: nil, mainPost: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension SinglePostVC : ShowAllDatas {
    func onClickListener(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        guard let data = post.data else { return }
        let vc = AllDatasVC(arrayListUrl: data, currentUser: currentUser)
        self.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
extension SinglePostVC : NewPostNoticesDataVCDelegate{
    func options(for cell: NoticesDataCell) {
        //        guard let currentUser = currentUser else { return }
        //        guard let post = cell.noticesPost else { return }
        //        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        //        guard let actionSheetOtherUser = actionSheetOtherUser else { return }
        //        if post.senderUid == currentUser.uid
        //        {
        //            actionSheetCurrentUser.delegate = self
        //            actionSheetCurrentUser.show(post: post)
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = mainPost[index.row].postId
        //        }
        //        else{
        //            Utilities.waitProgress(msg: nil)
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = mainPost[index.row].postId
        //            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
        //
        //                Utilities.dismissProgress()
        //               actionSheetOtherUser.show(post: post, otherUser: user)
        //
        //            }
        //        }
    }
    
    func like(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        
        
        NoticesService.shared.setPostLike( collectionview: collecitonView, currentUser: currentUser, post: post) { (_) in
            print("liked")
            
        }
    }
    
    func dislike(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        
        
        NoticesService.shared.setDislike( collectionview: collecitonView, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        
        
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: post, mainPost: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesDataCell) {
        guard  let post = cell.noticesPost else {
            return
        }
        
        
        if post.senderUid == currentUser.uid{
            
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
}

extension SinglePostVC : NewPostNoticesVCDelegate{
    func options(for cell: NoticesCell) {
        //        guard let post = cell.noticesPost else { return }
        //        guard let currentUser = currentUser else { return }
        //        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        //        guard let actionSheetOtherUser = actionSheetOtherUser else { return }
        //        if post.senderUid == currentUser.uid
        //        {
        //            actionSheetCurrentUser.delegate = self
        //            actionSheetCurrentUser.show(post: post)
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = mainPost[index.row].postId
        //        }
        //        else{
        //            Utilities.waitProgress(msg: nil)
        //            guard let  index = collectionview.indexPath(for: cell) else { return }
        //            selectedIndex = index
        //            selectedPostID = mainPost[index.row].postId
        //            UserService.shared.getOtherUser(userId: post.senderUid) {(user) in
        //
        //                Utilities.dismissProgress()
        //             actionSheetOtherUser.show(post: post, otherUser: user)
        //
        //            }
        //        }
    }
    
    func like(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        NoticesService.shared.setPostLike( collectionview: collecitonView, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        
        
        NoticesService.shared.setDislike( collectionview: collecitonView, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: post, mainPost: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesCell) {
        guard  let post = cell.noticesPost else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
    
}
extension SinglePostVC : ShowNoticesAllDatas {
    func onClickListener(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }

        guard let data = post.data else { return }
        let vc = AllDatasVC(arrayListUrl: data, currentUser: currentUser)
        self.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
}

extension SinglePostVC : FoodMeVCDelegate {
    func options(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }

        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
      
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
           
        }
        
    }
    
    func like(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.food_me.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.food_me.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func comment(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: FoodMeView) {
        guard let url = URL(string: (cell.mainPost?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for cell: FoodMeView) {
        guard  let post = cell.mainPost else {
            return
        }
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser:  self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
    
    func mapClick(for cell: FoodMeView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    

}
extension SinglePostVC : FoodMeVCDataDelegate {
    func options(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }

        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
         
        }
       
    }
    
    func like(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
       
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.food_me.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }

        MainPostService.shared.setDislike(target: MainPostLikeTarget.food_me.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func comment(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }

        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: FoodMeViewData) {
        guard let url = URL(string: (cell.mainPost?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func mapClick(for cell: FoodMeViewData) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func showProfile(for cell: FoodMeViewData) {
        guard  let post = cell.mainPost else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                            
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
}
extension SinglePostVC : ASMainPostLaungerDelgate{
    func didSelect(option: ASCurrentUserMainPostOptions) {
        
        switch option{
        case .editPost(_):
            if let post = mainPost{
               
                if post.postType == PostType.foodMe.despription {
                    if let h = collecitonView.cellForItem(at: indexPath) as? FoodMeViewData {
                        let vc = EditFoodMePost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }else if let h = collecitonView.cellForItem(at: indexPath) as? FoodMeView{
                        let vc = EditFoodMePost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }
                }else if post.postType == PostType.buySell.despription{
                    if let h = collecitonView.cellForItem(at: indexPath) as? BuyAndSellView {
                        let vc = EditSellBuyPost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }else if let h = collecitonView.cellForItem(at: indexPath) as? BuyAndSellDataView{
                        let vc = EditSellBuyPost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }
                }else if post.postType == PostType.camping.despription{
                    if let h = collecitonView.cellForItem(at: indexPath) as? CampingView {
                        let vc = EditCampingPost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }else if let h = collecitonView.cellForItem(at: indexPath) as? CampingDataView{
                        let vc = EditCampingPost(currentUser: self.currentUser, post: post, h: h.msgText.frame.height)
                        let controller = UINavigationController(rootViewController: vc)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
            
            break
        case .deletePost(_):
            if let post = mainPost {
                Utilities.waitProgress(msg: nil)
                if post.postType == PostType.buySell.despription || post.postType == PostType.camping.despription || post.postType == PostType.foodMe.despription{
                    let db = Firestore.firestore().collection("main-post")
                        .document("post")
                        .collection("post")
                        .document(post.postId)
                    db.delete { (err) in
                        if err == nil {
                            MainPostService.shared.deleteToStorage(data: post.data, postId: post.postId) { (_val) in
                                if _val{
                                    Utilities.succesProgress(msg: "Silindi")
                                }
                            }
                        }else{
                            Utilities.errorProgress(msg: "Hata Oluştu")
                        }
                    }
                }
            }
            break
        case .slientPost(_):
            break
        }
    }
    
    
}
extension SinglePostVC : ShowAllFoodMeData{
    func onClickListener(for cell: FoodMeViewData) {
        
    }
}
extension SinglePostVC : CampingVCDataDelegate {
    
    
    func options(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }

        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
   
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
          
        }
    }
    
    func like(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }

        MainPostService.shared.setLikePost(target: MainPostLikeTarget.camping.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
 
        MainPostService.shared.setDislike(target: MainPostLikeTarget.camping.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: CampingDataView) {
        
    }
    
    func mapClick(for cell: CampingDataView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func showProfile(for cell: CampingDataView) {
        guard  let post = cell.mainPost else {
            return
        }
      
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
}
extension SinglePostVC : CampingVCDelegate {
    func options(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
       
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
        
        }
    }
    
    func like(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
      
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.camping.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        
        MainPostService.shared.setDislike(target: MainPostLikeTarget.camping.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
 
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
       navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: CampingView) {
        
    }
    
    func showProfile(for cell: CampingView) {
        guard  let post = cell.mainPost else {
            return
        }
       
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
    
    func mapClick(for cell: CampingView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}
extension SinglePostVC : ShowAllCampingData {
    func onClickListener(for cell: CampingDataView) {
        
    }
}
extension SinglePostVC : BuySellVCDelegate {
    func options(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        guard let actionSheetOtherUser = actionSheetOtherUser  else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
         
        }
      
    }
    func mapClick(for cell: BuyAndSellView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    func like(for cell: BuyAndSellView)
    {
        guard let post = cell.mainPost else { return }
   
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    
    
    func comment(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellView) {
     
    }
    
    func showProfile(for cell: BuyAndSellView) {
        guard  let post = cell.mainPost else {
            return
        }
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
               
                
                
            }
        }
    }
    
   
    
}
extension SinglePostVC : BuySellVCDataDelegate {
    func mapClick(for cell: BuyAndSellDataView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    func options(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }

        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
           
        }
        
    }
    
    func like(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collecitonView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    func comment(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellDataView) {
        guard let url = URL(string: (cell.mainPost?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for cell: BuyAndSellDataView) {
        guard  let post = cell.mainPost else {
            return
        }

        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser:self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
                
            }
        }
    }
    
}
extension SinglePostVC : ShowBuySellData {
    func onClickListener(for cell: BuyAndSellDataView) {
        
    }
    
    
}
