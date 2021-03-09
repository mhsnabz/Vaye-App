//
//  BuySellCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 16.12.2020.
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

extension BuySell_Cell : ShowBuySellData{
    func onClickListener(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }

        guard let currentUser = currentUser else { return }
        guard let data = post.data else { return }
        let vc = AllDatasVC(arrayListUrl: data, currentUser: currentUser)
        self.rootController?.modalPresentationStyle = .fullScreen
        self.rootController?.present(vc, animated: true, completion: nil)
    }
    
    
}

class BuySell_Cell: UICollectionViewCell {
    var currentUser : CurrentUser?{
        didSet{
            getPost()
        }
    }
    weak var delegate : CoControllerDelegate?
    var isMenuOpen : Bool = false
    lazy var mainPost = [MainPostModel]()
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    weak  var nativeAd: GADUnifiedNativeAd?
    lazy var followers = [String]()
    var collectionview: UICollectionView!
    lazy  var refresher = UIRefreshControl()
    lazy  var page : DocumentSnapshot? = nil
    lazy  var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    var nativeAdView: GADUnifiedNativeAdView!
    
    var actionSheetCurrentUser : ActionSheetMainPost?{
        didSet{
            collectionview.reloadData()
        }
    }
    var actionSheetOtherUser : ASMainPostOtherUser?{
        didSet{
            collectionview.reloadData()
        }
    }
    let adUnitID =  "ca-app-pub-3940256099942544/3986624511"
    
    weak var rootController : VayeApp?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:--func
    fileprivate func configureUI(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
      addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(BuyAndSellView.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(BuyAndSellDataView.self , forCellWithReuseIdentifier: cellData)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        collectionview.refreshControl?.beginRefreshing()
   
        
    }
    fileprivate func  getPost(){
        guard let currentUser = currentUser else { return }
        mainPost = [MainPostModel]()
        loadMore = true
        collectionview.reloadData()
        
        fetchMainPost(currentUser: currentUser) {[weak self] (post) in
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
    
    private func loadMorePost(completion: @escaping(Bool) ->Void){
        guard let currentUser = currentUser else { return }
        
        guard let pagee = page else {
            loadMore = false
            collectionview.reloadData()
            completion(false)
            return }
        let  db =  Firestore.firestore().collection(currentUser.short_school)
            .document("main-post")
            .collection("buy-sell").limit(to: 5)
            .order(by: "postId",descending: true).start(afterDocument: pagee)
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
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: rootController,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
    }
}
extension BuySell_Cell  : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
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
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: frame.width - 78, height: h + 4)
                cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
                cell.bottomBar.anchor(top: nil, left: cell.priceLbl.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.mainPost = mainPost[indexPath.row]
                
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! BuyAndSellDataView
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: frame.width - 78, height: h + 4)
                cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
                
                cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: frame.width - 78, height: 200)
                cell.onClickListener = self
                
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
            return CGSize(width: frame.width, height: 50)
        }else{
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if mainPost[indexPath.row].postId == nil {
            return CGSize(width: frame.width, height: 409)
        }else{
            
            if mainPost[indexPath.row].text == nil {
                return .zero
            }
            let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            
            if mainPost[indexPath.row].data.isEmpty{
                return CGSize(width: frame.width, height: 40 + 8 + h + 4 + 4 + 50 + 5 )
            }
            else{
                return CGSize(width: frame.width, height: 40 + 8 + h + 4 + 4 + 200 + 50 + 5)
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
        guard let currentUser = currentUser else { return }
        
        let vc = MajorPostCommentController(currentUser: currentUser, postId: mainPost[indexPath.row].postId, lessonPost: nil, noticesPost: nil, mainPost: mainPost[indexPath.row])
        self.rootController?.navigationController?.pushViewController(vc, animated: true)
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
//MARK: - GADAdLoaderDelegate
extension BuySell_Cell : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
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
extension BuySell_Cell : BuySellVCDelegate{
    func options(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        guard let actionSheetOtherUser = actionSheetOtherUser  else { return }
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
            actionSheetOtherUser.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
                
                Utilities.dismissProgress()
                actionSheetOtherUser.show(post: post, otherUser: user)
                
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
        guard let currentUser = currentUser else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    
    
    func comment(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.rootController?.navigationController?.pushViewController(vc, animated: true)
        rootController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: BuyAndSellView) {
  
    }
    
    func showProfile(for cell: BuyAndSellView) {
        guard  let post = cell.mainPost else {
            return
        }
        guard let currentUser = currentUser else { return }
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: currentUser, width: 285)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: currentUser, width: 235)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
               
                
                
            }
        }
    }
    
    func goProfileByMention(userName: String) {
        guard let currentUser = currentUser else { return }
        if "@\(userName)" == currentUser.username {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: currentUser, width: 285)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: currentUser, width: 235)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
}
extension BuySell_Cell : BuySellVCDataDelegate {
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
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        guard let actionSheetOtherUser = actionSheetOtherUser else { return }
        guard let currentUser = currentUser else { return }
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
            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
       
                Utilities.dismissProgress()
               actionSheetOtherUser.show(post: post, otherUser: user)
                
            }
        }
    }
    
    func like(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }
        MainPostService.shared.setLikePost(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }
        MainPostService.shared.setDislike(target: MainPostLikeTarget.buy_sell.description, collectionview: self.collectionview, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    func comment(for cell: BuyAndSellDataView) {
        guard let post = cell.mainPost else { return }
        guard let currentUser = currentUser else { return }

        
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: nil, mainPost: post)
        self.rootController?.navigationController?.pushViewController(vc, animated: true)
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
        guard let currentUser = currentUser else { return }
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: currentUser, width: 285)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser:currentUser, width: 235)
                    self.rootController?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            //            vc.modalPresentationStyle = .fullScreen
            //            present(vc, animated: true, completion: nil)
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
                
            }
        }
    }
    
    
}
//MARK: -ASMainPostLaungerDelgate
extension BuySell_Cell : ASMainPostLaungerDelgate {
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        case .editPost(_):
            guard let index = selectedIndex else {
                return }
            guard let currentUser = currentUser else { return }
            if let h = collectionview.cellForItem(at: index) as? BuyAndSellDataView {
                let vc = EditSellBuyPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
            }else if let  h = collectionview.cellForItem(at: index) as? BuyAndSellView{
                let vc = EditSellBuyPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
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
extension BuySell_Cell : ASMainOtherUserDelegate {
    func didSelect(option: ASMainPostOtherUserOptions) {
        switch option {
        
        case .fallowUser(_):
            break
        case .slientUser(_):
            break
        
        case .reportPost(_):
            guard let index = selectedIndex else { return }
            guard let currentUser = currentUser else { return }
            let vc = ReportingVC(target: ReportTarget.buySellPost.description, currentUser: currentUser, otherUser: mainPost[index.row].senderUid
                                 , postId: mainPost[index.row].postId, reportType: ReportType.reportPost.description)
            self.rootController?.navigationController?.pushViewController(vc, animated: true)
            break
        case .reportUser(_):
            guard let index = selectedIndex else { return }
            guard let currentUser = currentUser else { return }
            let vc = ReportingVC(target: ReportTarget.buySellPost.description, currentUser: currentUser, otherUser: mainPost[index.row].senderUid
                                 , postId: mainPost[index.row].postId, reportType: ReportType.reportUser.description)
            self.rootController?.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    
    
}
