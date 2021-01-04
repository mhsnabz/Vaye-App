//
//  NotificationController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 3.01.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellId = "NotificaitionCell"
private let footerId = "footerID"

class NotificationController: UIViewController {
    var currentUser : CurrentUser
    var model = [NotificationModel]()
    var loadMore : Bool = false
    private lazy var notificationLauncher = NotificationLaunher(currentUser: currentUser, target: NotifictionTarget.notification.descriptions)
    
    
    var refreshControl = UIRefreshControl()
    var page : DocumentSnapshot? = nil
    weak var listener : ListenerRegistration?
    weak var notificaitonListener : ListenerRegistration?
    
    var tableView : UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    
    private lazy var footerView : UIView = {
       let v = UIView()
        let activityView = UIActivityIndicatorView(style: .gray)
        v.addSubview(activityView)
        activityView.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        activityView.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        return v
    }()
    
    //MARK:-lifeCycle
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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Bildirimler"
        configureTableViewController()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showLauncher))
        // Do any additional setup after loading the view.
    }
    init(currentUser : CurrentUser) {
        self.currentUser  = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func get_notification(currentUser : CurrentUser )
    {
        tableView.refreshControl?.beginRefreshing()
        loadMore = true
        self.model = [NotificationModel]()
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
                sself.loadMore = true
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
    //MARK:--functions
    func configureTableViewController(){
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(NotificaitionCell.self, forCellReuseIdentifier: cellId)
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(swipeAndRfresh), for: .valueChanged)
//        tableView.alwaysBounceVertical = true
        tableView.isUserInteractionEnabled = true
    }
    
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
    //MARK:-selectors
    @objc func showLauncher(){
        
    }
    @objc func swipeAndRfresh(){
       
    }
}

extension NotificationController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
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
        if loadMore {
            return 50
        }else{
            return 0
        }
    }
    
}
