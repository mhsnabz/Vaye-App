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
import MapKit
import CoreLocation
import FirebaseStorage
import SDWebImage
private let cellId = "id"
private let profileId = "profileId"
private let cell_notices_id = "cell_notices_id"
private let cell_notices_data_id = "cell_notices_data_id"
private let home_post_id = "home_post_id"
private let home_post_data_id = "home_post_data_id"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"
private let emptyCell = "empty_cell"

private let cellID = "cellID"
private let cellData = "cellData"

private let cell_foodme_id = "cell_food_me_id"
private let cell_foodme_data_id = "cell_foodme_data_id"

private let cell_camp_id = "cell_camp_id"
private let cell_camp_data_id = "cell_camp_data_id"

class OtherUserProfile: UIViewController  {
    lazy var lessonPostModel = [LessonPostModel]()
    lazy var mainPost = [MainPostModel]()
    lazy var favPost = [LessonPostModel]()
    lazy var schoolPost = [NoticesMainModel]()
    
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    var time : Timestamp!
    var adLoader: GADAdLoader!
    var nativeAd: GADUnifiedNativeAd?
    //MARK:-DocumentSnapshot
    var home_page : DocumentSnapshot? = nil
    var vaye_page : DocumentSnapshot? = nil
    var fav_page : DocumentSnapshot? = nil
    var schoolPost_page : DocumentSnapshot? = nil
    //MARK: - variables
    var width : CGFloat
    var profileModel : ProfileModel
    var controller : UIViewController!
    lazy var count : Int = 0
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    weak var profileHeaderDelegate : ProfileHeaderMenuBarDelegate?
    private  var actionSheet : ActionSheetHomeLauncher
    private var actionOtherUserSheet : ActionSheetOtherUserLaunher
    private var actionSheetCurrentUser : ASNoticesPostCurrentUserLaunher
    let native_adUnitID =  "ca-app-pub-3940256099942544/3986624511"
    //MARK:-post filter val
    var isHomePost : Bool = false
    var isSchoolPost : Bool = false
    var isVayeAppPost : Bool = false
    var isFavPost : Bool = false
    
    var isLoadMoreHomePost : Bool = false
    var isLoadMoreSchoolPost : Bool = false
    var isLoadMoreVayeAppPost : Bool = false
    var isLoadMoreFavPost : Bool = false
  
    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
    //    var adUnitID =   "ca-app-pub-1362663023819993/4203883052"
    var interstitalAd : GADInterstitial!
 
    private var actionSheetOtherUser : ASMainPostOtherUser

    var otherUser : OtherUser
    //MARK:-propeties
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.6
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .darkGray
        return image
    }()
    lazy var followBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setTitle("Profilini Düzenle", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        return btn
    }()
    lazy var imageSections : UIView = {
        let view = UIView()
         view.addSubview(profileImage)
         profileImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 65, heigth: 65)
        
         profileImage.layer.cornerRadius = 65 / 2
       
         
         view.addSubview(followBtn)
         followBtn.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 50, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
         followBtn.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
       
//         followBtn.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
         return view

    }()
    
    
    let name : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 16)
        lbl.textColor = .black

        return lbl
    }()
    let major : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)

        lbl.textColor = .darkGray
        return lbl
    }()
    let school : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
   
        lbl.textColor = .darkGray
        return lbl
    }()
    let number : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.text = "121503031"
        lbl.textColor = .darkGray
        return lbl
    }()
    lazy var aboutSection : UIView = {
       let v = UIView()
        let stack = UIStackView(arrangedSubviews: [name,number,school,major,number])
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .leading
        v.addSubview(stack)
        stack.anchor(top: nil, left: v.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
        return v
    }()
    var followers : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    var following : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    let fallowerLabel : UILabel = {
        let lbl = UILabel()
       
        return lbl
    }()
   
    let fallowingLabel : UILabel = {
        let lbl = UILabel()

        return lbl
    }()
    
    
    let github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    let linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goLinkedIn), for: .touchUpInside)
        return btn
    }()
    
    let twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goTwitter), for: .touchUpInside)
        return btn
    }()
    let instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goInstagram), for: .touchUpInside)
        return btn
    }()
    
    lazy var stackView : UIStackView = {
        let stackSocial = UIStackView(arrangedSubviews: [github,linkedin,twitter,instagram])
        stackSocial.axis = .horizontal
        stackSocial.distribution = .fillEqually
        stackSocial.spacing = 20
        return stackSocial
    }()
    
    lazy var stackFallow : UIStackView = {
        let stackFallow = UIStackView(arrangedSubviews: [fallowingLabel,fallowerLabel])
        stackFallow.axis = .horizontal
        stackFallow.spacing = 4
        stackFallow.alignment = .leading
        return stackFallow
    }()
    lazy var menuBar  : MenuBar = {
       let v = MenuBar()

        return v
    }()
    lazy var headerView : UIView = {
       let v = UIView()
        v.backgroundColor = .white
        v.addSubview(profileImage)
     
         v.addSubview(followBtn)
         followBtn.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: v.rightAnchor, marginTop: 0, marginLeft: 50, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        followBtn.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        v.addSubview(aboutSection)
        aboutSection.anchor(top: profileImage.bottomAnchor, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
       
        v.addSubview(stackFallow)
        stackFallow.anchor(top: aboutSection.bottomAnchor, left: aboutSection.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 12, marginBottom: 0, marginRigth: 20, width: 0, heigth: 20)
        v.addSubview(stackView)
        stackView.anchor(top: stackFallow.bottomAnchor, left: stackFallow.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 40)
        v.addSubview(menuBar)
        menuBar.anchor(top: nil, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
     
//        menuBar.options = ProfileFilterVM(short_school: currentUser.short_school, major: currentUser.bolum, userUid: currentUser.uid, currentUser: currentUser)
//        menuBar.profileModel = ProfileModel(shortSchool: currentUser.short_school, currentUser: currentUser, major: currentUser.bolum, uid: currentUser.uid)
        menuBar.menuFilter = MenuFilter(model:  ProfileModel(shortSchool: otherUser.short_school, currentUser: currentUser, major: otherUser.bolum, uid: otherUser.uid),options:ProfileFilterVM(short_school: otherUser.short_school, major: otherUser.bolum, userUid: otherUser.uid, currentUser: currentUser))
        menuBar.filterDelagate = self
        return v
    }()
 
    //MARK:-lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitalAd = createAd()
        setNavigationBar()
        navigationItem.title = otherUser.username
        configureUI()
        configureCollectionView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        
        
    }
    init(currentUser : CurrentUser, otherUser : OtherUser , profileModel : ProfileModel , width : CGFloat) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.profileModel = profileModel
        self.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        self.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        self.width = width
        self.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        self.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        self.actionSheetCurrentUser = ASNoticesPostCurrentUserLaunher(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
        super.init(nibName: nil, bundle: nil)
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dissmis(){
       self.dismiss(animated: true, completion: nil)
    }
   
    
    //MARK:-load home post
    func getHomePost(){
        lessonPostModel = [LessonPostModel]()
        isHomePost = true
        isVayeAppPost = false
        isSchoolPost = false
        
        isLoadMoreHomePost = true
        isLoadMoreSchoolPost = false
        isLoadMoreVayeAppPost = false
        collectionview.reloadData()
        fetchLessonPost(otherUser: otherUser) {[weak self] (post) in
       
            self?.lessonPostModel = post
           
            if self?.lessonPostModel.count ?? -1 > 0{
                if  let time_e = self?.lessonPostModel[((self?.lessonPostModel.count)!) - 1].postTime{
                    self?.time = self?.lessonPostModel[((self?.lessonPostModel.count)!) - 1].postTime
                    self?.lessonPostModel.sort(by: { (post, post1) -> Bool in
                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    self?.collectionview.reloadData()
                }
            }
            else{
                self?.fetchAds()
                self?.collectionview.reloadData()
                
            }
        }
    }
    func fetchLessonPost(otherUser : OtherUser, completion : @escaping([LessonPostModel])->Void){
        var post = [LessonPostModel]()
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection("my-post").limit(to: 5).order(by: "postId", descending: true)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    return
                }
                if snap.isEmpty {
                    completion([])
                }else{
                    for postId in snap.documents{
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
                                        .document(otherUser.uid).collection("lesson-post").document(postId.documentID)
                                    deleteDb.delete()
                                }
                                completion(post)
                            }
                        }
                        
                        
                    }
                    self.home_page = snap.documents.last
                    self.fetchAds()
                    self.isLoadMoreHomePost = true
                    self.isLoadMoreSchoolPost = false
                    self.isLoadMoreVayeAppPost = false
                }
            }
        }
    }
    private func loadMoreHomePost(completion : @escaping(Bool) ->Void){
        guard let page = home_page else {
            isLoadMoreHomePost = false
            collectionview.reloadData()
            completion(false)
            return
        }
        
        let  db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("my-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: page)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            guard let snap = querySnap else {
                completion(false)
                return }
            if let err = err {
                print(err.localizedDescription as Any)
            }else if snap.isEmpty{
                sself.isLoadMoreHomePost = false
                sself.collectionview.reloadData()
                completion(false)
            }else{
                for item in snap.documents{
                    let db = Firestore.firestore().collection(sself.otherUser.short_school)
                        .document("lesson-post").collection("post").document(item.documentID)
                    db.getDocument { (docSnap , err) in
                        if err == nil {
                            guard let snapp = docSnap else {
                                completion(false)
                                return
                            }
                            if snapp.exists {
                                
                                sself.lessonPostModel.append(LessonPostModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = sself.lessonPostModel[(sself.lessonPostModel.count) - 1].postTime{
                                    sself.time = sself.lessonPostModel[(sself.lessonPostModel.count) - 1].postTime
                                    sself.lessonPostModel.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    sself.isLoadMoreHomePost = true
                                    sself.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                                
                            }else{
                                let deleteDb = Firestore.firestore().collection("user")
                                    .document(sself.otherUser.uid).collection("my-post").document(snapp.documentID)
                                deleteDb.delete()
                            }
                        }
                    }
                    sself.home_page = snap.documents.last
                }
                self?.fetchAds()
            }
        }
    }
    
    
    //MARK:-load vayeAppPost
    func getMainPost(){
        mainPost = [MainPostModel]()
        isHomePost = false
        isVayeAppPost = true
        isSchoolPost = false
        
        isLoadMoreHomePost = false
        isLoadMoreSchoolPost = false
        isLoadMoreVayeAppPost = true
        collectionview.reloadData()
        fetchMainPost(otherUser: otherUser) {[weak self] (post) in
            self?.mainPost = post
            //            self?.fetchAds()
            if self?.mainPost.count ?? -1 > 0{
 
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
    func fetchMainPost(otherUser : OtherUser , completion : @escaping([MainPostModel])->Void){
        var post = [MainPostModel]()
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection("user-main-post")
            .limit(to: 5)
            .order(by: "postId",descending: true)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty{
                    completion([])
                }else{
                    for postId in snap.documents{
                        let db = Firestore.firestore().collection("main-post")
                            .document("post")
                            .collection("post")
                            .document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists{
                                    post.append(MainPostModel.init(postId: snap.documentID, dic: snap.data()!))
                                }else{
                                    let db_currentUser = Firestore.firestore().collection("user")
                                        .document(otherUser.uid)
                                        .collection("user-main-post")
                                        .document(postId.documentID)
                                    db_currentUser.delete(){(err) in
                                        if let postType = postId.get("postType") as? String {
                                            let deleteDb = Firestore.firestore().collection(otherUser.short_school)
                                                .document("main-post")
                                                .collection(postType).document(postId.documentID)
                                            deleteDb.delete()
                                        }
                                    }
                                }
                            }
                            completion(post)
                        }
                    }
                    self.vaye_page = snap.documents.last
                    self.fetchAds()
                    self.isLoadMoreVayeAppPost = true
                  
                    self.isLoadMoreHomePost = false
                    self.isLoadMoreSchoolPost = false
                }
            }
        }
        
        
    }
    
    private func loadMoreVayeAppPost(completion: @escaping(Bool) ->Void){
        guard let pagee = vaye_page else {
            isLoadMoreVayeAppPost = false
            collectionview.reloadData()
            completion(false)
            return
        }
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection("user-main-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: pagee)
        db.getDocuments { (querySnap, err) in
            guard let snap = querySnap else { return }
            if let err = err {
                print("\(err.localizedDescription)")
            }else if snap.isEmpty{
                self.isLoadMoreVayeAppPost = false
                self.collectionview.reloadData()
                completion(false)
            }else{
                for item in snap.documents{
                    let db = Firestore.firestore().collection("main-post")
                        .document("post").collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else { return }
                            if snapp.exists {
                                self.mainPost.append(MainPostModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = self.mainPost[(self.mainPost.count) - 1].postTime{
                                    self.time = self.mainPost[(self.mainPost.count) - 1].postTime
                                    self.mainPost.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    self.isLoadMoreVayeAppPost = true
                                    self.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                            }else{
                                let db_currentUser = Firestore.firestore().collection("user")
                                    .document(self.otherUser.uid)
                                    .collection("user-main-post")
                                    .document(item.documentID)
                                db_currentUser.delete(){(err) in
                                    if let postType = item.get("postType") as? String {
                                        let deleteDb = Firestore.firestore().collection(self.otherUser.short_school)
                                            .document("main-post")
                                            .collection(postType).document(item.documentID)
                                        deleteDb.delete()
                                    }
                                }
                            }
                        }
                    }
                    self.vaye_page = snap.documents.last
                }
                self.fetchAds()
            }
        }
    }
    //MARK:-load school post
    func getSchoolPost(){
        schoolPost = [NoticesMainModel]()
        isHomePost = false
        isVayeAppPost = false
        isSchoolPost = true
       
        
       
        isLoadMoreHomePost = false
        isLoadMoreSchoolPost = true
        isLoadMoreVayeAppPost = false
        collectionview.reloadData()
        
        fetchScholPost(otherUser: otherUser) {[weak self] (post) in
            self?.schoolPost = post
            if self?.schoolPost.count ?? -1 > 0{
                if  let time_e = self?.schoolPost[((self?.schoolPost.count)!) - 1].postTime{
                    self?.time = self?.schoolPost[((self?.schoolPost.count)!) - 1].postTime
                    self?.schoolPost.sort(by: { (post, post1) -> Bool in
                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    self?.collectionview.reloadData()
                }
            }else{
                self?.fetchAds()
                self?.collectionview.reloadData()
            }
        }
    }
    //user/2YZzIIAdcUfMFHnreosXZOTLZat1/İSTE/1607288767989
    func fetchScholPost(otherUser : OtherUser , completion:@escaping([NoticesMainModel]) ->Void){
        
        var post = [NoticesMainModel]()
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/fav-post/1600284816337
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection(otherUser.short_school).limit(to: 5).order(by: "postId", descending: true)
        
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty{
                    completion([])
                }else{
                    for postId in  snap.documents {
                        let db = Firestore.firestore().collection(otherUser.short_school)
                            .document("notices")
                            .collection("post")
                            .document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists{
                                    post.append(NoticesMainModel.init(postId: snap.documentID, dic: snap.data()))
                                }else{
                                    let deleteDb = Firestore.firestore().collection("user")
                                        .document(otherUser.uid)
                                        .collection(otherUser.short_school)
                                        .document(postId.documentID)
                                    deleteDb.delete()
                                }
                                completion(post)
                            }
                        }
                    }
                    self.schoolPost_page = snap.documents.last
                    self.fetchAds()
                 
                    self.isLoadMoreHomePost = false
                    self.isLoadMoreSchoolPost = true
                    self.isLoadMoreVayeAppPost = false
                }
            }
        }
        
    }
    func loadMoreSchoolPost(completion: @escaping(Bool) ->Void){
        guard let pagee = schoolPost_page else {
            isLoadMoreSchoolPost = false
            collectionview.reloadData()
            completion(false)
            return }
       //user/4OaYqfc53gOBwAwVZMdu9XZV6ix2/İSTE/1607178986322
            let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection(otherUser.short_school).limit(to: 5).order(by: "postId", descending: true).start(afterDocument: pagee)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let snap = querySnap else { return }
            guard let sself = self else { return }
            if let err = err {
                print("\(err.localizedDescription)")
            }else if snap.isEmpty{
                sself.isLoadMoreSchoolPost = false
                sself.collectionview.reloadData()
                completion(false)
            }else{
                for item in snap.documents {
                    print("snapss : \(item.documentID)")
                    let db = Firestore.firestore().collection(sself.otherUser.short_school)
                        .document("notices")
                        .collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else{ return }
                            if snapp.exists {
                                sself.schoolPost.append(NoticesMainModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = sself.schoolPost[(sself.schoolPost.count) - 1].postTime{
                                    sself.time = sself.schoolPost[(sself.schoolPost.count) - 1].postTime
                                    sself.schoolPost.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    sself.isLoadMoreSchoolPost = true
                                    sself.collectionview.reloadData()
                                    completion(true)
                                    
                                }
                            }else{
                                let db = Firestore.firestore().collection("user")
                                    .document(sself.otherUser.uid)
                                    .collection(sself.otherUser.short_school)
                                    .document(item.documentID)
                                db.delete()
                            }
                        }
                    }
                    sself.schoolPost_page = snap.documents.last
                }
                sself.fetchAds()
            }
        }

        
    }
    
    func fetchAds() {
        adLoader = GADAdLoader(adUnitID: native_adUnitID, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
  
    
    
    private func createAd() ->GADInterstitial {
        let ad = GADInterstitial(adUnitID: adUnitID)
        ad.delegate = self
        ad.load(GADRequest())
        return ad
    }
    
    func configureUI(){
        view.backgroundColor = .white
       name.text = otherUser.name
       school.text = otherUser.schoolName
       major.text = otherUser.bolum
       UserService.shared.getFollowersCount(uid: otherUser.uid) {[weak self] (val) in
           guard let sself = self else { return }
           sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
           sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

           sself.fallowerLabel.attributedText = sself.followers
       }
       UserService.shared.getFollowingCount(uid : otherUser.uid){[weak self]  (val) in
           guard let sself = self else { return }
           sself.following = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
           sself.following.append(NSAttributedString(string: "  Takip Edilen  ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
           sself.fallowingLabel.attributedText = sself.following
       }
       
       profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
       profileImage.sd_setImage(with: URL(string: otherUser.thumb_image))
       if otherUser.linkedin == "" {
           linkedin.isHidden = true
       }
       if otherUser.instagram == ""{
           instagram.isHidden = true
       }
       if otherUser.twitter == ""{
           twitter.isHidden = true
       }
       if otherUser.github == ""{
           github.isHidden = true
       }
    }
    
 
    func configureCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .collectionColor()
        
        
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: home_post_id)
        collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: home_post_data_id)
        
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.register(EmptyCell.self, forCellWithReuseIdentifier: emptyCell)
        
        
        collectionview.register(BuyAndSellView.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(BuyAndSellDataView.self , forCellWithReuseIdentifier: cellData)
        collectionview.register(FoodMeView.self, forCellWithReuseIdentifier: cell_foodme_id)
        collectionview.register(FoodMeViewData.self, forCellWithReuseIdentifier: cell_foodme_data_id)
        collectionview.register(CampingView.self, forCellWithReuseIdentifier: cell_camp_id)
        collectionview.register(CampingDataView.self, forCellWithReuseIdentifier: cell_camp_data_id)
        collectionview.register(NoticesCell.self, forCellWithReuseIdentifier: cell_notices_id)
        collectionview.register(NoticesDataCell.self, forCellWithReuseIdentifier: cell_notices_data_id)
        
        
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        
        
        view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        view.addSubview(headerView)
        
        collectionview.contentInset = UIEdgeInsets(top: width, left: 0, bottom: 0, right: 0)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let y = -scrollView.contentOffset.y
//        print(y)
        let h = max(y,50)
     

        if h <= 230 {
            stackView.isHidden = true
        }else{
            stackView.isHidden = false
        }

        if h <= 161 {
            aboutSection.isHidden = true
        }else{
            aboutSection.isHidden = false
        }
        if h <= 180 {
            stackFallow.isHidden = true
        }else{
            stackFallow.isHidden = false
        }
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top
                                  , width: view.frame.width, height: h)
        
        profileImage.frame = CGRect(x: 24, y: 4, width: (h) * ((65 * 100) / width) / 100 , height: (h) * ((65 * 100) / width) / 100)
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        if h <= 30 {
            profileImage.isHidden = true
            followBtn.isHidden = true
        }else{
            profileImage.isHidden = false
            followBtn.isHidden = false
        }
    }
    
}

extension OtherUserProfile : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isHomePost {
            return lessonPostModel.count
        }else if isVayeAppPost{
            return mainPost.count
        }else if isSchoolPost{
            return schoolPost.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if isHomePost {
            
            
            if lessonPostModel[indexPath.row].postId == nil {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
                cell.nativeAd = lessonPostModel[indexPath.row].nativeAd
                return cell
            }
            else if lessonPostModel[indexPath.row].empty == "empty"{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: emptyCell, for: indexPath) as! EmptyCell
                
                return cell
            }
            else if lessonPostModel[indexPath.row].data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_id, for: indexPath) as! NewPostHomeVC
//                  cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPostModel[indexPath.row]
                
                return cell
            }
            
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_data_id, for: indexPath) as! NewPostHomeVCData
                
                cell.backgroundColor = .white
//                cell.delegate = self
                cell.currentUser = currentUser
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                
                cell.filterView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPostModel[indexPath.row]
                
                return cell
            }
        }
        else if isSchoolPost{
            if schoolPost[indexPath.row].postId == nil {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
                cell.nativeAd = schoolPost[indexPath.row].nativeAd
                return cell
            }
            else if schoolPost[indexPath.row].empty == "empty"{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: emptyCell, for: indexPath) as! EmptyCell
                
                return cell
            }
           else if schoolPost[indexPath.row].data.isEmpty {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_notices_id, for: indexPath) as! NoticesCell
//                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = schoolPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = schoolPost[indexPath.row]
                return cell
            }else{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cell_notices_data_id, for: indexPath) as! NoticesDataCell
                cell.backgroundColor = .white
//                cell.delegate = self
                cell.currentUser = currentUser
                let h = schoolPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)

                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 12 , width: cell.msgText.frame.width, height: 100)

                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = schoolPost[indexPath.row]
                return cell
            }
        }
        else if isVayeAppPost {
            if mainPost[indexPath.row].postId == nil {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
                cell.nativeAd = mainPost[indexPath.row].nativeAd
                return cell
            }
            else if mainPost[indexPath.row].empty == "empty"{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: emptyCell, for: indexPath) as! EmptyCell
                
                return cell
            }
            else{
                
                if mainPost[indexPath.row].postType == PostType.buySell.despription{
                    if mainPost[indexPath.row].data.isEmpty {
                        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BuyAndSellView
//                        cell.delegate = self
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
//                        cell.delegate = self
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
//                        cell.delegate = self
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
//                        cell.delegate = self
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
//                            cell.delegate = self
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
//                        cell.delegate = self
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
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.backgroundColor = .red
        return cell
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isHomePost {
            
            if lessonPostModel[indexPath.row].postId == nil {
                return CGSize(width: view.frame.width, height: 409)
                
            }
            else if lessonPostModel[indexPath.row].empty == "empty"{
                return .zero
            }
            else{
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                if lessonPostModel[indexPath.row].data.isEmpty{
                    
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
                }else{
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
                }
            }
            
            
        }else if isSchoolPost{
            if schoolPost[indexPath.row].postId == nil {
                return CGSize(width: view.frame.width, height: 409)
                
            }
            else if schoolPost[indexPath.row].empty == "empty"{
                return .zero
            }else{
                if schoolPost[indexPath.row].text == nil {
                    return .zero
                }
                let h = schoolPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                
                if schoolPost[indexPath.row].data.isEmpty{
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30 )
                }
                else{
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
                }
            }
        }
        else if isVayeAppPost {
            if mainPost[indexPath.row].postId == nil {
                return CGSize(width: view.frame.width, height: 409)
            }
            
            if mainPost[indexPath.row].empty == "empty" {
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
       else if isSchoolPost{
            if schoolPost[indexPath.row].postId == nil {
                return CGSize(width: view.frame.width, height: 409)
                
            }
            else if schoolPost[indexPath.row].empty == "empty"{
                return .zero
            }else{
                if schoolPost[indexPath.row].text == nil {
                    return .zero
                }
                let h = schoolPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                
                if schoolPost[indexPath.row].data.isEmpty{
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30 )
                }
                else{
                    return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
                }
            }
        }
        
        return CGSize(width: self.view.frame.width, height: view.frame.height - 225)
    }
  
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if isHomePost {
            if lessonPostModel.count > 5 {
                
                if indexPath.item == lessonPostModel.count - 1 {
                    loadMoreHomePost { (val) in
                    }
                }else{
                    isVayeAppPost = true
                    isHomePost = true
                    isSchoolPost = false
                    
     
                    self.isLoadMoreHomePost = false
                    self.isLoadMoreSchoolPost = false
                    self.isLoadMoreVayeAppPost = false
                }
            }
        }else if isVayeAppPost{
            if mainPost.count > 5 {
                if indexPath.item == mainPost.count - 1 {
                    loadMoreVayeAppPost { (val) in

                    }
                }else{
                    isVayeAppPost = true
                    isHomePost = false
                    isSchoolPost = false
                  
                    self.isLoadMoreHomePost = false
                    self.isLoadMoreSchoolPost = false
                    self.isLoadMoreVayeAppPost = false
                }
            }
        }else if isSchoolPost{
            if schoolPost.count > 5 {
                if indexPath.item == schoolPost.count - 1 {
                    loadMoreSchoolPost { (va) in
                        
                    }
                }
               
            }else{
                isVayeAppPost = false
                isHomePost = false
                isSchoolPost = true
         
                self.isLoadMoreHomePost = false
                self.isLoadMoreSchoolPost = false
                self.isLoadMoreVayeAppPost = false
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




extension OtherUserProfile : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        if isHomePost {
            self.nativeAd = nativeAd
            if lessonPostModel.count > 0{
                if  let time_e = self.lessonPostModel[(self.lessonPostModel.count) - 1].postTime{
                    self.lessonPostModel.sort(by: { (post, post1) -> Bool in
                        
                        return post.postTime?.dateValue() ?? time_e.dateValue()   > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    
                    self.lessonPostModel.append(LessonPostModel.init(nativeAd: nativeAd , postTime : self.lessonPostModel[(self.lessonPostModel.count) - 1].postTime!))
                }
            }
            self.isLoadMoreHomePost = false
            self.collectionview.reloadData()
        }else if isVayeAppPost {
            self.nativeAd = nativeAd
            if mainPost.count > 0{
                if  let time_e = self.mainPost[(self.mainPost.count) - 1].postTime{
                    self.mainPost.sort(by: { (post, post1) -> Bool in
                        
                        return post.postTime?.dateValue() ?? time_e.dateValue()   > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    
                    self.mainPost.append(MainPostModel.init(nativeAd: nativeAd , postTime : self.mainPost[(self.mainPost.count) - 1].postTime!))
                }
            }
            self.isLoadMoreVayeAppPost = false
            self.collectionview.reloadData()
        }
        else if isSchoolPost{
            self.nativeAd = nativeAd
            if schoolPost.count > 0{
                if  let time_e = self.schoolPost[(self.schoolPost.count) - 1].postTime{
                    self.schoolPost.sort(by: { (post, post1) -> Bool in
                        
                        return post.postTime?.dateValue() ?? time_e.dateValue()   > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    
                    self.schoolPost.append(NoticesMainModel.init(nativeAd: nativeAd , postTime : self.schoolPost[(self.schoolPost.count) - 1].postTime!))
                }
            }
            self.isLoadMoreSchoolPost = false
            self.collectionview.reloadData()
        }
    }
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        if isHomePost {
            print("\(adLoader) failed with error: \(error.localizedDescription)")
            self.lessonPostModel.append(LessonPostModel.init(empty: "empty", postId: "empty"))
            self.isLoadMoreHomePost = true
            self.collectionview.reloadData()
        }else if isVayeAppPost{
            print("\(adLoader) failed with error: \(error.localizedDescription)")
            self.mainPost.append(MainPostModel.init(empty: "empty", postId: "empty"))
            self.isVayeAppPost = true
            self.collectionview.reloadData()
        }else if isSchoolPost{
            print("\(adLoader) failed with error: \(error.localizedDescription)")
            self.schoolPost.append(NoticesMainModel.init(empty: "empty", postId: "empty"))
            self.isSchoolPost = true
            self.collectionview.reloadData()
        }
    }
    
    
}
extension OtherUserProfile : UserProfileMenuBarDelegate{
    func didSelectOptions(option: ProfileFilterOptions) {
        switch option{
        
        case .major():
            getHomePost()
            break
        case .shortSchool():
            getSchoolPost()
        break
        case .vayeApp():
            getMainPost()
            break
        case .fav():
            break
        }
    }
    
    
}



