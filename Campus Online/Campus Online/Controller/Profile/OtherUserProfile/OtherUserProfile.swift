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


private let cellID = "cell_text"
private let cellData = "cell_data"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"
class OtherUserProfile: UIViewController  {

    weak var delegate : OtherUserProfileHeaderDelegate?
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
    
    
    
//    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
    var adUnitID =   "ca-app-pub-1362663023819993/4203883052"
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        configureUI()
        configureCollectionView()
        getPost()
        interstitalAd = createAd()
        navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            if self.interstitalAd.isReady {
                self.interstitalAd.present(fromRootViewController: self)
            }
        })
    }
    
    init(currentUser : CurrentUser, otherUser : OtherUser) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -functions
    
    
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
        collectionview.anchor(top: headerBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
         }
    
     @objc func dissmis(){
         self.dismiss(animated: true, completion: nil)
     }
    
    //MARK:- selector
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
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
        
    }
    
    func like(for cell: NewPostHomeVCData) {
        
    }
    
    func dislike(for cell: NewPostHomeVCData) {
                
    }
    
    func fav(for cell: NewPostHomeVCData) {
            
    }
    
    func comment(for cell: NewPostHomeVCData) {
        
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        
    }
    
    func showProfile(for cell: NewPostHomeVCData) {
        
    }
    
    func goProfileByMention(userName: String) {
        
    }
    
    
}


extension OtherUserProfile : NewPostHomeVCDelegate{
    func options(for cell: NewPostHomeVC) {
            
    }
    
    func like(for cell: NewPostHomeVC) {
        
    }
    
    func dislike(for cell: NewPostHomeVC) {
        
    }
    
    func fav(for cell: NewPostHomeVC) {
        
    }
    
    func comment(for cell: NewPostHomeVC) {
        
    }
    
    func linkClick(for cell: NewPostHomeVC) {
        
    }
    
    func showProfile(for cell: NewPostHomeVC) {
        
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
