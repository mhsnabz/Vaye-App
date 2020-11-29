//
//  CampusOnlineVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
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

private let cell_foodme_id = "cell_food_me_id"
private let cell_foodme_data_id = "cell_foodme_data_id"

private let cell_camp_id = "cell_camp_id"
private let cell_camp_data_id = "cell_camp_data_id"


class CampusOnlineVC: UIViewController{
    var currentUser : CurrentUser
    weak var delegate : CoControllerDelegate?
    var isMenuOpen : Bool = false
    var mainPost = [MainPostModel]()
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    var nativeAd: GADUnifiedNativeAd?
    lazy var followers = [String]()
    var collectionview: UICollectionView!
    var refresher = UIRefreshControl()
    var page : DocumentSnapshot? = nil
    var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    var nativeAdView: GADUnifiedNativeAdView!
    
    private var actionSheetCurrentUser : ActionSheetMainPost
    private var actionSheetOtherUser : ASMainPostOtherUser
    let adUnitID =  "ca-app-pub-3940256099942544/3986624511"
//        let adUnitID = "ca-app-pub-1362663023819993/1801312504"
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
    
    //MARK: -lifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
  
    }
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
//        animationView()
        
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        view.backgroundColor = .white
        navigationItem.title = "Takip Ettiklerin"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        checkHasFollowingAnyUser {[weak self] (_val) in
            guard let sself = self else { return }
            sself.configureUI()
        }
        view.backgroundColor = .collectionColor()
    }
    
    
    
    //MARK:-selectors
    @objc func menuClick(){
        self.delegate?.handleMenuToggle(forMenuOption: nil)
        if !isMenuOpen {
            self.isMenuOpen = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        }
        else{
            self.isMenuOpen = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        }
    }
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
    }
    
    
    //MARK: - functions
    
    private func checkHasFollowingAnyUser(completion : @escaping(Bool) ->Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/following/4OaYqfc53gOBwAwVZMdu9XZV6ix2
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("following")
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
        collectionview.register(FoodMeView.self, forCellWithReuseIdentifier: cell_foodme_id)
        collectionview.register(FoodMeViewData.self, forCellWithReuseIdentifier: cell_foodme_data_id)
        collectionview.register(CampingView.self, forCellWithReuseIdentifier: cell_camp_id)
        collectionview.register(CampingDataView.self, forCellWithReuseIdentifier: cell_camp_data_id)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        collectionview.refreshControl?.beginRefreshing()
      
        getPost()
    }
    
    //MARK: -post
    fileprivate func getPost(){
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
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("main-post").limit(to: 5)
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
                            .document("post")
                            .collection("post")
                            .document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists
                                {
                                    post.append(MainPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                }else{
                                    let db_currentUser = Firestore.firestore().collection("user")
                                        .document(currentUser.uid)
                                        .collection("main-post")
                                        .document(postId.documentID)
                                    db_currentUser.delete(){(err) in
                                        if let postType = postId.get("postType") as? String {
                                            let deleteDb = Firestore.firestore().collection(currentUser.short_school)
                                                .document("main-post")
                                                .collection(postType).document(postId.documentID)
                                            deleteDb.delete()
                                        }
                                    }
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
    
    private func loadMorePost(completion: @escaping(Bool) ->Void){
     
        
        guard let pagee = page else {
            loadMore = false
            collectionview.reloadData()
            completion(false)
            return }
        let  db =  Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("main-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: pagee)
        db.getDocuments { [self] (snapshot, err ) in
            guard let snap = snapshot else { return }
            if let err = err {
                print("\(err.localizedDescription)")
            }else if snap.isEmpty {
                self.loadMore = false
                collectionview.reloadData()
                completion(false)
            
            }else{
                for item in snap.documents{
                    let db = Firestore.firestore().collection("main-post")
                        .document("post").collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else { return }
                            if snapp.exists
                            {
                                
                                self.mainPost.append(MainPostModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = self.mainPost[(self.mainPost.count) - 1].postTime{
                                    self.time = self.mainPost[(self.mainPost.count) - 1].postTime
                                    self.mainPost.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    self.loadMore = true
                                    self.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                               
                          
                                
                            }else{
                                
                                let db_currentUser = Firestore.firestore().collection("user")
                                    .document(currentUser.uid)
                                    .collection("main-post")
                                    .document(item.documentID)
                                db_currentUser.delete(){(err) in
                                    if let postType = item.get("postType") as? String {
                                        let deleteDb = Firestore.firestore().collection(currentUser.short_school)
                                            .document("main-post")
                                            .collection(postType).document(item.documentID)
                                        deleteDb.delete()
                                    }
                                }
                                
                            }
                        }
                        
                    }
                   
                    page = snap.documents.last
                    
                  
                    
                }
                self.fetchAds()
//                self.collectionview.reloadData()
                
//                loadMore = false
                
            }
        }
        
    }
    
    func fetchAds() {
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}
extension CampusOnlineVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if mainPost[indexPath.row].postId == nil {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
            cell.nativeAd = mainPost[indexPath.row].nativeAd
            return cell
        }else{
            
            if mainPost[indexPath.row].postType == PostType.buySell.despription{
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
            }else if mainPost[indexPath.row].postType == PostType.foodMe.despription{
                if mainPost[indexPath.row].data.isEmpty {
                    let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_foodme_id, for: indexPath) as! FoodMeView
                    cell.delegate = self
                    cell.currentUser = currentUser
                    cell.backgroundColor = .white
                    let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                   
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = mainPost[indexPath.row]
                    return cell
                }else{
                    let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_foodme_data_id, for: indexPath) as! FoodMeViewData
                    
                    cell.backgroundColor = .white
                    cell.delegate = self
                    cell.currentUser = currentUser
                    let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    
                    cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
                    
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = mainPost[indexPath.row]
                    return cell
                }
            }else if mainPost[indexPath.row].postType == PostType.camping.despription{
                if mainPost[indexPath.row].data.isEmpty {
                   
                        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_camp_id, for: indexPath) as! CampingView
                        cell.delegate = self
                        cell.currentUser = currentUser
                        cell.backgroundColor = .white
                        let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                        cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                       
                        cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                        cell.mainPost = mainPost[indexPath.row]
                        return cell
                }else{
                    let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_camp_data_id, for: indexPath) as! CampingDataView
                    
                    cell.backgroundColor = .white
                    cell.delegate = self
                    cell.currentUser = currentUser
                    let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                    cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                    
                    cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
                    
                    cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                    cell.mainPost = mainPost[indexPath.row]
                    return cell
                }
            }
            
            
        }
       
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath) as! EmptyCell
        return cell
        
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
            
            if mainPost[indexPath.row].postType == PostType.buySell.despription{
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                
                if mainPost[indexPath.row].data.isEmpty{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 50 + 5 )
                }
                else{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 100 + 50 + 5)
                }
            }
            else if mainPost[indexPath.row].postType == PostType.foodMe.despription{
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                
                if mainPost[indexPath.row].data.isEmpty{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 30 + 5 )
                }
                else{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 100 + 30 + 5)
                }
            }
            else if mainPost[indexPath.row].postType == PostType.camping.despription{
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                
                if mainPost[indexPath.row].data.isEmpty{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 30 + 5 )
                }
                else{
                    return CGSize(width: view.frame.width, height: 40 + 8 + h + 4 + 4 + 100 + 30 + 5)
                }
            }
            else{
                return .zero
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = MainPostCommentVC(currentUser: currentUser, post : mainPost[indexPath.row], target: mainPost[indexPath.row].postType)
        navigationController?.pushViewController(vc, animated: true)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
      
          if mainPost.count > 5 {
             
              if indexPath.item == mainPost.count - 1 {
                  loadMorePost { (val) in
                      
                  }
              }else{
                  self.loadMore = false
              }
          }
    }
    
}
//BuySellVCDelegate
extension CampusOnlineVC :  BuySellVCDelegate{
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
//            actionOtherUserSheet.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.actionSheetOtherUser.show(post : post , otherUser : user)
                

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
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellView)
    {
//        guard let url = URL(string: (cell.mainPost?.link)!) else {
//            return
//        }
//        UIApplication.shared.open(url)
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
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }

        
            }
        }
    }
    
    func goProfileByMention(userName: String)
    {
        if "@\(userName)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
               
            }
        }
    }
    
    
}

extension CampusOnlineVC : BuySellVCDataDelegate {
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
        }else {
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

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }

        
            }
        }
    }
    
    
}
//GADAdLoaderDelegate
extension CampusOnlineVC :  GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
      
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        self.loadMore = true
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
//MARK:- ASMainPostLaungerDelgate
extension CampusOnlineVC : ASMainPostLaungerDelgate {
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        case .editPost(_):
            guard let index = selectedIndex else { return }
            
            if mainPost[index.row].postType == PostType.buySell.despription {
                if let h = collectionview.cellForItem(at: index) as? BuyAndSellDataView {
                    let vc = EditSellBuyPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }else if let  h = collectionview.cellForItem(at: index) as? BuyAndSellView{
                    let vc = EditSellBuyPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }else if mainPost[index.row].postType == PostType.foodMe.despription{
                if let h = collectionview.cellForItem(at: index) as? FoodMeViewData {
                    let vc = EditFoodMePost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }else if let  h = collectionview.cellForItem(at: index) as? FoodMeView{
                    let vc = EditFoodMePost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
                
            }else if mainPost[index.row].postType == PostType.camping.despription{
                if let h = collectionview.cellForItem(at: index) as? CampingDataView {
                    let vc = EditCampingPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }else if let  h = collectionview.cellForItem(at: index) as? CampingView{
                    let vc = EditCampingPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
            
            
            break
        case .deletePost(_):
           
            Utilities.waitProgress(msg: "Siliniyor")
            guard let index = selectedIndex else { return }
            guard let postId = selectedPostID else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return }
            let db = Firestore.firestore().collection("main-post")
                .document("post")
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
//MARK: FoodMeVCDelegate
extension CampusOnlineVC : FoodMeVCDelegate{
    func options(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }else {
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
    
    func like(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.food_me.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.food_me.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: FoodMeView) {
        
    }
    
    func showProfile(for cell: FoodMeView) {
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
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }

        
            }
        }
    }
    
    func mapClick(for cell: FoodMeView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    
}
//MARK:FoodMeVCDataDelegate
extension CampusOnlineVC : FoodMeVCDataDelegate {
    func options(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }else {
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
    
    func like(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.food_me.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.food_me.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: FoodMeViewData) {
        
    }
    
    func mapClick(for cell: FoodMeViewData) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func showProfile(for cell: FoodMeViewData) {
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
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }

        
            }
        }
    }
    
    
}
//MARK:-CampingVCDelegate
extension CampusOnlineVC : CampingVCDelegate {
    func options(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }else {
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
    
    func like(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.camping.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.camping.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: CampingView) {
        
    }
    
    func showProfile(for cell: CampingView) {
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
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }

        
            }
        }
    }
    
    func mapClick(for cell: CampingView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    
}
//MARK:-CampingVCDataDelegate
extension CampusOnlineVC : CampingVCDataDelegate {
    func options(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }else {
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
    
    func like(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.camping.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.camping.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
            
        }
    }
    
    func comment(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        let vc = MainPostCommentVC(currentUser: currentUser, post : post, target: post.postType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: CampingDataView) {
        
    }
    
    func mapClick(for cell: CampingDataView) {
        guard let lat = cell.mainPost?.geoPoint.latitude else { return }
        guard let long = cell.mainPost?.geoPoint.longitude else { return }
        let coordinate = CLLocationCoordinate2DMake(lat, long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let name = cell.mainPost?.locationName {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func showProfile(for cell: CampingDataView) {
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
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
        
            }
        }
    }
    
    
}
