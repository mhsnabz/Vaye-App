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
    //MARK:-functions
    
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
                getTypeDescribing(type: model[indexPath.row].type) == Notification_description.reply_comment.desprition{
            
            let text = model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text +  getTypeDescribing(type: model[indexPath.row].type)
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            
            if h > 41 {
                return CGSize(width: view.frame.width, height: 12 + h + 5)
            }else{
                return CGSize(width: view.frame.width, height: 50)
            }
        }else{
            let text =  model[indexPath.row].senderName + model[indexPath.row].username +
                model[indexPath.row].time.dateValue().timeAgoDisplay() + "\n" + model[indexPath.row].text
            let h = text.height(withConstrainedWidth: view.frame.width - 44, font: UIFont(name: Utilities.font, size: 12)!)
            if h > 41 {
                return CGSize(width: view.frame.width, height: 12 + h + 5)
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
    
}
extension LocalNotificationController : NotificationLauncherDelegate {
    func didSelect(option: NotificationOptions) {
        switch option {
        
        case .makeAllRead(_):
            break
        case .deleteAll(_):
            break
        }
    }
    
    
}
extension LocalNotificationController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Sil") { (action, indexPat) in
                
            }
            
            deleteAction.image = #imageLiteral(resourceName: "remove").withRenderingMode(.alwaysOriginal)
            deleteAction.font = UIFont(name: Utilities.font, size: 11)
            return [deleteAction]
        }else {
            let read = SwipeAction(style: .destructive, title: "Görüntüle") { (action, indexPath) in
                
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
