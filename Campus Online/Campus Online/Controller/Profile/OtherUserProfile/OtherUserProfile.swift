//
//  OtherUserProfile.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseFirestore
private let cellId = "id"
private let profileId = "profileId"

import FirebaseStorage
private let cellID = "cell_text"
private let cellData = "cell_data"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"
class OtherUserProfile: UIViewController  {

    var selectedIndex : IndexPath?
    var selectedPostID : String?
    
    weak var delegate : OtherUserProfileHeaderDelegate?
    lazy var isFallowing : Bool = false
    var currentUser : CurrentUser
    var otherUser : OtherUser
    var collectionview: UICollectionView!
    lazy var count : Int = 0
    lazy var homePost : Bool = true
    lazy var loadMore_HomePost : Bool = false
    lazy var isHomePost : Bool = true
    lazy var schoolPost : Bool = false
    lazy var schoolPotsDelegate : Bool = false
    lazy var loadMore_schoolPost : Bool = false
    
    lazy var coPost : Bool = false
    lazy var loadMore_coPost : Bool = false

    lazy var page_homePost : DocumentSnapshot? = nil
    lazy var page_schoolPost : DocumentSnapshot? = nil
    lazy var page_coPost : DocumentSnapshot? = nil
 
    
    lazy var lessonPostModel = [LessonPostModel]()
    
    

    private var actionOtherUserSheet : ActionSheetOtherUserLaunher
    
    
    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
//    var adUnitID =   "ca-app-pub-1362663023819993/4203883052"
    var interstitalAd : GADInterstitial!
    
    let titleLbl : UILabel = {
       let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let dissmisButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "down-arrow"), for: .normal)
        
        return btn
    }()
    let fallowBtn : UIButton = {
        let btn = UIButton(type: .system)
      
        btn.addTarget(self, action: #selector(fallowUser), for: .touchUpInside)
        return btn
        
    }()
    lazy var headerBar : UIView = {
       let v = UIView()
      
        v.addSubview(dissmisButton)
        dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(titleLbl)
        titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        v.addSubview(fallowBtn)
        fallowBtn.anchor(top: nil, left: nil, bottom: nil, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 25, heigth: 25)
        fallowBtn.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        
        return v
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        configureUI()
        configureCollectionView()
        getPost()
        interstitalAd = createAd()
   
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            if self.interstitalAd.isReady {
                self.interstitalAd.present(fromRootViewController: self)
            }
        })
        navigationItem.title = otherUser.username
        UserService.shared.checkFollowers(currentUser: currentUser, otherUser: otherUser) {[weak self] (val) in
            guard let sself = self else { return }
            sself.isFallowing = val
            if val {
                sself.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "unfollow-user").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(sself.fallowUser))
                
               

            }else{
                sself.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "follow-user").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(sself.fallowUser))
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        
        
    }
    init(currentUser : CurrentUser, otherUser : OtherUser) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -functions
    private func removeLesson (lessonName : String! ,completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: "Ders Siliniyor")
       
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!)
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                let abc = Firestore.firestore().collection(sself.currentUser.short_school)
                    .document("lesson").collection(sself.currentUser.bolum)
                    .document(lessonName!).collection("fallowers").document(sself.currentUser.username)
                abc.delete { (err) in
                    if err == nil {
                        sself.getAllPost(currentUser: sself.currentUser, lessonName: lessonName) { (val) in
                            sself.removeAllPost(postId: val, currentUser: sself.currentUser) { (_val) in
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
    private func setLike(post : LessonPostModel , completion : @escaping(Bool) ->Void){
        
        if !post.likes.contains(currentUser.uid){
            post.likes.append(self.currentUser.uid)
            post.dislike.remove(element: self.currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                db.updateData(["dislike":FieldValue.arrayRemove([self.currentUser.uid as String])]) { (err) in
                    
                    completion(true)
                }
            }
        }else{
            post.likes.remove(element: self.currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                completion(true)
            }
        }
        
      
    }
    private func setFav(post : LessonPostModel , completion : @escaping(Bool) ->Void){
        if !post.favori.contains(currentUser.uid){
            post.favori.append(currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["favori":FieldValue.arrayUnion([currentUser.uid as String])]) {[weak self] (err) in
                guard let sself = self else { return }
                //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                let dbc = Firestore.firestore().collection("user")
                    .document(sself.currentUser.uid).collection("fav-post").document(post.postId)
                let dic = ["postId":post.postId as Any] as [String:Any]
                dbc.setData(dic, merge: true) { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
            }
            
        }
        else{
            post.favori.remove(element: currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["favori":FieldValue.arrayRemove([currentUser.uid as String])]) {[weak self] (err) in
                guard let sself = self else { return }
                //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                let dbc = Firestore.firestore().collection("user")
                    .document(sself.currentUser.uid).collection("fav-post").document(post.postId)
                dbc.delete { (err) in
                    if err == nil {
                        completion(true)
                    }
                }
                
            }
            
        }
    }
    
    private func setDislike(post : LessonPostModel , completion : @escaping(Bool)->Void){
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school).document("lesson-post").collection("post").document(post.postId)
            db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                if err == nil {
                    db.updateData(["likes":FieldValue.arrayRemove([self.currentUser.uid as String])]) { (err) in
                    
                    completion(true)
                    }
                }
            }
        }else{
            post.dislike.remove(element: self.currentUser.uid)
            collectionview.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                completion(true)
            }
        }
    }
    fileprivate func getPost(){
            isHomePost = true
            lessonPostModel = [LessonPostModel]()
            loadMore_HomePost = true
            collectionview.reloadData()
            
        fetchLessonPost(otherUser: self.otherUser) {[weak self] (post) in
            self?.lessonPostModel = post
//            self?.fetchAds()
                if self?.lessonPostModel.count ?? -1 > 0{
                    self?.collectionview.refreshControl?.endRefreshing()
                    if  let time_e = self?.lessonPostModel[(self?.lessonPostModel.count)! - 1].postTime{
                       
                        self?.lessonPostModel.sort(by: { (post, post1) -> Bool in
                            return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                        })
                        self?.collectionview.reloadData()
                       
                    }
                }else{
                   
                    self?.collectionview.reloadData()
                }
        }
    }
    
    private func loadMorePost(completion: @escaping(Bool) ->Void){
     
        
        guard let pagee = page_homePost else {
            loadMore_HomePost = false
            collectionview.reloadData()
            completion(false)
            return }
        let  db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("my-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: pagee)
        db.getDocuments { [self] (snapshot, err ) in
            guard let snap = snapshot else { return }
            if let err = err {
                print("\(err.localizedDescription)")
            }else if snap.isEmpty {
                self.loadMore_HomePost = false
                collectionview.reloadData()
                completion(false)
            
            }else{
                for item in snap.documents{
                    let db = Firestore.firestore().collection(otherUser.short_school)
                        .document("lesson-post").collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else { return }
                            if snapp.exists
                            {
                                
                                self.lessonPostModel.append(LessonPostModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = self.lessonPostModel[(self.lessonPostModel.count) - 1].postTime{
                                
                                    self.lessonPostModel.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    self.loadMore_schoolPost = true
                                    self.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                               
                          
                                
                            }else{
                                
                                let deleteDb = Firestore.firestore().collection("user")
                                    .document(otherUser.uid).collection("lesson-post").document(snapp.documentID)
                                deleteDb.delete()
                                
                            }
                        }
                        
                    }
                   
                    page_homePost = snap.documents.last
                    
                  
                    
                }
//                self.fetchAds()
//                self.collectionview.reloadData()
                
//                loadMore = false
                
            }
        }
    }
    private func getOtherUser(userId : String , completion : @escaping(OtherUser)->Void){
        let db = Firestore.firestore().collection("user")
            .document(userId)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    Utilities.dismissProgress()
                    return }
                if snap.exists {
                    completion(OtherUser.init(dic: docSnap!.data()!))
                }
            }
        }
    }
    
    //MARK: - lesson post
    func fetchLessonPost(otherUser : OtherUser, completion : @escaping([LessonPostModel])->Void){

        var post = [LessonPostModel]()
      let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("my-post").limit(to: 6).order(by: "postId", descending: true)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    
                    for postId in snap.documents {
                        let db = Firestore.firestore().collection(otherUser.short_school)
                            .document("lesson-post").collection("post").document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists
                                {
                                    post.append(LessonPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                  
                  
                                }else{
                                    
                                    let deleteDb = Firestore.firestore().collection("user")
                                        .document(otherUser.uid).collection("my-post").document(postId.documentID)
                                    deleteDb.delete()
                                }
                                completion(post)
                            }
                        }
                        
                    }
                    
                    self.page_homePost = snap.documents.last
//                    self.fetchAds()
                    self.loadMore_HomePost = true
                   
                }
                
            }
        }
        
    }
    
    private func createAd() ->GADInterstitial {
        let ad = GADInterstitial(adUnitID: adUnitID)
        ad.delegate = self
        ad.load(GADRequest())
        return ad
    }
    
    func configureUI(){
         view.backgroundColor = .white
         view.addSubview(headerBar)
        headerBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 60)
         dissmisButton.addTarget(self, action: #selector(dissmis), for: .touchUpInside)
        titleLbl.text = otherUser.username
     }
    
    func configureCollectionView(){
             let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
             collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
//        collectionview.contentInsetAdjustmentBehavior = .never
             collectionview.dataSource = self
             collectionview.delegate = self
             collectionview.backgroundColor = .white
             collectionview.register(ProfileCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: cellData)
        collectionview.register(OtherUserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileId)
             view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
         }
    
     @objc func dissmis(){
         self.dismiss(animated: true, completion: nil)
     }
    
    //MARK:- selector
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func fallowUser(){
        if isFallowing{
            UserService.shared.unFollowUser(currentUser: currentUser, otherUser: otherUser) {[weak self] (_) in
                guard let sself = self else { return }
                sself.isFallowing = false
                sself.fallowBtn.setImage(#imageLiteral(resourceName: "follow-user").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }else{
            UserService.shared.fallowUser(currentUser: currentUser, otherUser: otherUser) {[weak self] (_) in
                guard let sself = self else { return }
                sself.isFallowing = true
                sself.fallowBtn.setImage(#imageLiteral(resourceName: "unfollow-user").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    
    
    
}
extension OtherUserProfile : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if homePost
        {
        count = lessonPostModel.count
        }else if schoolPost{
            
        }else if coPost {
            
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if homePost
        {
            schoolPotsDelegate = true
           
            
            if lessonPostModel[indexPath.row].data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewPostHomeVC
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPostModel[indexPath.row]
                
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NewPostHomeVCData
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                
                cell.filterView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPostModel[indexPath.row]
                
                return cell
            }
            
            
        }else if schoolPost{
            
        }else if coPost {
            
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.backgroundColor = .red
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if homePost
        {
            if lessonPostModel[indexPath.row].text == nil {
                return .zero
            }
            let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            
            if lessonPostModel[indexPath.row].data.isEmpty{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
            }
            else{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
            }
        }else if schoolPost{
            
        }else if coPost {
            
        }
        return CGSize(width: self.view.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 246)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileId, for: indexPath) as! OtherUserProfileHeader
        header.delegate = self
        header.controller = self

        header.helps = helps(otherUser: otherUser, currentUser: currentUser, option: OtherUserFilterVM(target: TargetFilterView.otherUser.description, otherUser: otherUser, currentUser: currentUser))
        let count = helps(otherUser: otherUser, currentUser: currentUser, option: OtherUserFilterVM(target: TargetFilterView.otherUser.description, otherUser: otherUser, currentUser: currentUser)).option.options.count
        header.underLine.frame = CGRect(x: 0, y: 235, width: Int(header.frame.width) / count, height: 2)
        return header
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isHomePost {
            if lessonPostModel.count > 5 {
                if indexPath.item == lessonPostModel.count - 1 {
                    loadMorePost { (val) in
                        
                    }
                }else{
                    self.loadMore_HomePost = false
                }
            }
        }
    }
    
}

extension OtherUserProfile : GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("dismiss")
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("failed")
    }
    
}
struct helps {
    let otherUser : OtherUser
    let currentUser : CurrentUser
    let option : OtherUserFilterVM
}


extension OtherUserProfile : NewPostHomeVCDataDelegate {
    func options(for cell: NewPostHomeVCData) {
       print("click option")
        if schoolPotsDelegate{
            guard  let post = cell.lessonPostModel else {
                return
            }
             
                Utilities.waitProgress(msg: nil)
                actionOtherUserSheet.delegate = self
                guard let  index = collectionview.indexPath(for: cell) else { return }
                selectedIndex = index
                selectedPostID = lessonPostModel[index.row].postId
                getOtherUser(userId: post.senderUid) {[weak self] (user) in
                    guard let sself = self else { return }
                    Utilities.dismissProgress()
                    sself.actionOtherUserSheet.show(post: post, otherUser: user)
                    
                }
            
        }
    }
    
    func like(for cell: NewPostHomeVCData) {
        
        guard let post = cell.lessonPostModel else { return }
        setLike(post: post) { (_) in }
    }
    
    func dislike(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        setDislike(post: post) { (_) in }
    }
    
    func fav(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        setFav(post: post) { (_) in }
    }
    
    func comment(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        let vc = CommentVC(currentUser: currentUser, post : post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        
    }
    
    func showProfile(for cell: NewPostHomeVCData) {
        
    }
    
    func goProfileByMention(userName: String) {
        if "@\(userName)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen

                sself.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
}


extension OtherUserProfile : NewPostHomeVCDelegate{
    func clickMention(username: String) {
        if "@\(username)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen

                sself.present(vc, animated: true, completion: nil)
            }
        }
    }
    func showProfile(for cell: NewPostHomeVC) {
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
        print("click option")
         if schoolPotsDelegate{
             
            
                 Utilities.waitProgress(msg: nil)
                 actionOtherUserSheet.delegate = self
                 guard let  index = collectionview.indexPath(for: cell) else { return }
                 selectedIndex = index
                 selectedPostID = lessonPostModel[index.row].postId
                 getOtherUser(userId: post.senderUid) {[weak self] (user) in
                     guard let sself = self else { return }
                     Utilities.dismissProgress()
                     sself.actionOtherUserSheet.show(post: post, otherUser: user)
                     
                 }
             
         }
        
    }
    
    func like(for cell: NewPostHomeVC) {
        
        
        guard let post = cell.lessonPostModel else { return }
        setLike(post: post) { (_) in }
    }
    
    func dislike(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        setDislike(post: post) { (_) in }
    }
    
    func fav(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        setFav(post: post) { (_) in }
    }
    
    func comment(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        let vc = CommentVC(currentUser: currentUser, post : post)
        navigationController?.pushViewController(vc, animated: true)
    }
   
   
    
}

extension OtherUserProfile : OtherUserProfileHeaderDelegate {
    func getMajorPost() {
        homePost = true
        schoolPost = false
        coPost = false
       
        isHomePost = true
        getPost()
        
       
    }
    
    func getSchoolPost() {
        homePost = false
        schoolPost = true
        coPost = false

    }
    
    func getCoPost() {
        homePost = false
        schoolPost = false
        coPost = true

    }
    
    
}
extension OtherUserProfile : ActionSheetOtherUserLauncherDelegate {
    func didSelect(option: ActionSheetOtherUserOptions)
    {
        switch option {
        
        case .fallowUser(_):
            if schoolPotsDelegate {
                print("called")
                Utilities.waitProgress(msg: "")
                guard let index = selectedIndex else {
                    Utilities.dismissProgress()
                    return }
                UserService.shared.fetchOtherUser(uid: lessonPostModel[index.row].senderUid) {[weak self] (user) in
                    guard let sself = self else {
                        Utilities.dismissProgress()
                        return}
                    let vc = OtherUserProfile(currentUser : sself.currentUser,otherUser : user)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    sself.present(controller, animated: true) {
                        Utilities.dismissProgress()
                    }
                }
            }
            break
        case .slientUser(_):
            
            break
        case .deleteLesson(_):
           
        break
        case .slientLesson(_):
            
            break
        case .slientPost(_):
           
            break
        case .reportPost(_):
           
            break
        case .reportUser(_):
           
            break
        }
    }
    
    
}
