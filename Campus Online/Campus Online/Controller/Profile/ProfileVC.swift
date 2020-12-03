//
//  ProfileVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let cellId = "id"
private let profileId = "profileId"

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
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import GoogleMobileAds
class ProfileVC: UIViewController  , UIScrollViewDelegate{
   
    
    lazy var lessonPostModel = [LessonPostModel]()
    lazy var mainPost = [MainPostModel]()
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    var time : Timestamp!
    var adLoader: GADAdLoader!
    var nativeAd: GADUnifiedNativeAd?
    
    //MARK:-DocumentSnapshot
    var home_page : DocumentSnapshot? = nil
    var vaye_page : DocumentSnapshot? = nil
    //MARK: - variables
    var width : CGFloat
    var profileModel : ProfileModel
    var controller : UIViewController!
    lazy var count : Int = 0
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    weak var profileHeaderDelegate : ProfileHeaderMenuBarDelegate?
    private  var actionSheet : ActionSheetHomeLauncher
    let native_adUnitID =  "ca-app-pub-1362663023819993/1801312504"
    //MARK:-post filter val
    var isHomePost : Bool = false
    var isSchoolPost : Bool = false
    var isVayeAppPost : Bool = false
    var isFavPost : Bool = false
    
    var isLoadMoreHomePost : Bool = false
    var isLoadMoreSchoolPost : Bool = false
    var isLoadMoreVayeAppPost : Bool = false
    var isLoadMoreFavPost : Bool = false
    //MARK: -properties
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
    lazy var headerBar : UIView = {
       let v = UIView()
      
        v.addSubview(dissmisButton)
        dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(titleLbl)
        titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        return v
    }()
 
    lazy var menuBar  : MenuBar = {
       let v = MenuBar()

        return v
    }()
    
    //MARK:- header properites
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
    
    lazy var headerView : UIView = {
       let v = UIView()
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
        menuBar.menuFilter = MenuFilter(model:  ProfileModel(shortSchool: currentUser.short_school, currentUser: currentUser, major: currentUser.bolum, uid: currentUser.uid),options:ProfileFilterVM(short_school: currentUser.short_school, major: currentUser.bolum, userUid: currentUser.uid, currentUser: currentUser))
        menuBar.filterDelagate = self
        return v
    }()
    
    //MARK: - lifeCycle
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
     
        self.profileModel = ProfileModel.init(shortSchool: currentUser.short_school, currentUser: currentUser, major: currentUser.bolum, uid: currentUser.uid)
        self.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        self.width = 285
        super.init(nibName: nil, bundle: nil)
     
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationItem.title = currentUser.username
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        setNavigationBar()
       navigationController?.navigationBar.isHidden = false
        configureUI()
        configureCollectionView()
        titleLbl.text = currentUser.username
        if profileModel.shortSchool == currentUser.short_school {
            if profileModel.major == currentUser.bolum{
                getHomePost()
            }else {
                //getSchoolPost
            }
        }else{
//            getMainPost()
        }
   
    }
   
 //MARK: configure functions
    func configureUI(){
         view.backgroundColor = .white
        name.text = currentUser.name
        school.text = currentUser.schoolName
        major.text = currentUser.bolum
        UserService.shared.getFollowersCount(uid: currentUser.uid) {[weak self] (val) in
            guard let sself = self else { return }
            sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

            sself.fallowerLabel.attributedText = sself.followers
        }
        UserService.shared.getFollowingCount(uid : currentUser.uid){[weak self]  (val) in
            guard let sself = self else { return }
            sself.following = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.following.append(NSAttributedString(string: "  Takip Edilen  ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
            sself.fallowingLabel.attributedText = sself.following
        }
        
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        if currentUser.linkedin == "" {
            linkedin.isHidden = true
        }
        if currentUser.instagram == ""{
            instagram.isHidden = true
        }
        if currentUser.twitter == ""{
            twitter.isHidden = true
        }
        if currentUser.github == ""{
            github.isHidden = true
        }
      
     }
    func configureCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionview.backgroundColor = .white
       
        collectionview.dataSource = self
        collectionview.delegate = self

        
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
        
        view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        view.addSubview(headerView)
        
//        collectionview.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: view.frame.height)
        collectionview.contentInset = UIEdgeInsets(top: 285, left: 0, bottom: 0, right: 0)
    
         }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let y = -scrollView.contentOffset.y
//        print(y)
        let h = max(y,50)
     
        print(h)

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
    
    //MARK: - ads func
    func fetchAds() {
        adLoader = GADAdLoader(adUnitID: native_adUnitID, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    //MARK:- helper functions
    //MARK:-  load home post helper
    func getHomePost(){
        lessonPostModel = [LessonPostModel]()
        isHomePost = true
        isVayeAppPost = false
        isSchoolPost = false
        
        isLoadMoreHomePost = true
        isLoadMoreSchoolPost = false
        isLoadMoreVayeAppPost = false
        collectionview.reloadData()
        
        fetchLessonPost(currentUser: currentUser) {[weak self] (post) in
       
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
    func fetchLessonPost(currentUser : CurrentUser, completion : @escaping([LessonPostModel])->Void){
        var post = [LessonPostModel]()
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
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
            .document(currentUser.uid).collection("my-post").limit(to: 5).order(by: "postId", descending: true).start(afterDocument: page)
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
                    let db = Firestore.firestore().collection(sself.currentUser.short_school)
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
                                    .document(sself.currentUser.uid).collection("my-post").document(snapp.documentID)
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

   
 
  
   //MARK:-selectors
     @objc func dissmis(){
        self.dismiss(animated: true, completion: nil)
     }
   

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ProfileVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isHomePost {
            return lessonPostModel.count
        }else if isVayeAppPost{
            return mainPost.count
        }
        
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isHomePost{
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
                
            }else{
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
        }else if isVayeAppPost{
            
        }else if isSchoolPost{
            
        }else if isFavPost{
            
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
            
            
        }else if isVayeAppPost {
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
        
        return CGSize(width: self.view.frame.width, height: view.frame.height - 225)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
//                if indexPath.item == mainPost.count - 1 {
//                    loadMoreVayeAppPost { (val) in
//
//                    }
//                }else{
//                    isVayeAppPost = true
//                    isHomePost = false
//                    isSchoolPost = false
//                    self.isLoadMoreHomePost = false
//                    self.isLoadMoreSchoolPost = false
//                    self.isLoadMoreVayeAppPost = false
//                }
            }
        }
    }
    
}
//MARK:-ads extension
extension ProfileVC: GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
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
        }
    }
    
    
}


extension ProfileVC : UserProfileMenuBarDelegate {
    func didSelectOptions(option: ProfileFilterOptions) {
        switch option {
        
        case .major():
//            profileHeaderDelegate?.getMajorPost()
//            self.collectionview.reloadData()
//            print("major post")
        getHomePost()
            break
        case .shortSchool():
            profileHeaderDelegate?.getSchoolPost()
            self.collectionview.reloadData()
            print("school post")
        case .vayeApp():
            profileHeaderDelegate?.getVayeAppPost()
        case .fav():
            profileHeaderDelegate?.getFavPost()
        }
    }
    
    
}

extension ProfileVC : ActionSheetHomeLauncherDelegate{
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
//MARK:-lesson post extension
extension ProfileVC : NewPostHomeVCDelegate{
    func goProfileByMention(userName: String) {
        
    }
    
    
    
    func clickMention(username: String) {
        if "@\(username)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
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
      
        actionSheet.delegate = self
        actionSheet.show(post: post)
        guard let  index = collectionview.indexPath(for: cell) else { return }
        selectedIndex = index
        selectedPostID = lessonPostModel[index.row].postId
        
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
    
}
