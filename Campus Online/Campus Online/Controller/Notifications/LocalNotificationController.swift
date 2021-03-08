//
//  LocalNotificationController.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 6.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let cellId = "cell_id"
private let loadMoreCell = "loadMoreCell"
import FirebaseFirestore
import SwipeCellKit
class LocalNotificationController: UIViewController  {
    var currentUser : CurrentUser
    var model = [NotificationModel]()
    var loadMore : Bool = false
    var page : DocumentSnapshot? = nil
    weak var notificaitonListener : ListenerRegistration?
    private lazy var notificationLauncher = NotificationLaunher(currentUser: currentUser, target: NotifictionTarget.notification.descriptions)
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return control
    }()
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.refreshControl = refreshControl
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Bildirimler"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showLauncher))
        configureUI()
        
    }
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificaitonListener?.remove()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificaitonListener?.remove()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotificationCount()
    }
    //MARK:-functions
    private func getNotificationCount(){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601502870421
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("notification").whereField("isRead", isEqualTo: false)
        notificaitonListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                guard let sself = self else {
                    self?.tabBarController?.tabBar.items?[2].badgeValue = nil
                    return
                }
                if snap.isEmpty {
                    sself.tabBarController?.tabBar.items?[2].badgeValue = nil
                }else{
                    sself.tabBarController?.tabBar.items?[2].badgeValue = snap.documents.count.description
                }
            }
        })
    }
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0 , width: 0, heigth: 0)
        collecitonView.register(NotificationCell.self, forCellWithReuseIdentifier: cellId)
        collecitonView.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        getAllPost()
    }
    
    private func getAllPost(){
        model = [NotificationModel]()
        loadMore = true
        collecitonView.refreshControl?.beginRefreshing()
        collecitonView.reloadData()
        ///user/t01RVvdauThanTbmpmmsLMgiJGx1/notification/
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("notification")
            .limit(to: 10).order(by: "not_id" , descending: true)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else {
                    sself.collecitonView.refreshControl?.endRefreshing()
                    sself.loadMore = false
                    return
                    
                }
                if snap.isEmpty {
                    sself.collecitonView.refreshControl?.endRefreshing()
                    sself.loadMore = false
                    return
                }else{
                    for item in snap.documents{
                        if item.exists {
                            sself.model.append(NotificationModel.init(not_id: item.documentID, dic: item.data()))
                        }else{
                            sself.loadMore = false
                        }
                    }
                    sself.page = snap.documents.last
                    sself.loadMore = false
                    sself.collecitonView.reloadData()
                    sself.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    private func loadMorePost(){
        guard let page = page else {
            loadMore = false
            collecitonView.reloadData()
            return }
        loadMore = true
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("notification")
            .limit(to: 5).order(by: "not_id" , descending: true).start(atDocument: page)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty{
                    sself.loadMore = false
                    sself.collecitonView.reloadData()
                }else{
                    for item in snap.documents{
                        sself.model.append(NotificationModel.init(not_id: item.documentID, dic: item.data()))
                    }
                    sself.collecitonView.reloadData()
                    sself.loadMore = true
                    sself.page = snap.documents.last
                }
            }
        }
        
    }
    
    
    private func makeReadNotification(not_id : String , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").document(not_id)
        db.setData(["isRead":true], merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    private func setNotificationRead(completion : @escaping(Bool)->Void){
        Utilities.succesProgress(msg: nil)
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601502870421
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").whereField("isRead", isEqualTo: false)
        db.getDocuments {[weak self] (querySnap, err) in
            if err == nil{
                guard let snap = querySnap else { return }
                guard let sself = self else { return }
                if !snap.isEmpty{
                    for item in snap.documents{
                        sself.makeReadNotification(not_id: item.documentID) { (_) in
                            completion(true)
                        }
                    }
                }else{
                    completion(true)
                }
                
            }
        }
    }
    private func getAllNotificationForDelete(completion : @escaping(Bool) ->Void){
        Utilities.succesProgress(msg: nil)
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601502870421
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification")
        db.getDocuments {[weak self] (querySnap, err) in
            if err == nil{
                guard let snap = querySnap else { return }
                guard let sself = self else { return }
                if !snap.isEmpty{
                    for item in snap.documents{
                        sself.deleteNotification(not_id: item.documentID) { (_) in
                            completion(true)
                        }
                    }
                }else{
                    completion(true)
                }
                
            }
        }
    }
    private func deleteNotification(not_id : String ,completion : @escaping(Bool) -> Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").document(not_id)
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil{
                Utilities.dismissProgress()
                if let index = sself.model.firstIndex(where: {$0.not_id == not_id}) {
                    sself.model.remove(at: index)
                    sself.collecitonView.reloadData()
                }
                
                completion(true)
            }
        }
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
                text = MajorPostNotification.new_replied_mentioned_comment.type
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
                text = NoticesPostNotification.new_replied_mentioned_comment.type
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
    

    
    
    //MARK:-notificaiton deep linking
    
    
    private func showPost(model : NotificationModel){
        
        if model.postType == NotificationPostType.lessonPost.name {
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(model.postId)
            db.getDocument {[weak self] (docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap = docSnap else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let post = LessonPostModel.init(postId: snap.documentID, dic: snap.data())
                        
                        let vc = SinglePostVC(currentUser: sself.currentUser)
                        vc.lessonPost = post
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        }else if model.postType == NotificationPostType.notices.name{
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("notices")
                .collection("post")
                .document(model.postId)
            db.getDocument {[weak self] (docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap = docSnap else {
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                        
                    }
                    if snap.exists {
                        let post = NoticesMainModel.init(postId: snap.documentID, dic: snap.data())
                        let vc = SinglePostVC(currentUser: sself.currentUser)
                        vc.noticesPost = post
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        
                    }
                    
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        }else if model.postType == NotificationPostType.mainPost.name{
            let db = Firestore.firestore().collection("main-post")
                .document("post").collection("post")
                .document(model.postId)
            db.getDocument {[weak self] (docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap  = docSnap else {
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return }
                    if snap.exists {
                        let post = MainPostModel.init(postId: snap.documentID, dic: snap.data())
                        let vc = SinglePostVC(currentUser: sself.currentUser)
                        vc.mainPost = post
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                    }
                    
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
            
        }
        
    }
    
   
    private func showRepliedComment(model : NotificationModel){
        if model.postType == NotificationPostType.mainPost.name {
            guard let targetComment = model.targetCommentId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return }
            guard let postID = model.postId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return
            }
            
            let db = Firestore.firestore().collection("main-post")
                .document("post")
                .collection("post")
                .document(model.postId)
            db.getDocument { (docSnap,err) in
                if err == nil {
                    guard let snap = docSnap else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let mainPost = MainPostModel.init(postId: snap.documentID, dic: snap.data())
                        let commentData = Firestore.firestore().collection("comment")
                            .document(postID)
                            .collection("comment")
                            .document(targetComment)
                        commentData.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let commentSnap = docSnap else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                                if commentSnap.exists {
                                    let commentModel = CommentModel.init(ID: commentSnap.documentID, dic: commentSnap.data()!)
                                    let vc = RepliyCommentVC(targetCommentModel: commentModel, currentUser: self.currentUser, postId: postID, commentId: targetComment, lessonPost: nil, noticesPost: nil, mainPost: mainPost)
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    Utilities.dismissProgress()
                                }else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                            }else{
                                Utilities.dismissProgress()
                                Utilities.errorProgress(msg: "Hata Oluştu")
                                return
                            }
                        }
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                    return
                }
            }
            
        
        }else if model.postType == NotificationPostType.lessonPost.name{
            guard let targetComment = model.targetCommentId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return }
            guard let postID = model.postId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return
            }
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(model.postId)
            db.getDocument { (docSnap,err) in
                if err == nil {
                    guard let snap = docSnap else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let lessonPost = LessonPostModel.init(postId: snap.documentID, dic: snap.data())
                        let commentData = Firestore.firestore().collection("comment")
                            .document(postID)
                            .collection("comment")
                            .document(targetComment)
                        commentData.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let commentSnap = docSnap else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                                if commentSnap.exists {
                                    let commentModel = CommentModel.init(ID: commentSnap.documentID, dic: commentSnap.data()!)
                                    let vc = RepliyCommentVC(targetCommentModel: commentModel, currentUser: self.currentUser, postId: postID, commentId: targetComment, lessonPost: lessonPost, noticesPost: nil, mainPost: nil)
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    Utilities.dismissProgress()
                                }else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                            }else{
                                Utilities.dismissProgress()
                                Utilities.errorProgress(msg: "Hata Oluştu")
                                return
                            }
                        }
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                    return
                }
            }
            
            
        }else if model.postType == NotificationPostType.notices.name{
            guard let targetComment = model.targetCommentId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return }
            guard let postID = model.postId else {
                Utilities.dismissProgress()
                Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                return
            }
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("notices")
                .collection("post")
                .document(model.postId)
            db.getDocument { (docSnap,err) in
                if err == nil {
                    guard let snap = docSnap else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let noticesPost = NoticesMainModel.init(postId: snap.documentID, dic: snap.data())
                        ///comment/1611176191370/comment/1615023519925
                        let commentData = Firestore.firestore().collection("comment")
                            .document(postID)
                            .collection("comment")
                            .document(targetComment)
                        
                        commentData.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let commentSnap = docSnap else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                                if commentSnap.exists {
                                    let commentModel = CommentModel.init(ID: commentSnap.documentID, dic: commentSnap.data()!)
                                    let vc = RepliyCommentVC(targetCommentModel: commentModel, currentUser: self.currentUser, postId: postID, commentId: targetComment, lessonPost: nil, noticesPost: noticesPost, mainPost: nil)
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    Utilities.dismissProgress()
                                }else{
                                    Utilities.dismissProgress()
                                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                                    return
                                }
                            }else{
                                Utilities.dismissProgress()
                                Utilities.errorProgress(msg: "Hata Oluştu")
                                return
                            }
                        }
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                    return
                }
            }
            
        }
    }
    
    private func showComment(model : NotificationModel){
        
        if model.postType == NotificationPostType.notices.name {
            
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("notices")
                .collection("post")
                .document(model.postId)
            db.getDocument { [weak self](docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap = docSnap else {
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return }
                    if snap.exists {
                        let vc = MajorPostCommentController(currentUser: sself.currentUser, postId: model.postId, lessonPost: nil, noticesPost: NoticesMainModel.init(postId: snap.documentID, dic: snap.data()), mainPost: nil)
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                        
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        }else if model.postType == NotificationPostType.lessonPost.name  {
            
            
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(model.postId)
            db.getDocument {[weak self] (docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap = docSnap else {
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let vc = MajorPostCommentController(currentUser: sself.currentUser, postId: model.postId, lessonPost: LessonPostModel.init(postId: snap.documentID, dic: snap.data()), noticesPost: nil, mainPost: nil)
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        }
        else if model.postType == NotificationPostType.mainPost.name
        {
            
            let db = Firestore.firestore().collection("main-post")
                .document("post").collection("post")
                .document(model.postId)
            db.getDocument {[weak self] (docSnap, err) in
                guard let sself = self else { return }
                if err == nil {
                    guard let snap = docSnap else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return
                    }
                    if snap.exists {
                        let vc = MajorPostCommentController(currentUser: sself.currentUser, postId: model.postId, lessonPost: nil, noticesPost: nil, mainPost: MainPostModel.init(postId: snap.documentID, dic: snap.data()))
                        sself.navigationController?.pushViewController(vc, animated: true)
                        Utilities.dismissProgress()
                    }else{
                        Utilities.dismissProgress()
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                    }
                }else{
                    Utilities.dismissProgress()
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        }else{
            Utilities.dismissProgress()
            return
        }
    }
    
    private func showProfile(model : NotificationModel){
        UserService.shared.fetchOtherUser(uid: model.senderUid) {[weak self](user) in
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
    //MARK:-objc
    @objc func showLauncher(){
        notificationLauncher.show()
        notificationLauncher.delegate = self
    }
    @objc func loadData(){
        getAllPost()
    }
    
    
   
    
    
}
extension LocalNotificationController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationCell
        cell.currentUser = currentUser
        cell.model = model[indexPath.row]
        cell.actionDelegate = self
        cell.delegate = self
        let text =  model[indexPath.row].senderName + model[indexPath.row].username +
            model[indexPath.row].time.dateValue().timeAgoDisplay() + getMainText(model: model[indexPath.row]) + "\n" + model[indexPath.row].text
        let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
        cell.mainText.frame = CGRect(x: 44, y: 6, width: view.frame.width - 50, height: h + 5)
        if model[indexPath.row].isRead {
            cell.contentView.backgroundColor = .white
        }else{
            cell.contentView.backgroundColor = .notificationNotRead()
        }

        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let text = model[indexPath.row].senderName + model[indexPath.row].username +
            model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text +  getMainText(model: model[indexPath.row])
        let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
        
        if h > 41 {
            return CGSize(width: view.frame.width, height: 12 + h + 15)
        }else{
            return CGSize(width: view.frame.width, height: 50)
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if model.count > 10 {
            if  indexPath.item == model.count - 1 {
                loadMorePost()
            }else{
                self.loadMore = false
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadMoreCell, for: indexPath)
            as! LoadMoreCell
        cell.activityView.startAnimating()
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if loadMore{
            return CGSize(width: view.frame.width, height: 50)
        }else{
            return .zero
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Utilities.waitProgress(msg: nil)
        
       
        if model[indexPath.row].postType == NotificationPostType.lessonPost.name {
            if model[indexPath.row].type == MajorPostNotification.comment_like.type ||
                model[indexPath.row].type == MajorPostNotification.new_comment.type ||
                model[indexPath.row].type == MajorPostNotification.new_mentioned_comment.type
            {
                showComment(model : model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }else if model[indexPath.row].type == MajorPostNotification.new_post.type ||
                        model[indexPath.row].type == MajorPostNotification.new_mentioned_post.type ||
                        model[indexPath.row].type  == MajorPostNotification.post_like.type  {
                showPost(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
                
            }else if model[indexPath.row].type == MajorPostNotification.new_replied_comment.type ||
                        model[indexPath.row].type == MajorPostNotification.new_replied_mentioned_comment.type{
                showRepliedComment(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }
            
        }else if model[indexPath.row].postType == NotificationPostType.notices.name{
            if model[indexPath.row].type == NoticesPostNotification.comment_like.type ||
                model[indexPath.row].type == NoticesPostNotification.new_comment.type ||
                model[indexPath.row].type == NoticesPostNotification.new_mentioned_comment.type
            {
                showComment(model : model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }else if model[indexPath.row].type == NoticesPostNotification.new_post.type ||
                        model[indexPath.row].type == NoticesPostNotification.new_mentioned_post.type ||
                        model[indexPath.row].type  == NoticesPostNotification.post_like.type  {
                showPost(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
                
            }else if model[indexPath.row].type == NoticesPostNotification.new_replied_comment.type ||
                        model[indexPath.row].type == NoticesPostNotification.new_replied_mentioned_comment.type{
                showRepliedComment(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }
        }else if model[indexPath.row].postType == NotificationPostType.mainPost.name{
            if model[indexPath.row].type == MainPostNotification.comment_like.type ||
                model[indexPath.row].type == MainPostNotification.new_comment.type ||
                model[indexPath.row].type == MainPostNotification.new_mentioned_comment.type
            {
                showComment(model : model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }else if model[indexPath.row].type == MainPostNotification.new_post.type ||
                        model[indexPath.row].type == MainPostNotification.new_mentioned_post.type ||
                        model[indexPath.row].type  == MainPostNotification.post_like.type  {
                showPost(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
                
            }else if model[indexPath.row].type == MainPostNotification.new_replied_comment.type ||
                        model[indexPath.row].type == MainPostNotification.new_replied_mentioned_comment.type{
                showRepliedComment(model: model[indexPath.row])
                makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.model[indexPath.row].isRead = true
                    sself.collecitonView.reloadData()
                }
            }
        }
        else if model[indexPath.row].postType == NotificationPostType.follow.name{
            showProfile(model: model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }
        }
        else{
            Utilities.dismissProgress()
            return
        }
        
        
        
        

    }
    
}


extension LocalNotificationController : NotificationLauncherDelegate {
    func didSelect(option: NotificationOptions) {
        switch option {
        
        case .makeAllRead(_):
            setNotificationRead {[weak self] (_) in
                guard let sself = self else { return }
                for item in sself.model{
                    item.isRead = true
                }
                sself.collecitonView.reloadData()
                Utilities.dismissProgress()
            }
            break
        case .deleteAll(_):
            getAllNotificationForDelete {[weak self] (_) in
                guard let sself = self else { return }
                sself.model = [NotificationModel]()
                sself.collecitonView.reloadData()
                Utilities.dismissProgress()
            }
            break
        }
    }
    
    
}
extension LocalNotificationController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Sil") {[weak self] (action, indexPat) in
                guard let sself = self else { return }
                Utilities.waitProgress(msg: nil)
                sself.deleteNotification(not_id: sself.model[indexPath.row].not_id) { (_val) in
                    if _val{
                        sself.collecitonView.reloadData()
                        Utilities.dismissProgress()
                    }
                }
                
            }
            
            deleteAction.image = #imageLiteral(resourceName: "remove").withRenderingMode(.alwaysOriginal)
            deleteAction.font = UIFont(name: Utilities.font, size: 11)
            return [deleteAction]
        }else {
            let read = SwipeAction(style: .destructive, title: "Görüntüle") {[weak self] (action, indexPath) in
                guard let sself = self else { return }
                Utilities.waitProgress(msg: nil)
               
            }
            read.image = #imageLiteral(resourceName: "seen").withRenderingMode(.alwaysOriginal)
            read.hidesWhenSelected = true
            read.accessibilityLabel = "Görüntüle"
            read.backgroundColor = .mainColor()
            read.font = UIFont(name: Utilities.font, size: 11)
            
            return [read]
        }
        
    }
    
}

extension LocalNotificationController : NotificationActionDelegate {
    func imageClick(for cell : NotificationCell){
        guard let post = cell.model else { return }
        Utilities.waitProgress(msg: nil)
        UserService.shared.fetchOtherUser(uid: post.senderUid) {[weak self] (user) in
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
