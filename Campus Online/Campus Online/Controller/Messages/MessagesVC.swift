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
class MessagesVC: UIViewController, HomeMenuBarSelectedIndex {
    func getIndex(indexItem: Int) {
        self.selectedIndex = indexItem
    }
    var selectedIndex : Int?{
        didSet{
            setNavBarButton()
            guard let index = selectedIndex else { return }
            if index == 0 {
                navigationItem.title = "Sohbetler"
            }else if index == 1 {
                navigationItem.title = "Arkadaşlar"
            }
        }
    }
    var currentUser : CurrentUser
    weak var listener : ListenerRegistration?
    weak var notificaitonListener : ListenerRegistration?
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
        setNavBarButton()
    }
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collecitonView.register(ChatListCell.self, forCellWithReuseIdentifier: msg_cell)
        collecitonView.register(FriendListCell.self, forCellWithReuseIdentifier: friend_cell)
          
    }
    //MARK:--funcitons
    private func  setupMenuBar(){
        
        view.addSubview(menuBar)
        
        menuBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 44)
        menuBar.delegate = self
    }
    private func setNavBarButton(){
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action:  #selector(menuClick))
//        if let index = selectedIndex {
//
//            if index == 0 {
//                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
//            }else if index == 1 {
//                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(schollNotificaitonSetting))
//            }
//        }else{
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
//        }
    }
    func scrollToIndex ( menuIndex : Int) {
        let index = IndexPath(item: menuIndex, section: 0)
        
        self.collecitonView.isPagingEnabled = false
        self.collecitonView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        self.collecitonView.isPagingEnabled = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftConstarint?.constant = scrollView.contentOffset.x / 2
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let memoryIndex = targetContentOffset.pointee.x / view.frame.width
        
        let index = IndexPath(item: Int(memoryIndex), section: 0)
        menuBar.collecitonView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        menuBar.delegate?.getIndex(indexItem: Int(memoryIndex))
    }
}
extension MessagesVC  : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: msg_cell, for: indexPath) as! ChatListCell
            cell.backgroundColor = .red
//            cell.currentUser = currentUser
//            cell.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
//            cell.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
//            cell.rootController = self
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friend_cell, for: indexPath) as! FriendListCell
            cell.backgroundColor = .black
//            cell.currentUser = currentUser
//            cell.rootController = self
//            cell.actionSheetOtherUser = ASNoticesPostLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
//            cell.actionSheetCurrentUser = ASNoticesPostCurrentUserLaunher(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = view.safeAreaInsets.top + view.safeAreaInsets.bottom + 45
        return CGSize(width: view.frame.width, height: view.frame.height - x)
    }
    
}

