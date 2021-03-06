//
//  SinglePostVC.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 6.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

import FirebaseFirestore
private let home_post_cell = "home_post_cell"
private let home_post_data_cell = "home_post_data_cell"
class SinglePostVC: UIViewController {
   
    
     var lessonPost : LessonPostModel?{
        didSet{
            guard let lessonPost = lessonPost else { return }
            
            self.navigationItem.title = lessonPost.lessonName
            self.collecitonView.reloadData()
            
        }
    }
     var noticesPost : NoticesMainModel?
     var mainPost : MainPostModel?
    
    var currentUser : CurrentUser
    
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
        }else{
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
            
           
        }else{
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
        
    }
    
    
}
