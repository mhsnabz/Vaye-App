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
    
    
    //MARK:-post filter val
    
    var isHomePost : Bool = false
    var isSchoolPost : Bool = false
    var isVayeAppPost : Bool = false
    
    
    var isLoadMoreHomePost : Bool = false
    var isLoadMoreSchoolPost : Bool = false
    var isLoadMoreVayeAppPost : Bool = false
    
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
    }
    
    func fetchLessonPost(otherUser : OtherUser, completion : @escaping([LessonPostModel])->Void){
        var post = [LessonPostModel]()
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
        
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
        cell.backgroundColor = .red
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
