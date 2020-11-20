//
//  BuyAndCellVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 8.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import GoogleMobileAds
import SDWebImage
import FirebaseStorage
import MapKit

import CoreLocation
private let cellID = "cellID"
private let cellData = "cellData"
private let loadMoreCell = "loadmorecell"
private let cellAds = "cellAds"
class BuyAndCellVC: UIViewController {
    var currentUser : CurrentUser

    lazy var followers = [String]()
    var collectionview: UICollectionView!
    var refresher = UIRefreshControl()
    var page : DocumentSnapshot? = nil
    var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    var nativeAdView: GADUnifiedNativeAdView!
    weak var notificaitonListener : ListenerRegistration?
    weak var delegate : BuySellVCDelegate?
    var mainPost = [MainPostModel]()
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    private var actionSheetCurrentUser : ActionSheetMainPost
    private var actionSheetOtherUser : ASMainPostOtherUser
    /// The ad unit ID.
    let adUnitID = "ca-app-pub-3940256099942544/2521693316"  // "ca-app-pub-3940256099942544/3986624511"
    //    let adUnitID = "ca-app-pub-1362663023819993/1801312504"
    var nativeAd: GADUnifiedNativeAd?
    
    //MARK:-properties
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
    let label : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    lazy var msg_text : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    //    MARK: -lifeCycle
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        self.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
        self.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (user) in
            if let sself = self {
                sself.followers = user
            }
        }
        
        checkHasPost {[weak self] (_val) in
            guard let sself = self else { return }
            if _val{
                sself.configureUI()
            }else{
               
            }
        }
        view.backgroundColor = .collectionColor()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Al - Sat"
  
        checkFollowingTopic(currentUser: currentUser) { [weak self] (_val) in
            guard let sself = self else { return }
            sself.setNavigationBarItems(val: _val)
        }
    }
    //MARK:-functions
 
    fileprivate  func setNavigationBarItems(val : Bool) {
        if val {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(#imageLiteral(resourceName: "bell-selected"), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(enableNotification), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.setImage(#imageLiteral(resourceName: "info"), for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn2.addTarget(self, action: #selector(aboutPage), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: btn2)
            self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
            
        }else{
            let btn1 = UIButton(type: .custom)
            btn1.setImage(#imageLiteral(resourceName: "not"), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(enableNotification), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.setImage(#imageLiteral(resourceName: "info"), for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn2.addTarget(self, action: #selector(aboutPage), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: btn2)
            self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
            
        }
        
        
    }
    fileprivate func configureUI(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(BuyAndSellView.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(BuyAndSellDataView.self , forCellWithReuseIdentifier: cellData)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        collectionview.refreshControl?.beginRefreshing()
        
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        getPost()
        
    }
    fileprivate func  getPost(){
        
        mainPost = [MainPostModel]()
        loadMore = true
        collectionview.reloadData()
        
        fetchMainPost(currentUser: self.currentUser) {[weak self] (post) in
            self?.mainPost = post
            //            self?.fetchAds()
            if self?.mainPost.count ?? -1 > 0{
                self?.collectionview.refreshControl?.endRefreshing()
                if  let time_e = self?.mainPost[(self?.mainPost.count)! - 1].postTime{
                    self?.time = self?.mainPost[(self?.mainPost.count)! - 1].postTime
                    self?.mainPost.sort(by: { (post, post1) -> Bool in
                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    self?.collectionview.reloadData()
                }
            }else{
                self?.fetchAds()
                self?.collectionview.refreshControl?.endRefreshing()
                self?.collectionview.reloadData()
            }
        }
        
    }
    func fetchMainPost(currentUser : CurrentUser, completion : @escaping([MainPostModel])->Void){
        collectionview.refreshControl?.beginRefreshing()
        var post = [MainPostModel]()
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("main-post")
            .collection("sell-buy").limit(to: 5)
            .order(by: "postId",descending: true)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    //İSTE/main-post/post/1602875543801
                    for postId in snap.documents {
                        //main-post/sell-buy/post/1603356076781
                        let db = Firestore.firestore().collection("main-post")
                            .document("sell-buy")
                            .collection("post")
                            .document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists
                                {
                                    post.append(MainPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                }else{
                                    
                                    let deleteDb = Firestore.firestore().collection(currentUser.short_school)
                                        .document("main-post")
                                        .collection("sell-buy").document(postId.documentID)
                                    deleteDb.delete()
                                }
                                completion(post)
                            }
                        }
                        
                    }
                    
                    self.page = snap.documents.last
                    self.fetchAds()
                    self.loadMore = true
                    
                }
                
            }
        }
        
    }
    func fetchAds() {
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    private func checkHasPost(completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document("sell-buy").collection("post")
        db.getDocuments { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return}
                if snap.isEmpty{
                    completion(false)
                }else{
                    completion(true)
                }
            }
        }
     
    }
    
    private func checkFollowingTopic(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        //İSTE/sell-buy/followers/StTsYlJUVX4zOUzhRzXt
        let db = Firestore.firestore().collection("main-post")
            .document("sell-buy").collection("followers")
            .document(currentUser.uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return
                }
                if snap.exists{
                    completion(true)
                }
                else{
                    completion(false)
                }
            }else{
                completion(false)
            }
        }
        
    }
    
    private func followTopic(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        checkFollowingTopic(currentUser: currentUser) {[weak self] (_val) in
            guard let sself = self else { return }
            
            if _val{
                ///main-post/sell-buy/post/1603292156873
                
                let db = Firestore.firestore().collection("main-post")
                    .document("sell-buy")
                    .collection("followers")
                    .document(currentUser.uid)
                db.delete { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Kapandı")
                        sself.setNavigationBarItems(val: false)
                    }
                }
            }else{
              
                let db = Firestore.firestore().collection("main-post")
                    .document("sell-buy")
                    .collection("followers").document(currentUser.uid)
 
                db.setData(["userId":currentUser.uid as Any , "school":currentUser.short_school as Any] as [String : Any], merge: true) { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Açıldı")
                        sself.setNavigationBarItems(val: true)
                    }
                }
            }
        }
        
        
    }
    
    
    //MARK: -selectors
    @objc func enableNotification(){
        followTopic(currentUser: currentUser) { (_) in
            print("succes")
        }
    }
    @objc func aboutPage(){
        print("about")
    }
    @objc func newPost(){
        Utilities.waitProgress(msg: nil)

            UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
                guard let sself = self else { return }
                let vc = SetNewBuySellVC(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
            
        }
        
    }
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
    }
    
}
extension BuyAndCellVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if mainPost[indexPath.row].postId == nil {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
            cell.nativeAd = mainPost[indexPath.row].nativeAd
            return cell
        }else{
            if mainPost[indexPath.row].data.isEmpty {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BuyAndSellView
                cell.delegate = self
                cell.currentUser = currentUser
                
                cell.backgroundColor = .white
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
                cell.bottomBar.anchor(top: nil, left: cell.priceLbl.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.mainPost = mainPost[indexPath.row]
                
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! BuyAndSellDataView
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4 + 20 + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.mainPost = mainPost[indexPath.row]
                
                return cell
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if mainPost[indexPath.row].postId == nil {
            return CGSize(width: view.frame.width, height: 409)
        }else{
            
            if mainPost[indexPath.row].text == nil {
                return .zero
            }
            let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            
            if mainPost[indexPath.row].data.isEmpty{
                return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 50 + 5 )
            }
            else{
                return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 100 + 50 + 5)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MainPostCommentVC(currentUser: currentUser, post : mainPost[indexPath.row] , target: mainPost[indexPath.row].postType)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension BuyAndCellVC : BuySellVCDelegate{
    func options(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.actionSheetOtherUser.show(post: post, otherUser: user)

            }


        }
    }
    func mapClick(for cell: BuyAndSellView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])

    }
    func like(for cell: BuyAndSellView)
    {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    
    
    func comment(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post , target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellView) {
        guard let url = URL(string: (cell.mainPost?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for cell: BuyAndSellView) {
        guard  let post = cell.mainPost else {
            return
        }
      
        if post.senderUid == currentUser.uid{
            let vc = ProfileVC(currentUser: currentUser)
            vc.currentUser = currentUser
            navigationController?.pushViewController(vc, animated: true)

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()

        
            }
        }
    }
    
    func goProfileByMention(userName: String) {
        if "@\(userName)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                sself.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension BuyAndCellVC : BuySellVCDataDelegate {
    func mapClick(for cell: BuyAndSellDataView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    func options(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.actionSheetOtherUser.show(post: post, otherUser: user)

            }
        }
    }
    
    func like(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    func comment(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellDataView) {
        guard let url = URL(string: (cell.mainPost?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for cell: BuyAndSellDataView) {
        guard  let post = cell.mainPost else {
            return
        }
      
        if post.senderUid == currentUser.uid{
            let vc = ProfileVC(currentUser: currentUser)
            vc.currentUser = currentUser
            navigationController?.pushViewController(vc, animated: true)
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true, completion: nil)
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()

        
            }
        }
    }
    
    
}
//MARK: -ASMainPostLaungerDelgate
extension BuyAndCellVC : ASMainPostLaungerDelgate {
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        case .editPost(_):
            guard let index = selectedIndex else {
                return }
            if let h = collectionview.cellForItem(at: index) as? BuyAndSellDataView {
                let vc = EditMainPost(currentUser: currentUser, post: mainPost[index.row], heigth: h.msgText.frame.height)
                
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }else if let  h = collectionview.cellForItem(at: index) as? BuyAndSellView{
                let vc = EditMainPost(currentUser: currentUser, post: mainPost[index.row], heigth: h.msgText.frame.height)
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
            break
        case .deletePost(_):
            Utilities.waitProgress(msg: "Siliniyor")
            guard let index = selectedIndex else { return }
            guard let postId = selectedPostID else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return }
            guard let target = self.mainPost[index.row].postType else { return }
            let db = Firestore.firestore().collection("main-post")
                .document(target)
                .collection("post")
                .document(postId)
           
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    MainPostService.shared.deleteToStorage(data: sself.mainPost[index.row].data, postId: postId) { (_val) in
                        if (_val){
                            Utilities.succesProgress(msg: "Silindi")
                        }
                    }
                }else{
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
            break
        case .slientPost(_):
            print("slient post")
        }
    }
    
    
}

//MARK: - GADAdLoaderDelegate
extension BuyAndCellVC : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
      
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        self.loadMore = false
        self.collectionview.reloadData()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        self.nativeAd = nativeAd
        if mainPost.count > 0{
            if  let time_e = self.mainPost[(self.mainPost.count) - 1].postTime{
                self.mainPost.sort(by: { (post, post1) -> Bool in
                    
                    return post.postTime?.dateValue() ?? time_e.dateValue()   > post1.postTime?.dateValue() ??  time_e.dateValue()
                })
                
                self.mainPost.append(MainPostModel.init(nativeAd: nativeAd , postTime : self.mainPost[(self.mainPost.count) - 1].postTime!))
            }
        }
        self.loadMore = false
        self.collectionview.reloadData()
    }
}
