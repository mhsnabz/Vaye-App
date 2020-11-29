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
private let home_post_id = "home_post_id"
private let home_post_data_id = "home_post_data_id"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"
class OtherUserProfile: UIViewController  {
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    weak var delegate : OtherUserProfileHeaderDelegate?
    var currentUser : CurrentUser
    var otherUser : OtherUser
    var collectionview: UICollectionView!
    lazy var lessonPostModel = [LessonPostModel]()
    var profileModel : ProfileModel
    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
    //    var adUnitID =   "ca-app-pub-1362663023819993/4203883052"
    var interstitalAd : GADInterstitial!
    
    var time : Timestamp!
    //MARK:-post filter val
    
    var isHomePost : Bool = false
    var isSchoolPost : Bool = false
    var isVayeAppPost : Bool = false
    
    
    var isLoadMoreHomePost : Bool = false
    var isLoadMoreSchoolPost : Bool = false
    var isLoadMoreVayeAppPost : Bool = false
    
    
    //MARK:-DocumentSnapshot
    var home_page : DocumentSnapshot? = nil
    //MARK:-propeties
    
    let titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    
    
    lazy var headerBar : UIView = {
        let v = UIView()
        
        v.addSubview(titleLbl)
        titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        
        return v
    }()
    //MARK:-lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        configureUI()
        configureCollectionView()
        interstitalAd = createAd()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            if self.interstitalAd.isReady {
                self.interstitalAd.present(fromRootViewController: self)
            }
        })
        navigationItem.title = otherUser.username
        getHomePost()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        
        
    }
    init(currentUser : CurrentUser, otherUser : OtherUser , profileModel : ProfileModel) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.profileModel = profileModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -functions
    //MARK:- load home post helper
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
            guard let sself = self else { return }
            sself.lessonPostModel = post
            if sself.lessonPostModel.count > 0{
                if  let time_e = sself.lessonPostModel[(sself.lessonPostModel.count) - 1].postTime{
                    sself.time = sself.lessonPostModel[(sself.lessonPostModel.count) - 1].postTime
                    self?.lessonPostModel.sort(by: { (post, post1) -> Bool in
                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                    })
                    self?.collectionview.reloadData()
                }else{
                    sself.collectionview.reloadData()
                }
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
                    self.isLoadMoreHomePost = true
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
                sself.isHomePost = false
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
            }
        }
    }
    
    //MARK: - lesson post
    
    
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
        
        titleLbl.text = otherUser.username
    }
    
    
    func configureCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        
        collectionview.register(Profile_Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileId)
        
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: home_post_id)
        collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: home_post_data_id)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)

        
        view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
    }
    
    
}

extension OtherUserProfile : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isHomePost {
            return lessonPostModel.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if isHomePost {
            if lessonPostModel[indexPath.row].data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: home_post_id, for: indexPath) as! NewPostHomeVC
//                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = lessonPostModel[indexPath.row]
                
                return cell
            }else {
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.backgroundColor = .red
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isHomePost {
            let h = lessonPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            if lessonPostModel[indexPath.row].data.isEmpty{
               
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
            }else{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
            }
        }
        
        return CGSize(width: self.view.frame.width, height: view.frame.height - 225)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 285)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileId, for: indexPath) as! Profile_Header
        header.user = otherUser
        header.profileModel = profileModel
        header.profileHeaderDelegate = self
        return header
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if isHomePost {
            if lessonPostModel.count > 5 {
               
                if indexPath.item == lessonPostModel.count - 1 {
                    loadMoreHomePost { (val) in
                        
                    }
                }else{
                    self.isLoadMoreHomePost = false
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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


extension OtherUserProfile : ProfileHeaderMenuBarDelegate{
    
    func getMajorPost() {
        print("major post")
    }
    
    func getSchoolPost() {
        print("school post")
    }
    
    func getVayeAppPost() {
        print("vaye app post")
    }
    
    func getFavPost() {
        print("fav post")
    }
}
