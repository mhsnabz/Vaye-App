//
//  VayeApp.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 16.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let mainCell = "mainCell"
private let foodMeCell = "foodMeCell"
private let campingCell = "campingCell"
private let buySellCell = "buyCellSell"
class VayeApp: UIViewController, MainMenuBarSelectedIndex {
    func getIndex(indexItem: Int) {
        self.selectedIndex = indexItem
    }
    
    
    var selectedIndex : Int?{
        didSet{
            guard let index = selectedIndex else{
                navigationItem.title = "Vaye.App"
        
                return
            }
            
            navigationItem.title = navBarTitle[index]
        
        }
    }
    
    private var mainPostLauncher : MainPostActionSheet
    //MARK:-properties
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
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
    lazy var menuBar : VayeAppMenuBar = {
       let mb = VayeAppMenuBar()
        mb.vayeAppController = self
        return mb
    }()
    //    let imageName = ["follow_unselected","buy_sell_unselected","food_me_unselected","camping_unselected"]
    let navBarTitle = ["Vaye.App" , "Al-Sat" , "Yemek" , "Kamp"]
    var currentUser : CurrentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        setupMenuBar()
        configureUI()
        configureRigthBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        self.mainPostLauncher = MainPostActionSheet(currentUser: currentUser)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureRigthBarButton(){
    let rigthBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(optionsLauncher))
        navigationItem.rightBarButtonItem = rigthBtn
    }
    //MARK:--funcitons
    private func  setupMenuBar(){
        navigationItem.title = navBarTitle[0]
        view.addSubview(menuBar)
        menuBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
        menuBar.delegate = self
    }
    
    func scrollToIndex ( menuIndex : Int) {
        let index = IndexPath(item: menuIndex, section: 0)
        
        self.collecitonView.isPagingEnabled = false
        self.collecitonView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        self.collecitonView.isPagingEnabled = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftConstarint?.constant = scrollView.contentOffset.x / 4
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let memoryIndex = targetContentOffset.pointee.x / view.frame.width
     
        let index = IndexPath(item: Int(memoryIndex), section: 0)
        menuBar.collecitonView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        menuBar.delegate?.getIndex(indexItem: Int(memoryIndex))
    }
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
  
        collecitonView.register(MainCell.self, forCellWithReuseIdentifier: mainCell)
        collecitonView.register(FoodMe_Cell.self, forCellWithReuseIdentifier: foodMeCell)
        collecitonView.register(Camping_Cell.self, forCellWithReuseIdentifier: campingCell)
        collecitonView.register(BuySell_Cell.self, forCellWithReuseIdentifier: buySellCell)
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        
        
    }
    @objc func optionsLauncher(){
        let vc = VayeAppNotification()
        let controller = UINavigationController(rootViewController: vc)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @objc func newPost(){
        if let index = selectedIndex {
            if index  == 0 {
                mainPostLauncher.show()
                mainPostLauncher.delegate = self
            }
            else if index == 1 {
                
                UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                    guard let sself = self else { return }
                    let vc = SetNewBuySellVC(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                    
                }
            }else if index == 2 {
                UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                    guard let sself = self else { return }
                    let vc = SetNewFoodMePost(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                    
                }
            }else if index == 3 {
                UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                    guard let sself = self else { return }
                    let vc = SetNewCampingPost(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                    
                }
            }
        }else{
            mainPostLauncher.show()
            mainPostLauncher.delegate = self
        }
   
    }
   
}

extension VayeApp : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCell, for: indexPath) as! MainCell
            
            cell.currentUser = currentUser
            cell.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            cell.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buySellCell, for: indexPath) as! BuySell_Cell
            cell.currentUser = currentUser
            cell.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            cell.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
            return cell
        }else if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: foodMeCell, for: indexPath) as! FoodMe_Cell
            cell.currentUser = currentUser
            cell.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            cell.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
          
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: campingCell, for: indexPath) as! Camping_Cell
            cell.currentUser = currentUser
            cell.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
            cell.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
            cell.rootController = self
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = view.safeAreaInsets.top + view.safeAreaInsets.bottom + 55
        return CGSize(width: view.frame.width, height: view.frame.height - x)
    }
    
    
    
}
extension VayeApp : MainPostLauncherDelegate {
    func didSelect(option: MainPostSheetOptions) {
        switch option {
        
        case .buyAndSellPost(_):
            UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                guard let sself = self else { return }
                let vc = SetNewBuySellVC(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
                
            }
                
            
             
        case .foodMePost(_):
                UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                    guard let sself = self else { return }
                    let vc = SetNewFoodMePost(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
        case .campingPost(_):
            UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                guard let sself = self else { return }
                let vc = SetNewCampingPost(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
                
            }
        }
    }
    
    
}
