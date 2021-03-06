//
//  HOMEVC.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 2.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let home_cell = "Home_cell"
private let scholl_cell = "scholl_cell"
class HOMEVC: UIViewController ,HomeMenuBarSelectedIndex{
    
    
    
    func getIndex(indexItem: Int) {
        self.selectedIndex = indexItem
    }
    weak var delegate : HomeControllerDelegate?
    var isMenuOpen : Bool = false
    var currentUser : CurrentUser
    
    var totalBadgeCount : Int?{
        didSet{
            guard let badge = totalBadgeCount else {
            
                return }
            if badge > 0  {
               
                self.tabBarController?.tabBar.items?[3].badgeValue = badge.description
            }else{
                
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            }
        }
    }
    var selectedIndex : Int?{
        didSet{
            
            guard let index = selectedIndex else { return }
            setNavBarButton()
            if index == 0 {
                navigationItem.title = currentUser.bolum
            }else if index == 1 {
                navigationItem.title = currentUser.short_school + " Kulüpleri"
            }
        }
    }
    lazy var menuBar : HomeMenuView = {
        let mb = HomeMenuView()
        mb.controllerDelegate = self
        return mb
    }()
    lazy var backView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.init(white: 0.95, alpha: 0.5)
        
        return v
    }()
    weak var notificaitonListener : ListenerRegistration?
    
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
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Vaye.App"
        setupMenuBar()
        setNavBarButton()
        configureUI()
        menuBar.delegate = self
        
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-functions
    private func setNavBarButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action:  #selector(menuClick))
        if let index = selectedIndex {
           
            if index == 0 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
            }else if index == 1 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(schollNotificaitonSetting))
            }
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
        }
    }
    private func  setupMenuBar(){
        
        view.addSubview(menuBar)
        
        menuBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 44)
        menuBar.controllerDelegate = self
    }
    
    
    private func configureUI(){
        
    
        
        view.addSubview(collecitonView)
        collecitonView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collecitonView.register(Home_Cell.self, forCellWithReuseIdentifier: home_cell)
        collecitonView.register(School_Cell.self, forCellWithReuseIdentifier: scholl_cell)
        
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        
        
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
    //MARK:-objc
    @objc func menuClick(){
        self.delegate?.handleMenuToggle(forMenuOption: nil)

    }
    @objc func schollNotificaitonSetting(){
        let vc = SchoolPostNotificationSetting(currentUser : currentUser)
        let controller = UINavigationController(rootViewController: vc)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @objc func setLessons(){
        
        if currentUser.priority == "teacher"
        {
           let vc = TeacherSetLesson(currentUser: currentUser)
            vc.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                vc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            
        }else if currentUser.priority == "student"{
            let vc = LessonList(currentUser: currentUser)
            vc.currentUser = currentUser
            vc.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                vc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            
            vc.modalPresentationStyle = .fullScreen
            self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        }
        
        
    }
    
    @objc func newPost(){
        if let index = selectedIndex{
            if index == 0 {
                if currentUser.priority == "teacher" {
                    
                    let vc = TeacherChooseLesson(currentUser: currentUser)
                    let  centerController = UINavigationController(rootViewController: vc)
                    centerController.modalPresentationStyle = .fullScreen
                    self.present(centerController, animated: true, completion: nil)
                }else if currentUser.priority == "student"{
                    
                    let vc = ChooseLessonTB(currentUser: currentUser)
                    let  centerController = UINavigationController(rootViewController: vc)
                    centerController.modalPresentationStyle = .fullScreen
                    self.present(centerController, animated: true, completion: nil)
                }
             }
            else if index == 1{
                let vc = ChooseClub(currentUser: currentUser, dataSource: NoticesService.shared.getHastag(currentUser: currentUser))
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if currentUser.priority == "teacher" {
            
            let vc = TeacherChooseLesson(currentUser: currentUser)
            let  centerController = UINavigationController(rootViewController: vc)
            centerController.modalPresentationStyle = .fullScreen
            self.present(centerController, animated: true, completion: nil)
        }else  if currentUser.priority == "student"{
            
            let vc = ChooseLessonTB(currentUser: currentUser)
            let  centerController = UINavigationController(rootViewController: vc)
            centerController.modalPresentationStyle = .fullScreen
            self.present(centerController, animated: true, completion: nil)
        } }
    }
}
extension HOMEVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_cell, for: indexPath) as! Home_Cell
            cell.currentUser = currentUser
            cell.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
            cell.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scholl_cell, for: indexPath) as! School_Cell
            cell.currentUser = currentUser
            cell.rootController = self
            cell.actionSheetOtherUser = ASNoticesPostLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.actionSheetCurrentUser = ASNoticesPostCurrentUserLaunher(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = view.safeAreaInsets.top + view.safeAreaInsets.bottom + 45
        return CGSize(width: view.frame.width, height: view.frame.height - x)
    }
    
}

