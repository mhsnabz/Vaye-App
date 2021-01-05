//
//  MessagesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let msg_cell = "msg_cell"
private let friend_cell = "friend_cell"
private let request_cell = "request_cell"
class MessagesVC: UIViewController, HomeMenuBarSelectedIndex {
    func getIndex(indexItem: Int) {
        self.selectedIndex = indexItem
    }
    var totalBadgeCount : Int?{
        didSet{
            guard let badge = totalBadgeCount else { return }
            if badge > 0  {
                menuBar.msgBadgeCount = badge
                self.tabBarController?.tabBar.items?[3].badgeValue = badge.description
            }else{
                menuBar.msgBadgeCount = nil
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            }
        }
    }
    var selectedIndex : Int?{
        didSet{
            setNavBarIcon()
            guard let index = selectedIndex else { return }
            if index == 0 {
                navigationItem.title = "Sohbetler"
            }else if index == 1 {
                navigationItem.title = "Arkadaşlar"
            }else{
                navigationItem.title = "Sohbet İstekleri"
            }
        }
    }
    
    weak var snapShotListener : ListenerRegistration?
    var currentUser : CurrentUser
    weak var listener : ListenerRegistration?
    weak var notificaitonListener : ListenerRegistration?
    private  var messagesOption : MessagesVCLauncher?
    var page : DocumentSnapshot? = nil
    //MARK:--properties
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    //MARK:--menu bar
    
    lazy var menuBar : ChatMenuBar = {
        let mb = ChatMenuBar()
        mb.homeController = self
        return mb
    }()
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Sohbet"

        setupMenuBar()
        configureUI()
        setNavigationBar()
        setNavBarIcon()
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
    private func getMessagesBadgeCount(){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("msg-list").whereField("badgeCount", isGreaterThan: 0 )
        notificaitonListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            guard let sself = self else { return }
            sself.totalBadgeCount = 0
            if err == nil {
                guard let snap = querySnap else { return }
                if !snap.isEmpty {
                    
                    for item in snap.documents{
                        sself.totalBadgeCount! += item.get("badgeCount") as! Int
                    }
                }
            }
        })
    }
    private func getMessagesRequestBadgeCount(){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("msg-list").whereField("badgeCount", isGreaterThan: 0 )
        notificaitonListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            guard let sself = self else { return }
            sself.totalBadgeCount = 0
            if err == nil {
                guard let snap = querySnap else { return }
                if !snap.isEmpty {
                    
                    for item in snap.documents{
                        sself.totalBadgeCount! += item.get("badgeCount") as! Int
                    }
                }
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        snapShotListener?.remove()
        notificaitonListener?.remove()
        let indexChatList = IndexPath(item: 0, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: indexChatList) as? ChatListCell{
            cell.snapShotListener?.remove()
            cell.times = -1
            cell.collectionview.reloadData()
        }
        let indexFriendList = IndexPath(item: 1, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: indexFriendList) as? FriendListCell{
            cell.snapShotListener?.remove()
            cell.times = -1
            cell.collectionview.reloadData()
        }
    
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        snapShotListener?.remove()
        notificaitonListener?.remove()
        let indexChatList = IndexPath(item: 0, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: indexChatList) as? ChatListCell{
            cell.snapShotListener?.remove()
        }
        let indexFriendList = IndexPath(item: 1, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: indexFriendList) as? FriendListCell{
            cell.snapShotListener?.remove()
            cell.times = -1
            cell.collectionview.reloadData()
        }
 
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessagesBadgeCount()
        getNotificationCount()
        
        let index = IndexPath(item: 0, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: index) as? ChatListCell{
            cell.times = 0
            cell.collectionview.reloadData()
        }
        let indexFriendList = IndexPath(item: 1, section: 0)
        if  let cell = collectionView(collecitonView, cellForItemAt: indexFriendList) as? FriendListCell{
        
            cell.times = 0
            cell.collectionview.reloadData()
        }
        collecitonView.reloadData()
    }
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collecitonView.register(ChatListCell.self, forCellWithReuseIdentifier: msg_cell)
        collecitonView.register(FriendListCell.self, forCellWithReuseIdentifier: friend_cell)
        collecitonView.register(RequestCell.self, forCellWithReuseIdentifier: request_cell)
    }
  
    
    //MARK:--funcitons
    
    private func setNavBarIcon(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showChatOption))
   
        if let index = selectedIndex {
            if index == 0 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showChatOption))
            }else if index == 1 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showChatOption))
            }else if index == 2 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showRequestOption))
            }
        }
    }
    
    private func  setupMenuBar(){
        
        view.addSubview(menuBar)
        
        menuBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 44)
        menuBar.delegate = self
    }

    func scrollToIndex ( menuIndex : Int) {
        let index = IndexPath(item: menuIndex, section: 0)
        
        self.collecitonView.isPagingEnabled = false
        self.collecitonView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        self.collecitonView.isPagingEnabled = true
        
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftConstarint?.constant = scrollView.contentOffset.x / 3
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let memoryIndex = targetContentOffset.pointee.x / view.frame.width
        
        let index = IndexPath(item: Int(memoryIndex), section: 0)
        menuBar.collecitonView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        menuBar.delegate?.getIndex(indexItem: Int(memoryIndex))
    }
    
    @objc func showChatOption()
    {
        messagesOption = MessagesVCLauncher(currentUser: currentUser, target: MessagesVCTarget.chat.description)
        guard let messagesOption = messagesOption else { return }
        messagesOption.show()
        messagesOption.delegate = self
    }
    @objc func showRequestOption(){
        messagesOption = MessagesVCLauncher(currentUser: currentUser, target: MessagesVCTarget.request.description)
        guard let messagesOption = messagesOption else { return }
        messagesOption.show()
        messagesOption.delegate = self
    }
    
    
}
extension MessagesVC  : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: msg_cell, for: indexPath) as! ChatListCell

            cell.currentUser = currentUser
//            cell.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
//            cell.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friend_cell, for: indexPath) as! FriendListCell

            cell.currentUser = currentUser
            cell.rootController = self
//            cell.friendListModel = friendList
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: request_cell, for: indexPath) as! RequestCell

            cell.currentUser = currentUser
            cell.rootController = self
           // cell.friendListModel = friendList
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = view.safeAreaInsets.top + view.safeAreaInsets.bottom + 45
        return CGSize(width: view.frame.width, height: view.frame.height - x)
    }
    
}

extension MessagesVC : MessagesVCSettingDelegate {
    func didSelect(option: MessagesVCOptions) {
        switch option {
   
        case .removeAllRequest(_):
            Utilities.waitProgress(msg: nil)
            ///user/4OaYqfc53gOBwAwVZMdu9XZV6ix2/msg-request/NOCWRTWMA3OXYvYFm5XFhR7KqZC2
            let db = Firestore.firestore().collection("user")
                .document(currentUser.uid)
                .collection("msg-request")
            db.getDocuments { (querySnap, err) in
                if err == nil {
                    guard let snap = querySnap else { return }
                    for item in snap.documents {
                        db.document(item.documentID).delete { (err) in
                            if err == nil {
                                Utilities.dismissProgress()
                            }
                        }
                    }
                }
            }
            break
        case .disableRequest(_):
            
            if currentUser.allowRequest{
                let alert = UIAlertController(title: "Mesaj İstekleri Kapat", message: "Sadece Karşılıklı Takipleştiğiniz Kullanıcılar Size Mesaj Atabilecek", preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Kapat", style: UIAlertAction.Style.destructive, handler:  { [weak self] action in
                  guard let sself = self else { return }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                    db.setData(["allowRequest":false], merge: true) { (err) in
                        if err == nil {
                            sself.currentUser.allowRequest = false
                        }
                    }
                 
                }))
                alert.addAction(UIAlertAction(title: "Vazgeç", style: UIAlertAction.Style.cancel, handler: {action in
                  
                }))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Mesaj İstekleri Aç", message: "Bütün Kullanıcılar Size Mesajlaşma İsteği Gönderebilecek", preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Aç", style: UIAlertAction.Style.destructive, handler:  { [weak self] action in
                  guard let sself = self else { return }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                    db.setData(["allowRequest":true], merge: true) { (err) in
                        if err == nil {
                            sself.currentUser.allowRequest = true
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Vazgeç", style: UIAlertAction.Style.cancel, handler: {action in
                  
                }))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            
   
            
            
            break
        }
    }
    
    
}
