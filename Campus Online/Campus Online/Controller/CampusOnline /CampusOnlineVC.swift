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
class CampusOnlineVC: UIViewController{
    var waitAnimation = AnimationView()
    var currentUser : CurrentUser
    weak var delegate : CoControllerDelegate?
    var isMenuOpen : Bool = false
    var mainPost = [MainPostModel]()
    var selectedIndex : IndexPath?
    var selectedPostID : String?
  
    lazy var followers = [String]()
    var collectionview: UICollectionView!
    var refresher = UIRefreshControl()
    var page : DocumentSnapshot? = nil
    var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    var nativeAdView: GADUnifiedNativeAdView!
    
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
        waitAnimation.play()
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView()
        
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        view.backgroundColor = .white
        navigationItem.title = "Takip Ettiklerin"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        checkHasFollowingAnyUser {[weak self] (_val) in
            guard let sself = self else { return }
            if _val{
                
            }else{
                sself.animationView()
            }
        }
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
    fileprivate func animationView() {
        waitAnimation = .init(name : "no-one-follow")
        waitAnimation.animationSpeed = 1
        waitAnimation.loopMode = .loop
        
        view.addSubview(waitAnimation)
        waitAnimation.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 20, marginRigth: 0, width: 0, heigth: 0)
        waitAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
        msg_text =  NSMutableAttributedString(string: "Hiç Kimseyi Takip Etmiyorsunuz\n", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        msg_text.append(NSAttributedString(string: "Takip Edebilceğin Kullanıcıları Bul", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
        label.attributedText = msg_text
        
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
    }
    fileprivate func configureUI(){
        waitAnimation.isHidden = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(BuyAndSellView.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(BuyAndSellDataView.self , forCellWithReuseIdentifier: cellData)
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
        
    }
}
extension CampusOnlineVC :  UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellAds, for: indexPath) as! FieldListLiteAdCell
        cell.nativeAd = mainPost[indexPath.row].nativeAd
        return cell
    }
    
    
}

