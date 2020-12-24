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

extension OtherUserProfile : ASMainOtherUserDelegate {
    func didSelect(option: ASMainPostOtherUserOptions) {
        switch option {
        
        case .fallowUser(_):
            break
        case .slientUser(_):
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

class OtherUserProfile: UIViewController     {
    lazy var lessonPostModel = [LessonPostModel]()
    lazy var mainPost = [MainPostModel]()
   
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
  
    
    
    
    //MARK:-home launcher
    private var homeLauncher : ActionSheetHomeLauncher
    private var homeLauncherOtherUser : ActionSheetOtherUserLaunher
    //MARK:-school launcher
    private var schoolLauncher : ASNoticesPostLaunher
    private var schoolLauncherCurrentUser : ASNoticesPostCurrentUserLaunher
    
    //MARK:-vaye app launcher
    private var vayeAppLauncherCurrentUser : ActionSheetMainPost
    private var vayeAppLaunherOtherUser :  ASMainPostOtherUser
    let native_adUnitID =  "ca-app-pub-3940256099942544/3986624511"
    
    var interstitalGithub : GADInterstitial!
    var interstitalInsta : GADInterstitial!
    var interstitalLinked : GADInterstitial!
    var interstitalTwitter : GADInterstitial!
    
    var ads_target : String = ""
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
 

    var otherUser : OtherUser
    
    var isFallowingUser : Bool?{
       didSet{
           guard let val = isFallowingUser else { return }
           if val{
               followBtn.setTitle("Takibi Bırak", for: .normal)
               followBtn.setBackgroundColor(color: .red, forState: .normal)
               followBtn.setTitleColor(.white, for: .normal)
               followBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
               followBtn.layer.borderColor = UIColor.red.cgColor
           }else{
               followBtn.setTitle("Takip Et", for: .normal)
               followBtn.setBackgroundColor(color: .mainColor(), forState: .normal)
               followBtn.setTitleColor(.white, for: .normal)
               followBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
               followBtn.layer.borderColor = UIColor.mainColor().cgColor
           }
       }
   }
    
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
        btn.setTitle("yükleniyor...", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(setFollow), for: .touchUpInside)
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
    let sendMsg : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "msg").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    
    let github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    let linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goLinkedIn), for: .touchUpInside)
        return btn
    }()
    
    let twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goTwitter), for: .touchUpInside)
        return btn
    }()
    let instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goInstagram), for: .touchUpInside)
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
        followBtn.anchor(top: v.topAnchor, left: nil, bottom: nil, rigth: v.rightAnchor, marginTop: 20, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 170, heigth: 30)
        v.addSubview(sendMsg)
        sendMsg.anchor(top: nil, left: nil, bottom: nil, rigth: followBtn.leftAnchor, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 20, width: 30, heigth: 30)
        sendMsg.centerYAnchor.constraint(equalTo: followBtn.centerYAnchor).isActive = true
        
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
        UserService.shared.checkFollowers(currentUser: currentUser, otherUser: otherUser.uid) {[weak self] (_val) in
            guard let sself = self else { return }
            sself.isFallowingUser = _val

        }
        if profileModel.shortSchool == currentUser.short_school {
            if profileModel.major == currentUser.bolum{
                getHomePost()
            }else {
               getSchoolPost()
            }
        }else{
            getMainPost()
        }
        
        interstitalTwitter = createAd()
        interstitalGithub = createAd()
        interstitalLinked = createAd()
        interstitalInsta = createAd()
        
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            if self.interstitalAd.isReady {
                self.interstitalAd.present(fromRootViewController: self)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        
        
    }
    init(currentUser : CurrentUser, otherUser : OtherUser , profileModel : ProfileModel , width : CGFloat) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.profileModel = profileModel
     
        self.width = width
      
        
       
        //home launcher
        self.homeLauncher = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        self.homeLauncherOtherUser = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        //notices launher
        
        self.schoolLauncher = ASNoticesPostLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        self.schoolLauncherCurrentUser = ASNoticesPostCurrentUserLaunher(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
        //vayeApp launher
        self.vayeAppLauncherCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
        self.vayeAppLaunherOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        super.init(nibName: nil, bundle: nil)
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:--selectors
    @objc func goGithub(){
        if interstitalGithub.isReady {
          
            ads_target = "github"
            interstitalGithub.present(fromRootViewController: self)
        }else{
             guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goInstagram(){
        if interstitalInsta.isReady {
           
            ads_target = "instagram"
            interstitalInsta.present(fromRootViewController: self)
        }else{
             guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goTwitter(){
        if interstitalTwitter.isReady {
            
            ads_target = "twitter"
            interstitalTwitter.present(fromRootViewController: self)
        }else{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goLinkedIn(){
        if interstitalLinked.isReady {
            
            ads_target = "linkedin"
            
            interstitalLinked.present(fromRootViewController: self)
        }else{
            guard let url = URL(string: otherUser.linkedin ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func dissmis(){
       self.dismiss(animated: true, completion: nil)
    }
   //MARK:-functions
    
    @objc func setFollow(){
        Utilities.waitProgress(msg: "")
        guard let isFallowingUser = isFallowingUser else { return }
        if isFallowingUser{
            let db = Firestore.firestore().collection("user")
                .document(otherUser.uid).collection("fallowers").document(currentUser.uid)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    
                    UserService.shared.checkFollowers(currentUser: sself.currentUser, otherUser: sself.otherUser.uid) { (val) in
                        sself.isFallowingUser = val
            
                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                        .collection("following").document(sself.otherUser.uid)
                    db.delete { (err) in
                        if err == nil {
                            Utilities.succesProgress(msg: "Takip Etmeyi Bıraktınız ")
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                
                
                }
            }
        }else{
            let db = Firestore.firestore().collection("user")
                .document(otherUser.uid).collection("fallowers").document(currentUser.uid)
            db.setData(["user":currentUser.uid as Any] as [String:Any], merge: true) {[weak self] (err) in
                if err == nil {
                    guard let sself = self else { return }
                
                    UserService.shared.checkFollowers(currentUser: sself.currentUser, otherUser: sself.otherUser.uid) { (val) in
                        sself.isFallowingUser = val
                   
                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                        .collection("following").document(sself.otherUser.uid)
                  
                    db.setData(["user":sself.otherUser.uid as Any], merge: true) { (err) in
                        if err == nil{
                            Utilities.succesProgress(msg: "Takip Ediliyor")
                            NotificaitonService.shared.start_following_you(currentUser: sself.currentUser, otherUser: sself.otherUser, text: Notification_description.following_you.desprition, type: NotificationType.following_you.desprition) { (_) in
                                
                            }
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                  
                }
            }
        }
    }
    
    private func getUsername(username : String) ->String{
        
        return username.replacingOccurrences(of: "@", with: "", options:NSString.CompareOptions.literal, range:nil)
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
                  cell.delegate = self
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
                cell.delegate = self
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
                cell.delegate = self
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
                cell.delegate = self
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
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.backgroundColor = .red
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadMoreCell, for: indexPath)
            as! LoadMoreCell
        cell.activityView.startAnimating()
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoadMoreHomePost{
            return CGSize(width: view.frame.width, height: 50)
        }else if isLoadMoreVayeAppPost{
            return CGSize(width: view.frame.width, height: 50)
        }else if isLoadMoreSchoolPost {
            return CGSize(width: view.frame.width, height: 50)
        }else{
            return .zero
        }
       
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

extension OtherUserProfile : ActionSheetHomeLauncherDelegate {
    func didSelect(option: ActionSheetHomeOptions) {
        switch option {
        case .editPost(_):
            guard let index = selectedIndex else { return }
            if let h = collectionview.cellForItem(at: index) as? NewPostHomeVCData {
                let vc = StudentEditPost(currentUser: currentUser , post : lessonPostModel[index.row] , heigth : h.msgText.frame.height )
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }else if let  h = collectionview.cellForItem(at: index) as? NewPostHomeVC{
                let vc = StudentEditPost(currentUser: currentUser , post : lessonPostModel[index.row] , heigth : h.msgText.frame.height )
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
            
            
        case .deletePost(_):
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
                    sself.deleteToStorage(data: sself.lessonPostModel[index.row].data, postId: postId) { (_val) in
                        if (_val){
                            Utilities.succesProgress(msg: "Silindi")
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
    
    
}
extension OtherUserProfile : ActionSheetOtherUserLauncherDelegate {
    func didSelect(option: ActionSheetOtherUserOptions) {
        switch option {
        case .fallowUser(_):
            Utilities.waitProgress(msg: "")
            guard let index = selectedIndex else {
                Utilities.dismissProgress()
                return }
            UserService.shared.fetchOtherUser(uid: mainPost[index.row].senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return}
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
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
            removeLesson(lessonName: mainPost[index.row].lessonName) { (_) in
              
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
            let vc = ReportingVC(target: ReportTarget.homePost.description, currentUser: currentUser, otherUser: lessonPostModel[index.row].senderUid, postId: lessonPostModel[index.row].postId, reportType: ReportType.reportPost.description)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .reportUser(_):
            break
     
        }
    }
    
    
}
extension OtherUserProfile : NewPostHomeVCDelegate {
    func options(for cell: NewPostHomeVC) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            homeLauncher.delegate = self
            homeLauncher.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
        }else{
            Utilities.waitProgress(msg: nil)
            homeLauncherOtherUser.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                    guard let sself = self else { return }
                    Utilities.dismissProgress()
                    sself.homeLauncherOtherUser.show(post: post, otherUser: user)
                    
                }
            
            
        }
    }
    
    func like(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        PostService.shared.setLike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
           
        }
    }
    
    func dislike(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }

     PostService.shared.setDislike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
        
     }
    }
    
    func fav(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }

        PostService.shared.setFav(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    }
    
    func comment(for cell: NewPostHomeVC) {
        guard let post = cell.lessonPostModel else { return }
        let vc = CommentVC(currentUser: currentUser, post : post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func linkClick(for cell: NewPostHomeVC) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for cell: NewPostHomeVC) {
        
    }
    

    
}

extension OtherUserProfile : NewPostHomeVCDataDelegate {
    func showProfile(for cell: NewPostHomeVCData) {

    }
    func options(for cell: NewPostHomeVCData) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            homeLauncher.delegate = self
            homeLauncher.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
        }else{
            Utilities.waitProgress(msg: nil)
            homeLauncherOtherUser.delegate = self
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                    guard let sself = self else { return }
                    Utilities.dismissProgress()
                    sself.homeLauncherOtherUser.show(post: post, otherUser: user)
                    
                }
            
            
        }
        
    }
    
    func like(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        PostService.shared.setLike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
    }
    
    func dislike(for cell: NewPostHomeVCData) {
           guard let post = cell.lessonPostModel else { return }
        PostService.shared.setDislike(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
   
    }
    
    func fav(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        PostService.shared.setFav(post: post, collectionView: collectionview, currentUser: currentUser) { (_) in
            
        }
   
    }
    
    func comment(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        let vc = CommentVC(currentUser: currentUser, post : post)
        navigationController?.pushViewController(vc, animated: true)
            
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)
    }
   
    
    
    
}

extension OtherUserProfile : BuySellVCDelegate {
    func options(for cell: BuyAndSellView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post : post , otherUser : user)
                

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
    
//    func goProfileByMention(userName: String)
//    {
//        if "@\(userName)" == currentUser.username {
//            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
//                guard let self = self else { return }
//                if val{
//                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }else{
//                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//        }else{
//            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
//                guard let sself = self else { return }
//                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
//                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
//                        if val {
//                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
//
//                            sself.navigationController?.pushViewController(vc, animated: true)
//                            Utilities.dismissProgress()
//                        }else{
//                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
//
//                            sself.navigationController?.pushViewController(vc, animated: true)
//                            Utilities.dismissProgress()
//                        }
//
//                    }                }
//
//            }
//        }
//    }
    
    
    
}
extension OtherUserProfile : ASMainPostLaungerDelgate {
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
extension OtherUserProfile : BuySellVCDataDelegate {
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
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post: post, otherUser: user)

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
    
    
}
extension OtherUserProfile : FoodMeVCDelegate {
    func options(for cell: FoodMeView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post: post, otherUser: user)

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
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
extension OtherUserProfile :FoodMeVCDataDelegate{
    func options(for cell: FoodMeViewData) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post: post, otherUser: user)

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
    
}
extension OtherUserProfile :CampingVCDataDelegate{
    func options(for cell: CampingDataView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post: post, otherUser: user)

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
        
            }
        }
    }
    
}

extension OtherUserProfile :CampingVCDelegate{
    func options(for cell: CampingView) {
        guard let post = cell.mainPost else { return }
        if post.senderUid == currentUser.uid
        {
            vayeAppLauncherCurrentUser.delegate = self
            vayeAppLauncherCurrentUser.show(post: post)
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
                sself.vayeAppLaunherOtherUser.show(post: post, otherUser: user)

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
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
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
extension OtherUserProfile :NewPostNoticesVCDelegate{
    func options(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        if post.senderUid == currentUser.uid
        {
            schoolLauncherCurrentUser.delegate = self
            schoolLauncherCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = schoolPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = schoolPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.schoolLauncher.show(post: post, otherUser: user)
                
            }
        }
    }
    
    func like(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        NoticesService.shared.setPostLike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        NoticesService.shared.setDislike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        let vc = NoticeVCComment(currentUser: currentUser, post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesCell) {
        guard  let post = cell.noticesPost else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
    
    func goProfileByMention(userName: String) {
        if "@\(userName)" == currentUser.username {
            
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
    
    func clickMention(username: String) {
        if "@\(username)" == currentUser.username {
            
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
    
}
extension OtherUserProfile :NewPostNoticesDataVCDelegate{
    func options(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        if post.senderUid == currentUser.uid
        {
            schoolLauncherCurrentUser.delegate = self
            schoolLauncherCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = schoolPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = schoolPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.schoolLauncher.show(post: post, otherUser: user)
                
            }
        }
    }
    
    func like(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        NoticesService.shared.setPostLike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("liked")
            
        }
    }
    
    func dislike(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        NoticesService.shared.setDislike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        let vc = NoticeVCComment(currentUser: currentUser, post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesDataCell) {
        guard  let post = cell.noticesPost else {
            return
        }
        
        if post.senderUid == currentUser.uid{
            
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
                
            }
        }
    }
    
}
extension OtherUserProfile : GADInterstitialDelegate {
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        if ads_target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("fail")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if ads_target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
        
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("reveived")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
       
        if ads_target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if ads_target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
    }
}
