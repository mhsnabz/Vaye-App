//
//  Home_Cell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
private let cellID = "cell_text"
private let cellData = "cell_data"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"
private let emptyCell = "empty_cell"
import GoogleMobileAds
import SDWebImage
import FirebaseStorage

class Home_Cell: UICollectionViewCell {
   
    
    //MARK: -variables
    var page : DocumentSnapshot? = nil
    var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    /// The native ad view that is being presented.
    var nativeAdView: GADUnifiedNativeAdView!
    weak var notificaitonListener : ListenerRegistration?

    /// The ad unit ID.
//    let adUnitID = "ca-app-pub-3940256099942544/2521693316"  // "ca-app-pub-3940256099942544/3986624511"
    var collectionview: UICollectionView!
    weak var rootController : HOMEVC?
    let adUnitID = "ca-app-pub-1362663023819993/1801312504"
    var nativeAd: GADUnifiedNativeAd?
    var lessonPost = [LessonPostModel]()
    var refresher = UIRefreshControl()
    var actionSheet : ActionSheetHomeLauncher?{
        didSet{
            collectionview.reloadData()
        }
    }
    var actionOtherUserSheet : ActionSheetOtherUserLaunher?{
        didSet{
            collectionview.reloadData()
        }
    }
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    var currentUser : CurrentUser?{
        didSet{
            getPost()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:--functions
    fileprivate func configureUI(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom:bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
      
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: cellData)
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.register(EmptyCell.self, forCellWithReuseIdentifier: emptyCell)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
    
        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        getPost()
    }
    
    //MARK:--functions
    
    //MARK: -functions
    private func removeLesson (lessonName : String!,currentUser : CurrentUser ,completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: "Ders Siliniyor")
       
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!)
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                let abc = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson").collection(currentUser.bolum)
                    .document(lessonName!).collection("fallowers").document(currentUser.username)
                abc.delete { (err) in
                    if err == nil {
                        sself.getAllPost(currentUser: currentUser, lessonName: lessonName) { (val) in
                            sself.removeAllPost(postId: val, currentUser: currentUser) { (_val) in
                                if _val{
                                    completion(true)
                                    Utilities.succesProgress(msg : "Ders Silindi")
                                    sself.collectionview.reloadData()
                                }else{
                                    completion(false)
                                  Utilities.errorProgress(msg: "Ders Silinemedi")
                                }
                            }
                        }
                        
                    }else{
                        completion(false)
                        Utilities.errorProgress(msg: "Ders Silinemedi")
                    }
                }
            }else{
                completion(false)
                Utilities.errorProgress(msg: "Ders Silinemedi")
            }
        }
    }
    private func removeAllPost(postId : [String] , currentUser : CurrentUser , completion : @escaping(Bool) -> Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson-post/1599800825321
        for item in postId {
           let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").document(item)
            db.delete { (err) in
                if err == nil {
                    completion(true)
                    let dbFav = Firestore.firestore().collection("user")
                        .document(currentUser.uid).collection("fav-post").document(item)
                    dbFav.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snap = docSnap else {
                                completion(true)
                                return }
                            if snap.exists{
                                dbFav.delete()
                            }
                        }
                        completion(true)
                    }
                    
                }else{
                    completion(false)
                }
            }
        }
        
    }
    private func getAllPost(currentUser : CurrentUser , lessonName : String , completion : @escaping([String]) ->Void){
         //İSTE/lesson-post/post/1599800825321
         var postId = [String]()
         let db = Firestore.firestore().collection(currentUser.short_school)
             .document("lesson-post").collection("post").whereField("lessonName", isEqualTo: lessonName)
         db.getDocuments { (querySnap, err) in
             if err == nil {
                 guard let snap = querySnap else {
                     completion([])
                     return }
                 for doc in snap.documents {
                     postId.append(doc.documentID)
                 }
                 completion(postId)
             }
         }
     }
    
    fileprivate func getPost(){
          
            lessonPost = [LessonPostModel]()
            loadMore = true
            collectionview.reloadData()
        guard let currentUser  = currentUser else { return }
            fetchLessonPost(currentUser: currentUser) {[weak self] (post) in
            self?.lessonPost = post
//            self?.fetch Ads()
                if self?.lessonPost.count ?? -1 > 0{
                    self?.collectionview.refreshControl?.endRefreshing()
                    if  let time_e = self?.lessonPost[(self?.lessonPost.count)! - 1].postTime{
                        self?.time = self?.lessonPost[(self?.lessonPost.count)! - 1].postTime
                        self?.lessonPost.sort(by: { (post, post1) -> Bool in
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
    func fetchLessonPost(currentUser : CurrentUser, completion : @escaping([LessonPostModel])->Void){
        collectionview.refreshControl?.beginRefreshing()
        var post = [LessonPostModel]()
        //  let db : Query!

        let  db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").limit(to: 5).order(by: "postId", descending: true)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    
                    for postId in snap.documents {
                        let db = Firestore.firestore().collection(currentUser.short_school)
                            .document("lesson-post").collection("post").document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists
                                {
                                    post.append(LessonPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                  
                  
                                }else{
                                    
                                    let deleteDb = Firestore.firestore().collection("user")
                                        .document(currentUser.uid).collection("lesson-post").document(postId.documentID)
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
        let  db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: pagee)
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
                    let db = Firestore.firestore().collection(currentUser.short_school)
                        .document("lesson-post").collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else { return }
                            if snapp.exists
                            {
                                
                                self.lessonPost.append(LessonPostModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = self.lessonPost[(self.lessonPost.count) - 1].postTime{
                                    self.time = self.lessonPost[(self.lessonPost.count) - 1].postTime
                                    self.lessonPost.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    self.loadMore = true
                                    self.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                               
                          
                                
                            }else{
                                
                                let deleteDb = Firestore.firestore().collection("user")
                                    .document(currentUser.uid).collection("lesson-post").document(snapp.documentID)
                                deleteDb.delete()
                                
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
  
    //MARK:-selectors
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
        
    }
}
extension Home_Cell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonPost.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if lessonPost[indexPath.row].postId == nil {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
            cell.nativeAd = lessonPost[indexPath.row].nativeAd
            return cell
        }
        else if lessonPost[indexPath.row].empty == "empty"{
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: emptyCell, for: indexPath) as! EmptyCell
          
            return cell
        }
        else{
            if lessonPost[indexPath.row].data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewPostHomeVC
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPost[indexPath.row]
                
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NewPostHomeVCData
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: frame.width - 78, height: h + 4)
                cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: frame.width - 78, height: 200)
                cell.onClickListener = self
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPost[indexPath.row]
                
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
        
        if lessonPost[indexPath.row].postId == nil {
            return CGSize(width: frame.width, height: 409)
            
        }
        else if lessonPost[indexPath.row].empty == "empty"{
            return .zero
        }
        else{
            
            if lessonPost[indexPath.row].text == nil {
                return .zero
            }
            let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            
            if lessonPost[indexPath.row].data.isEmpty{
                return CGSize(width: frame.width, height: 60 + 8 + h + 4 + 4 + 30)
            }
            else{
               
                return CGSize(width: frame.width, height: 60 + 8 + h + 4 + 4 + 200 + 30)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      
    
        if lessonPost.count > 5 {
           
            if indexPath.item == lessonPost.count - 1 {
                loadMorePost { (val) in
                    
                }
            }else{
                self.loadMore = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: lessonPost[indexPath.row].postId, lessonPost: lessonPost[indexPath.row], noticesPost: nil, mainPost: nil)
        self.rootController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension Home_Cell  : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
      
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        self.lessonPost.append(LessonPostModel.init(empty: "empty", postId: "empty"))
        self.loadMore = true
        self.collectionview.reloadData()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        self.nativeAd = nativeAd
        if lessonPost.count > 0{
            if  let time_e = self.lessonPost[(self.lessonPost.count) - 1].postTime{
                self.lessonPost.sort(by: { (post, post1) -> Bool in
                    
                    return post.postTime?.dateValue() ?? time_e.dateValue()   > post1.postTime?.dateValue() ??  time_e.dateValue()
                })
                
                self.lessonPost.append(LessonPostModel.init(nativeAd: nativeAd , postTime : self.lessonPost[(self.lessonPost.count) - 1].postTime!))
            }
        }
        self.loadMore = false
        self.collectionview.reloadData()
    }
}



extension Home_Cell : NewPostHomeVCDataDelegate {
    
    
    func showProfile(for cell: NewPostHomeVCData) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        guard let currentUser = currentUser else { return }
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser:currentUser, width: 285)
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
    func options(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        guard let actionSheet  = actionSheet else { return}
        guard let actionOtherUserSheet = actionOtherUserSheet else { return }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPost[index.row].postId
        }else{
            Utilities.waitProgress(msg: nil)
            actionOtherUserSheet.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
      
                Utilities.dismissProgress()
                actionOtherUserSheet.show(post: post, otherUser: user)
                
            }
            
            
        }
        
    }
    
    func like(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        PostService.shared.setLike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
      
        
               
    }
    
    func dislike(for cell: NewPostHomeVCData) {
           guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        PostService.shared.setDislike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    
    }
    
    func fav(for cell: NewPostHomeVCData) {
        
        guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        PostService.shared.setFav(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
        
    }
    
    func comment(for cell: NewPostHomeVCData) {
        guard let currentUser = currentUser else { return }
        guard let post = cell.lessonPostModel else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: post, noticesPost: nil, mainPost: nil)
        rootController?.navigationController?.pushViewController(vc, animated: true)
            
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
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
extension Home_Cell : ActionSheetOtherUserLauncherDelegate {
    func didSelect(option: ActionSheetOtherUserOptions) {
        switch option {
        case .fallowUser(_):
            print("called")
            Utilities.waitProgress(msg: "")
            guard let currentUser = currentUser else { return }
            guard let index = selectedIndex else {
                Utilities.dismissProgress()
                return }
            UserService.shared.fetchOtherUser(uid: lessonPost[index.row].senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return}
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
    
            break
        case .slientUser(_):
            
            break
        case .deleteLesson(_):
            guard let index = selectedIndex else {
            Utilities.dismissProgress()
            return }
            guard let currentUser = currentUser else { return }
            removeLesson(lessonName: lessonPost[index.row].lessonName, currentUser: currentUser) { (_) in
                self.getPost()
            }
            break
        case .slientLesson(_):
            break
        case .slientPost(_):
            break
        case .reportPost(_):
            guard let index = selectedIndex else {
            Utilities.dismissProgress()
            return }
            guard let currentUser = currentUser else { return }
            let vc = ReportingVC(target: ReportTarget.homePost.description, currentUser: currentUser, otherUser: lessonPost[index.row].senderUid, postId: lessonPost[index.row].postId, reportType: ReportType.reportPost.description)
           
            rootController?.navigationController?.pushViewController(vc, animated: true)
            break
        case .reportUser(_):
            guard let index = selectedIndex else {
            Utilities.dismissProgress()
            return }
            guard let currentUser = currentUser else { return }
            let vc = ReportingVC(target: ReportTarget.homePost.description, currentUser: currentUser, otherUser: lessonPost[index.row].senderUid, postId: lessonPost[index.row].postId, reportType: ReportType.reportUser.description)
           
            rootController?.navigationController?.pushViewController(vc, animated: true)
            break
     
        }
    }
    
    
}
extension Home_Cell : ActionSheetHomeLauncherDelegate {
    func didSelect(option: ActionSheetHomeOptions) {
        switch option {
        case .editPost(_):
            guard let index = selectedIndex else { return }
            guard let currentUser = currentUser else { return }
            if let h = collectionview.cellForItem(at: index) as? NewPostHomeVCData {
                let vc = StudentEditPost(currentUser: currentUser , post : lessonPost[index.row] , heigth : h.msgText.frame.height )
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
            }else if let  h = collectionview.cellForItem(at: index) as? NewPostHomeVC{
                let vc = StudentEditPost(currentUser: currentUser , post : lessonPost[index.row] , heigth : h.msgText.frame.height )
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
            }
            
            
        case .deletePost(_):
            guard let currentUser = currentUser else { return }
            Utilities.waitProgress(msg: "Siliniyor")
            guard let index = selectedIndex else { return }
            guard let postId = selectedPostID else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return }
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(postId)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    sself.deleteToStorage(data: sself.lessonPost[index.row].data, postId: postId) { (_val) in
                        if (_val){
                            //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama/lesson-post
                            let db = Firestore.firestore().collection(currentUser.short_school)
                                .document("lesson")
                                .collection(currentUser.bolum)
                                .document(sself.lessonPost[index.row].lessonName)
                                .collection("lesson-post")
                                .document(postId)
                            db.delete { (err) in
                                if err == nil {
                                    Utilities.succesProgress(msg: "Silindi")
                                    
                                }
                            }
                            
                            
                        
                        }
                    }
                    
                }else{
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        case .slientPost(_):
            print("slient")
        }
    }
    private func deleteToStorage(data : [String], postId : String , completion : @escaping(Bool) -> Void){
        if data.count == 0{
            completion(true)
            return
        }
        for item in data{
            let ref = Storage.storage().reference(forURL: item)
            ref.delete { (err) in
                completion(true)
            }
        }
    }
}
extension Home_Cell : NewPostHomeVCDelegate {
    
    
    func clickMention(username: String) {
        guard let currentUser = currentUser else { return }
        if "@\(username)" == currentUser.username {
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
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
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
    func showProfile(for cell: NewPostHomeVC) {
        guard  let post = cell.lessonPostModel else {
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
//            self.navigationController?.pushViewController(vc, animated: true)
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
    func linkClick(for cell: NewPostHomeVC) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func options(for cell: NewPostHomeVC) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        guard let currentUser = currentUser else { return }
        guard let actionSheet = actionSheet else { return }
        guard let actionOtherUserSheet = actionOtherUserSheet else { return }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPost[index.row].postId
        }else{
            Utilities.waitProgress(msg: nil)
            actionOtherUserSheet.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {(user) in
              
                Utilities.dismissProgress()
                actionOtherUserSheet.show(post: post, otherUser: user)
                
            }
        }
        
    }
    
    func like(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        PostService.shared.setLike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    }
    
    func dislike(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        guard let currentUser = currentUser else {
            return
        }
        PostService.shared.setDislike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    }
    
    func fav(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        
        guard let currentUser = currentUser else { return }
        PostService.shared.setFav(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    }
    
    func comment(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        guard let currentUser = currentUser else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: post, noticesPost: nil, mainPost: nil)
        rootController?.navigationController?.pushViewController(vc, animated: true)
    }
    
   
}
extension Home_Cell : ShowAllDatas {
    func onClickListener(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }

        guard let currentUser = currentUser else { return }
        guard let data = post.data else { return }
        let vc = AllDatasVC(arrayListUrl: data, currentUser: currentUser)
        self.rootController?.modalPresentationStyle = .fullScreen
        self.rootController?.present(vc, animated: true, completion: nil)
        
    }
    
    
}
