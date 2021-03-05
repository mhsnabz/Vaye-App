//
//  NotificationVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellId = "NotificaitionCell"
private let footerId = "footerID"
class NotificationVC: UIViewController {
    var currentUser : CurrentUser
    var model = [NotificationModel]()
    var isLoadMore : Bool = false
    weak var listener : ListenerRegistration?
    weak var notificaitonListener : ListenerRegistration?
    var page : DocumentSnapshot? = nil
    private var notificationLauncher : NotificationLaunher
    var refreshControl = UIRefreshControl()
    //MARK: -properties
    var tableView : UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    //MARK: - lifeCycle
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        notificationLauncher = NotificationLaunher(currentUser: currentUser, target: NotifictionTarget.notification.descriptions)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Bildirimler"
        configureTableViewController()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showLauncher))
        get_notification(currentUser: currentUser)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
        notificaitonListener?.remove()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        notificaitonListener?.remove()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        getNotificationCount()
        
    }
    
    private lazy var footerView : UIView = {
       let v = UIView()
        let activityView = UIActivityIndicatorView(style: .gray)
        v.addSubview(activityView)
        activityView.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        activityView.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        return v
    }()
    
    //MARK: - functions
    
    func getTypeText(type : String) -> String{
        if type == NotificationType.comment_home.desprition{
            return Notification_description.comment_home.desprition
        }else if type == NotificationType.comment_like.desprition{
            return Notification_description.comment_like.desprition
        }else if type == NotificationType.comment_mention.desprition {
            return Notification_description.comment_mention.desprition
        }else if type == NotificationType.following_you.desprition{
            return Notification_description.following_you.desprition
        }else if type == NotificationType.home_like.desprition{
            return  Notification_description.like_home.desprition
        }else if type == NotificationType.home_new_post.desprition{
            return Notification_description.home_new_post.desprition
        }else if type == NotificationType.reply_comment.desprition {
            return Notification_description.reply_comment.desprition
        }
        return ""
    }
    
    func get_notification(currentUser : CurrentUser )
    {
        tableView.refreshControl?.beginRefreshing()
        isLoadMore = true
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").order(by: "not_id", descending: true).limit(to: 10)
        
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            guard let snap = querySnap else {
                return
            }
            if err == nil {
                
                for item in snap.documents {
                    if item.exists{
                        sself.model.append(NotificationModel.init(not_id: item.get("not_id") as! String, dic: item.data()))
                        sself.page = snap.documents.last
                        
                    }
                }
                
            }
            
          
                sself.tableView.reloadData()
                sself.refreshControl.endRefreshing()
                sself.tableView.contentOffset = .zero
                sself.isLoadMore = true
                
            
        }
        
        
        
    }
    private func loadMoreNotification(completion : @escaping(Bool) ->Void){
        guard let pagee = page else {
            isLoadMore = false
            tableView.reloadData()
            completion(false)
            tableView.tableFooterView = nil
            return }
        let  db =  Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").order(by: "not_id", descending: true).limit(to: 10).start(afterDocument: pagee)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            guard let snap = querySnap else {
                return
            }
            
            if let err = err {
                print("\(err.localizedDescription)")
                completion(false)
            }else if snap.isEmpty{
                sself.isLoadMore = false
                sself.tableView.reloadData()
                completion(false)
            }else{
                for item in snap.documents {
                    if item.exists{
                        sself.model.append(NotificationModel.init(not_id: item.get("not_id") as! String, dic: item.data()))
                        sself.isLoadMore = true
                        sself.tableView.reloadData()
                        completion(true)
                        
                    }
                }
                sself.page = snap.documents.last
            }
            
          
        }
    }
    
    
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
                        sself.makeReadNotificaiton(not_id: item.documentID) { (_) in
                            completion(true)
                        }
                    }
                }else{
                    completion(true)
                }
                
            }
        }
    }
    private func makeReadNotificaiton(not_id : String ,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").document(not_id)
        db.setData(["isRead":true], merge: true) { (err) in
            if err == nil {
                completion(true)
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
                    sself.tableView.reloadData()
                }
                
                completion(true)
            }
        }
    }
    
    private func configureTableViewController(){
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(NotificaitionCell.self, forCellReuseIdentifier: cellId)
        
//        tableView.tableFooterView?.isHidden = true
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(swipeAndRfresh), for: .valueChanged)
//        tableView.alwaysBounceVertical = true
        tableView.isUserInteractionEnabled = true
    }
    
    func markAsRead(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Okundu") {[weak self] (action, view, completion) in
            guard let sself = self else { return }
            sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                sself.model[indexPath.row].isRead = true
                sself.tableView.reloadData()
                completion(true)
            }
            
        }
        action.backgroundColor = .systemGreen
        
        action.image = #imageLiteral(resourceName: "readed-white").withRenderingMode(.alwaysOriginal)
        return action
    }
    func showPost(at indexPath :IndexPath) ->UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Görüntüle") {[weak self] (action, view, completion) in
            guard let sself = self  else { return }
            
            
            Utilities.waitProgress(msg: nil)
            
            if sself.model[indexPath.row].type == NotificationType.following_you.desprition
            {
                UserService.shared.fetchOtherUser(uid: sself.model[indexPath.row].senderUid) {(user) in
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
                    sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                        sself.model[indexPath.row].isRead = true
                        sself.tableView.reloadData()
                        
                    }
                }
            }else if sself.model[indexPath.row].type == NotificationType.comment_home.desprition ||
                        sself.model[indexPath.row].type == NotificationType.comment_like.desprition ||
                        sself.model[indexPath.row].type == NotificationType.comment_mention.desprition ||
                        sself.model[indexPath.row].type == NotificationType.home_like.desprition ||
                        sself.model[indexPath.row].type == NotificationType.reply_comment.desprition ||
                        sself.model[indexPath.row].type == NotificationType.home_new_post.desprition {
                sself.getPost(postID: sself.model[indexPath.row].postId, not_id: sself.model[indexPath.row].not_id) { (postModel) in
                    guard let post = postModel else {
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış")
                        return }
                    let vc = CommentVC(currentUser: sself.currentUser, post: post)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                        sself.model[indexPath.row].isRead = true
                        sself.tableView.reloadData()
                        
                    }
                    Utilities.dismissProgress()
                }
            }else {
                MainPostService.shared.getMainPost(postId: sself.model[indexPath.row].postId) {[weak self] (post) in
                    
                    guard let post = post else{
                        Utilities.errorProgress(msg: "Gönderi Kaldırılmış veya Silinmiş")
                        return
                    }
//                    let vc = MainPostCommentVC(currentUser: sself.currentUser, post: post, target: post.postType)
//                    self?.navigationController?.pushViewController(vc, animated: true)
                    sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                        sself.model[indexPath.row].isRead = true
                        sself.tableView.reloadData()
                        
                    }
                    Utilities.dismissProgress()
                    
                }
            }
            
            
        }
        action.backgroundColor = .mainColor()
        action.title = "Görüntüle"
        action.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
        return action
    }
    
    
    func deleteAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Sil") {[weak self] (action, view, completion) in
            guard let sself = self else { return }
            let notId = sself.model[indexPath.row].not_id
            sself.model.remove(at: indexPath.row)
            sself.tableView.reloadData()
            sself.deleteNotification(not_id: notId!) { (_) in
                
            }
            
        }
        action.backgroundColor = .red
        
        action.image = UIImage(named: "remove")
        return action
    }
    private func getPost(postID : String,not_id : String , completion : @escaping(LessonPostModel?) ->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postID)
        db.getDocument {[weak self] (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else { return }
                guard let sself = self else { return }
                if snap.exists{
                    completion(LessonPostModel.init(postId: postID, dic: snap.data()))
                }else{
                    sself.deleteNotification(not_id: not_id) { (_) in
                        Utilities.errorProgress(msg: "Bu Gönderi Silinmiş")
                        sself.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    //MARK:-selector
    @objc func showLauncher(){
        notificationLauncher.show()
        notificationLauncher.delegate = self
    }
    @objc func swipeAndRfresh(){
        model = [NotificationModel]()
        tableView.reloadData()
        get_notification(currentUser: currentUser)
    }
    
}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let edit = markAsRead(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Utilities.waitProgress(msg: nil)
        let reply = showPost(at: indexPath)
        Utilities.dismissProgress()
        return UISwipeActionsConfiguration(actions: [reply])
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificaitionCell
        cell.model = model[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        guard let text = model[indexPath.row].text else { return 0}
        let totalText = text + getTypeText(type: model[indexPath.row].type)
        let h = totalText.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
        
        if h < 25 {
            return 62
        }else{
            return 25 + h + 25
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isLoadMore {
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Utilities.waitProgress(msg: nil)
        
        if model[indexPath.row].type == NotificationType.following_you.desprition
        {
            UserService.shared.fetchOtherUser(uid: model[indexPath.row].senderUid) {[weak self] (user) in
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
                sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                    sself.model[indexPath.row].isRead = true
                    sself.tableView.reloadData()
                    
                }
                
            }
        }else if model[indexPath.row].type == NotificationType.comment_home.desprition ||
                    model[indexPath.row].type == NotificationType.comment_like.desprition ||
                    model[indexPath.row].type == NotificationType.comment_mention.desprition ||
                    model[indexPath.row].type == NotificationType.home_like.desprition ||
                    model[indexPath.row].type == NotificationType.reply_comment.desprition ||
                    model[indexPath.row].type == NotificationType.home_new_post.desprition{
            
            
            
            
            getPost(postID: model[indexPath.row].postId, not_id: model[indexPath.row].not_id) {[weak self] (postModel) in
                guard let sself = self else { return }
                guard let post = postModel else {
                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış veya Silinmiş")
                    return }
                let vc = CommentVC(currentUser: sself.currentUser, post: post)
                sself.navigationController?.pushViewController(vc, animated: true)
                sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                    sself.model[indexPath.row].isRead = true
                    sself.tableView.reloadData()
                    
                }
                Utilities.dismissProgress()
            }
        }
        else if
            model[indexPath.row].type == NotificationType.notices_comment_like.desprition || model[indexPath.row].type == NotificationType.notices_post_like.desprition
                || model[indexPath.row].type == NotificationType.notices_replied_comment_like.desprition || model[indexPath.row].type == NotificationType.notices_new_comment.desprition ||
                model[indexPath.row].type == NotificationType.notice_mention_comment.desprition{
            NoticesService.shared.getNoticesPost(postId: model[indexPath.row].postId, currentUser: currentUser) {[weak self] (post) in
                guard let sself = self else { return }
                guard let post = post else {
                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış veya Silinmiş")
                    return }
                let vc = MajorPostCommentController(currentUser: sself.currentUser, postId: post.postId, lessonPost: nil, noticesPost: post, mainPost: nil)
                sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                    sself.model[indexPath.row].isRead = true
                    sself.tableView.reloadData()
                    
                }
                Utilities.dismissProgress()
            }
            
        }
        else {
            MainPostService.shared.getMainPost(postId: model[indexPath.row].postId) {[weak self] (post) in
                guard let sself = self else { return }
                guard let post = post else{
                    Utilities.errorProgress(msg: "Gönderi Kaldırılmış veya Silinmiş")
                    return
                }
//                let vc = MainPostCommentVC(currentUser: sself.currentUser, post: post, target: post.postType)
//                self?.navigationController?.pushViewController(vc, animated: true)
                sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                    sself.model[indexPath.row].isRead = true
                    sself.tableView.reloadData()
                    
                }
                Utilities.dismissProgress()
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if model.count > 9 {
            
            if indexPath.item == model.count - 1 {
                self.loadMoreNotification {(val) in
                }
            }
        }
        
    }
    
    
}
extension NotificationVC : NotificationLauncherDelegate{
    func didSelect(option: NotificationOptions) {
        switch option {
        
        case .makeAllRead(_):
            setNotificationRead {[weak self] (_) in
                guard let sself = self else { return }
                for item in sself.model{
                    item.isRead = true
                }
                sself.tableView.reloadData()
                Utilities.dismissProgress()
            }
        case .deleteAll(_):
            getAllNotificationForDelete {[weak self] (_) in
                guard let sself = self else { return }
                sself.model = [NotificationModel]()
                sself.tableView.reloadData()
                Utilities.dismissProgress()
            }
        }
    }
    
    
}




