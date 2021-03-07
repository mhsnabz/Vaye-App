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
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    sself.collecitonView.refreshControl?.endRefreshing()
                    sself.loadMore = false
                    return
                }else{
                    for item in snap.documents{
                        if item.exists {
                            sself.model.append(NotificationModel.init(not_id: item.documentID, dic: item.data()))
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
    
    func getNotificationType (type : String) ->String {
        if type == NotificationType.home_like.desprition {
            return NotificationType.home_like.desprition
        }
        else if type == NotificationType.comment_home.desprition {
            return NotificationType.comment_home.desprition
        }
        else if type == NotificationType.reply_comment.desprition {
            return NotificationType.reply_comment.desprition
        }
        else if type == NotificationType.comment_like.desprition {
            return NotificationType.comment_like.desprition
        }
        else if type == NotificationType.comment_mention.desprition {
            return NotificationType.comment_mention.desprition
        }
        else if type == NotificationType.following_you.desprition {
            return NotificationType.following_you.desprition
        }
        else if type == NotificationType.home_new_post.desprition {
            return NotificationType.home_new_post.desprition
        }
        else if type == NotificationType.home_new_mentions_post.desprition {
            return NotificationType.home_new_mentions_post.desprition
        }
        else if type == NotificationType.new_ad.desprition {
            return NotificationType.new_ad.desprition
        }
        else if type == NotificationType.like_sell_buy.desprition {
            return NotificationType.like_sell_buy.desprition
        }
        else if type == NotificationType.new_food_me.desprition {
            return NotificationType.new_food_me.desprition
        }
        else if type == NotificationType.like_food_me.desprition {
            return NotificationType.like_food_me.desprition
        }
        else if type == NotificationType.new_camping.desprition {
            return NotificationType.new_camping.desprition
        }
        else if type == NotificationType.like_camping.desprition {
            return NotificationType.like_camping.desprition
        }
        else if type == NotificationType.notices_comment_like.desprition {
            return NotificationType.notices_comment_like.desprition
        }
        
        else if type == NotificationType.notices_replied_comment_like.desprition{
            return NotificationType.notices_replied_comment_like.desprition
        }
        
        else if type == NotificationType.notices_post_like.desprition {
            return NotificationType.notices_post_like.desprition
        }
        
        else if type == NotificationType.notices_new_comment.desprition {
            return NotificationType.notices_new_comment.desprition
        }
        
        else if type == NotificationType.notice_mention_comment.desprition {
            return NotificationType.notice_mention_comment.desprition
        }
        
        else if type == NotificationType.notices_new_post.desprition {
            return NotificationType.notices_new_post.desprition
        }
        
        
        return ""
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
        }else if model.postType == PostType.buySell.despription || model.postType == PostType.camping.despription ||  model.postType == PostType.foodMe.despription {
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
        }else if model.postType == NotificationPostType.lessonPost.name {
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
        else
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
        if   getTypeDescribing(type: model[indexPath.row].type) == Notification_description.comment_home.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == NotificationType.comment_mention.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == Notification_description.notice_mention_comment.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == Notification_description.reply_comment.desprition{
            
            let text =  model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + getTypeDescribing(type: model[indexPath.row].type) + "\n" + model[indexPath.row].text
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            cell.mainText.frame = CGRect(x: 44, y: 6, width: view.frame.width - 50, height: h + 5)
            
        }else{
            let text =  model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            cell.mainText.frame = CGRect(x: 44, y: 6, width: view.frame.width - 50, height: h + 5)
        }
        if model[indexPath.row].isRead {
            cell.contentView.backgroundColor = .white
        }else{
            cell.contentView.backgroundColor = .notificationNotRead()
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if   getTypeDescribing(type: model[indexPath.row].type) == Notification_description.comment_home.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == NotificationType.comment_mention.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == Notification_description.notice_mention_comment.desprition ||
                getTypeDescribing(type: model[indexPath.row].type) == Notification_description.reply_comment.desprition || getTypeDescribing(type: model[indexPath.row].type) == Notification_description.comment_mention_reply.desprition {
            
            let text = model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text +  getTypeDescribing(type: model[indexPath.row].type)
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            
            if h > 41 {
                return CGSize(width: view.frame.width, height: 12 + h + 15)
            }else{
                return CGSize(width: view.frame.width, height: 50)
            }
        }else{
            let text =  model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            if h > 41 {
                return CGSize(width: view.frame.width, height: 12 + h + 15)
            }else{
                return CGSize(width: view.frame.width, height: 50)
            }
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
        if getNotificationType(type: model[indexPath.row].type) == NotificationType.comment_home.desprition ||
            getNotificationType(type: model[indexPath.row].type) == NotificationType.comment_mention.desprition {
            showComment(model : model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }
            
        }else if model[indexPath.row].postType == NotificationPostType.lessonPost.name{
            showPost(model: model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }
        }else if model[indexPath.row].postType == NotificationPostType.notices.name{
            showPost(model: model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }
        }else if model[indexPath.row].postType == PostType.buySell.despription ||
                    model[indexPath.row].postType == PostType.camping.despription ||
                    model[indexPath.row].postType == PostType.foodMe.despription{
            showPost(model: model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }
        }else if model[indexPath.row].postType == NotificationPostType.follow.name {
            showProfile(model: model[indexPath.row])
            makeReadNotification(not_id: model[indexPath.row].not_id) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.model[indexPath.row].isRead = true
                sself.collecitonView.reloadData()
            }

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
                if sself.getNotificationType(type: sself.model[indexPath.row].type) == NotificationType.comment_home.desprition ||
                    sself.getNotificationType(type: sself.model[indexPath.row].type) == NotificationType.comment_mention.desprition {
                    sself.showComment(model : sself.model[indexPath.row])
                    sself.makeReadNotification(not_id: sself.model[indexPath.row].not_id) {(_val) in
                        
                        sself.model[indexPath.row].isRead = true
                        sself.collecitonView.reloadData()
                    }
                    
                }else if sself.model[indexPath.row].postType == NotificationPostType.lessonPost.name{
                    sself.showPost(model: sself.model[indexPath.row])
                    sself.makeReadNotification(not_id: sself.model[indexPath.row].not_id) {(_val) in
                        
                        sself.model[indexPath.row].isRead = true
                        sself.collecitonView.reloadData()
                    }
                }else if sself.model[indexPath.row].postType == NotificationPostType.notices.name{
                    sself.showPost(model: sself.model[indexPath.row])
                    sself.makeReadNotification(not_id: sself.model[indexPath.row].not_id) { (_val) in
                  
                        sself.model[indexPath.row].isRead = true
                        sself.collecitonView.reloadData()
                    }
                }else if sself.model[indexPath.row].postType == PostType.buySell.despription ||
                            sself.model[indexPath.row].postType == PostType.camping.despription ||
                            sself.model[indexPath.row].postType == PostType.foodMe.despription{
                    sself.showPost(model: sself.model[indexPath.row])
                    sself.makeReadNotification(not_id: sself.model[indexPath.row].not_id) { (_val) in
                      
                        sself.model[indexPath.row].isRead = true
                        sself.collecitonView.reloadData()
                    }
                }else if sself.model[indexPath.row].postType == NotificationPostType.follow.name {
                    sself.showProfile(model: sself.model[indexPath.row])
                    sself.makeReadNotification(not_id: sself.model[indexPath.row].not_id) {[weak self] (_val) in
                        guard let sself = self else { return }
                        sself.model[indexPath.row].isRead = true
                        sself.collecitonView.reloadData()
                    }

                }
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
