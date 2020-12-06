//
//  NoticesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import UIKit
import FirebaseFirestore
import GoogleMobileAds
import SDWebImage
import FirebaseStorage
private let cellID = "cellID"
private let cellData = "cellData"
private let loadMoreCell = "loadmorecell"
private let cellAds = "cellAds"
private let emptyCell = "empty_cell"
class NoticesVC: UIViewController {
    
    //MARK:- properites
    var collectionview: UICollectionView!
    
    var delegate : HomeControllerDelegate?
    var isMenuOpen : Bool = false
    var refresher = UIRefreshControl()
    var page : DocumentSnapshot? = nil
    var loadMore : Bool = false
    var lastDocumentSnapshot: DocumentSnapshot!
    var adLoader: GADAdLoader!
    var time : Timestamp!
    var nativeAdView: GADUnifiedNativeAdView!
    var nativeAd: GADUnifiedNativeAd?
    weak var notificaitonListener : ListenerRegistration?
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    var mainPost = [NoticesMainModel]()
    let adUnitID = "ca-app-pub-3940256099942544/2521693316"
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
    
    
    var currentUser : CurrentUser
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
       
        setNavigationBar()
        navigationItem.title = currentUser.short_school + " Kulüp"
        
        configureUI()
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- functions
    private func configureUI(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .collectionColor()
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collectionview.register(NoticesCell.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(NoticesDataCell.self, forCellWithReuseIdentifier: cellData)
        collectionview.register(FieldListLiteAdCell.self,forCellWithReuseIdentifier : cellAds)
        collectionview.register(LoadMoreCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreCell)
        collectionview.register(EmptyCell.self, forCellWithReuseIdentifier: emptyCell)

        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        collectionview.refreshControl?.beginRefreshing()
        
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        getPost()
    }
    //MARK:-functions
    func getPost(){
        mainPost = [NoticesMainModel]()
        loadMore = true
        collectionview.reloadData()
        fetchMainPost(currentUser: currentUser) {[weak self] (post) in
    
            self?.mainPost = post
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
    //İSTE/notices/post
    func fetchMainPost(currentUser : CurrentUser, completion : @escaping([NoticesMainModel])->Void){
        collectionview.refreshControl?.beginRefreshing()
        var post = [NoticesMainModel]()
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post").limit(to: 5)
            .order(by: "postId",descending: true)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    
                    for postId in snap.documents {
                        let db = Firestore.firestore().collection(currentUser.short_school)
                            .document("notices")
                            .collection("post").document(postId.documentID)
                        db.getDocument { (docSnap, err) in
                            if err == nil {
                                guard let snap = docSnap else { return }
                                if snap.exists{
                                    post.append(NoticesMainModel.init(postId: snap.documentID, dic: snap.data()!))
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
        
        guard let pagee = page else {
            loadMore = false
            collectionview.reloadData()
            completion(false)
            return }
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post").limit(to: 5)
            .order(by: "postId",descending: true).start(afterDocument: pagee)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            guard let snap = querySnap else { return }
            if let err = err {
                print("\(err.localizedDescription)")
            }else if snap.isEmpty {
                sself.loadMore = false
                sself.collectionview.reloadData()
                completion(false)
            
            }else{
                for item in snap.documents{
                    let db = Firestore.firestore().collection(sself.currentUser.short_school)
                        .document("notices")
                        .collection("post").document(item.documentID)
                    db.getDocument { (docSnap, err) in
                        if err == nil {
                            guard let snapp = docSnap else { return }
                            if snapp.exists{
                                sself.mainPost.append(NoticesMainModel.init(postId: snapp.documentID, dic: snapp.data()))
                                if  let time_e = sself.mainPost[(sself.mainPost.count) - 1].postTime{
                                    sself.time = sself.mainPost[(sself.mainPost.count) - 1].postTime
                                    sself.mainPost.sort(by: { (post, post1) -> Bool in
                                        return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                                    })
                                    sself.loadMore = true
                                    sself.collectionview.reloadData()
                                    completion(true)
                            }else{
                                
                            }
                        }
                    }
                    sself.page = snap.documents.last
                }
                }
                sself.fetchAds()
            }
        }

    }
    
    
    
    func fetchAds() {
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    //MARK:-selector
    @objc func newPost(){
       
        let vc = ChooseClub(currentUser: currentUser, dataSource: NoticesService.shared.getHastag(currentUser: currentUser))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
    }
    
     @objc func menuClick(){
        print("deneme")
//        dismiss(animated: true, completion: nil)
            self.delegate?.handleMenuToggle(forMenuOption: nil)
            if !isMenuOpen {
                self.isMenuOpen = false
            }
            else{
             self.isMenuOpen = true

         }
        }

}

extension NoticesVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainPost.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

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
            if mainPost[indexPath.row].data.isEmpty {
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NoticesCell
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = mainPost[indexPath.row]
                return cell
            }else{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NoticesDataCell
                
//                cell.backgroundColor = .white
//                cell.delegate = self
//                cell.currentUser = currentUser
//                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
//                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
//
//                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
//
//                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
//                cell.mainPost = mainPost[indexPath.row]
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
            return CGSize(width: view.frame.width, height: 50)
        }else{
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if mainPost[indexPath.row].postId == nil {
            return CGSize(width: view.frame.width, height: 409)
        }
        else if mainPost[indexPath.row].empty == "empty"{
            return .zero
        }
        else{
            
            if mainPost[indexPath.row].text == nil {
                return .zero
            }
            let h = mainPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            
            if mainPost[indexPath.row].data.isEmpty{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30 )
            }
            else{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
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

//MARK:- google ads
extension NoticesVC  : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
      
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        self.mainPost.append(NoticesMainModel.init(empty: "empty", postId: "empty"))
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
                
                self.mainPost.append(NoticesMainModel.init(nativeAd: nativeAd , postTime : self.mainPost[(self.mainPost.count) - 1].postTime!))
            }
        }
        self.loadMore = false
        self.collectionview.reloadData()
    }
}
 //MARK:-NewPostNoticesVCDelegate
extension NoticesVC : NewPostNoticesVCDelegate {
    func options(for cell: NoticesCell) {
        
    }
    
    func like(for cell: NoticesCell) {
        
    }
    
    func dislike(for cell: NoticesCell) {
        
    }
    
    func comment(for cell: NoticesCell) {
        
    }
    
    func showProfile(for cell: NoticesCell) {
        
    }
    
    func goProfileByMention(userName: String) {
        
    }
    
    func clickMention(username: String) {
    
    }
    
    
}
