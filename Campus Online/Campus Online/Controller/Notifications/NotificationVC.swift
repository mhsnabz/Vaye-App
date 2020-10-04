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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showLauncher))
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
    
    
    //MARK: - functions
    func get_notification(currentUser : CurrentUser )
    {
        tableView.refreshControl?.beginRefreshing()
        
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
            
            DispatchQueue.main.async(execute: {
                sself.tableView.reloadData()
                sself.refreshControl.endRefreshing()
                sself.tableView.contentOffset = .zero
               
            })
        }
        
  
        
    }
    private func loadMoreNotification(completion : @escaping(Bool) ->Void){
        guard let pagee = page else {

            tableView.reloadData()
            completion(false)
            tableView.tableFooterView = nil
            return }
        let  db =  Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification").order(by: "not_id", descending: true).limit(to: 10).start(afterDocument: pagee)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else {
                    return
                }
                for item in snap.documents {
                    if item.exists{
                        sself.model.append(NotificationModel.init(not_id: item.get("not_id") as! String, dic: item.data()))
                        sself.tableView.reloadData()
                        completion(true)

                    }
                }
                sself.page = snap.documents.last
                sself.tableView.stopLoading()
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
        db.delete { (err) in
            if err == nil{
                Utilities.dismissProgress()
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
        tableView.tableFooterView?.isHidden = true
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(swipeAndRfresh), for: .valueChanged)
        tableView.alwaysBounceVertical = true
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
            sself.getPost(postID: sself.model[indexPath.row].postId, not_id: sself.model[indexPath.row].not_id) { (postModel) in
                guard let post = postModel else { return }
                let vc = CommentVC(currentUser: sself.currentUser, post: post)
                sself.navigationController?.pushViewController(vc, animated: true)
                sself.makeReadNotificaiton(not_id: sself.model[indexPath.row].not_id) { (_) in
                    sself.model[indexPath.row].isRead = true
                    sself.tableView.reloadData()
                    completion(true)
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
        
        let h = text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
        if h < 25 {
            return 62
        }else{
            return 25 + h + 25
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Utilities.waitProgress(msg: nil)
        getPost(postID: model[indexPath.row].postId, not_id: model[indexPath.row].not_id) { (postModel) in
            guard let post = postModel else { return }
            let vc = CommentVC(currentUser: self.currentUser, post: post)
            self.navigationController?.pushViewController(vc, animated: true)
            self.makeReadNotificaiton(not_id: self.model[indexPath.row].not_id) { (_) in
                self.model[indexPath.row].isRead = true
                self.tableView.reloadData()
                
            }
            Utilities.dismissProgress()
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if model.count > 9 {
           
            if indexPath.item == model.count - 1 {
                tableView.addLoading(indexPath) {
                    self.loadMoreNotification {(val) in
                       
                    }
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

extension UITableView{

    func indicatorView() -> UIActivityIndicatorView{
        var activityIndicatorView = UIActivityIndicatorView()
        if self.tableFooterView == nil{
            let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
            activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
            activityIndicatorView.isHidden = false
            activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
            activityIndicatorView.isHidden = true
            self.tableFooterView = activityIndicatorView
            return activityIndicatorView
        }else{
            return activityIndicatorView
        }
    }

    func addLoading(_ indexPath:IndexPath, closure: @escaping (() -> Void)){
        indicatorView().startAnimating()
        if let lastVisibleIndexPath = self.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath && indexPath.row == self.numberOfRows(inSection: 0) - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    closure()
                }
            }
        }
        indicatorView().isHidden = false
    }

    func stopLoading(){
        indicatorView().stopAnimating()
        indicatorView().isHidden = true
       
    }
}
