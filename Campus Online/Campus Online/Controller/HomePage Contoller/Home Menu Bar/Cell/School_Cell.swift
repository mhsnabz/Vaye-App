//
//  School_Cell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

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

class School_Cell: UICollectionViewCell {
    
    //MARK:- properites
    var refresher = UIRefreshControl()
    var collectionview: UICollectionView!

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
    let adUnitID = "ca-app-pub-1362663023819993/1801312504"
    weak var rootController : HOMEVC?
    var currentUser : CurrentUser?{
        didSet{
            getPost()
        }
    }
      var actionSheetOtherUser : ASNoticesPostLaunher?{
        didSet{
            collectionview.reloadData()
        }
    }
     var actionSheetCurrentUser : ASNoticesPostCurrentUserLaunher?{
        didSet{
            collectionview.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- functions
    private func configureUI(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
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
        
        getPost()
    }
    private func getPost(){
        guard let currentUser = currentUser else { return }
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
        guard let currentUser = currentUser else { return }
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
                    let db = Firestore.firestore().collection(currentUser.short_school)
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
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: rootController,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
    }
}


extension School_Cell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
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
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = mainPost[indexPath.row]
                return cell
            }else{
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NoticesDataCell
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: frame.width - 78, height: h + 4)
                
                cell.stackView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: frame.width - 78, height: 200)
                cell.onClickListener = self
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.noticesPost = mainPost[indexPath.row]
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
        if mainPost[indexPath.row].postId == nil {
            return CGSize(width: frame.width, height: 409)
        }
        else if mainPost[indexPath.row].empty == "empty"{
            return .zero
        }
        else{
            
            if mainPost[indexPath.row].text == nil {
                return .zero
            }
            let h = mainPost[indexPath.row].text.height(withConstrainedWidth: frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            
            if mainPost[indexPath.row].data.isEmpty{
                return CGSize(width: frame.width, height: 60 + 8 + h + 4 + 4 + 30 )
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
        
        
        if mainPost.count > 5 {
            
            if indexPath.item == mainPost.count - 1 {
                loadMorePost { (val) in
                    
                }
            }else{
                self.loadMore = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: mainPost[indexPath.row].postId, lessonPost: nil , noticesPost: mainPost[indexPath.row], mainPost: nil)
        
       
        rootController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension School_Cell  : GADUnifiedNativeAdLoaderDelegate, GADAdLoaderDelegate , GADUnifiedNativeAdDelegate {
    
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
extension School_Cell : NewPostNoticesVCDelegate {
    func options(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        guard let actionSheetOtherUser = actionSheetOtherUser else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) {(user) in

                Utilities.dismissProgress()
             actionSheetOtherUser.show(post: post, otherUser: user)
                
            }
        }
    }
    
    func like(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }
        NoticesService.shared.setPostLike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }

        NoticesService.shared.setDislike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }
        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: post, mainPost: nil)
        rootController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesCell) {
        guard  let post = cell.noticesPost else {
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
    
    func clickMention(username: String) {
        guard let currentUser = currentUser else { return }

        if "@\(username)" == currentUser.username {
            
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
    
    
}
extension School_Cell : NewPostNoticesDataVCDelegate{
    func options(for cell: NoticesDataCell) {
        guard let currentUser = currentUser else { return }
        guard let post = cell.noticesPost else { return }
        guard let actionSheetCurrentUser = actionSheetCurrentUser else { return }
        guard let actionSheetOtherUser = actionSheetOtherUser else { return }
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
        }
        else{
            Utilities.waitProgress(msg: nil)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = mainPost[index.row].postId
            UserService.shared.getOtherUser(userId: post.senderUid) { (user) in
              
                Utilities.dismissProgress()
               actionSheetOtherUser.show(post: post, otherUser: user)
                
            }
        }
    }
    
    func like(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }

        NoticesService.shared.setPostLike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("liked")
            
        }
    }
    
    func dislike(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }

        NoticesService.shared.setDislike( collectionview: collectionview, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func comment(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }
        guard let currentUser = currentUser else { return }

        let vc = MajorPostCommentController(currentUser: currentUser, postId: post.postId, lessonPost: nil, noticesPost: post, mainPost: nil)
        rootController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile(for cell: NoticesDataCell) {
        guard  let post = cell.noticesPost else {
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
    
    
}
//MARK:-ASMainPostLaungerDelgate
extension School_Cell : ASMainPostLaungerDelgate{
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        
        case .editPost(_):
            guard let index = selectedIndex else { return }
            guard let currentUser = currentUser else { return }
            if let h = collectionview.cellForItem(at: index) as? NoticesCell{
                let vc = EditNoticesPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
            }else if let h = collectionview.cellForItem(at: index) as? NoticesDataCell{
                let vc = EditNoticesPost(currentUser: currentUser, post: mainPost[index.row], h: h.msgText.frame.height)
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.rootController?.present(controller, animated: true, completion: nil)
            }
            break
        case .deletePost(_):
            guard let currentUser = currentUser else { return }
            Utilities.waitProgress(msg: "Siliniyor")
            guard let index = selectedIndex else { return }
            guard let postId = selectedPostID else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return }
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("notices")
                .collection("post")
                .document(postId)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil{
                    NoticesService.shared.deleteToStorage(data: sself.mainPost[index.row].data, postId: postId) { (_val) in
                        if _val{
                            Utilities.succesProgress(msg: "Silindi")
                        }else{
                            Utilities.errorProgress(msg: "Hata Oluştu")
                            
                        }
                    }
                }else{
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
            break
        case .slientPost(_):
            break
        }
    }
    
    
}
extension School_Cell : ShowNoticesAllDatas {
    func onClickListener(for cell: NoticesDataCell) {
        guard let post = cell.noticesPost else { return }

        guard let currentUser = currentUser else { return }
        guard let data = post.data else { return }
        let vc = AllDatasVC(arrayListUrl: data, currentUser: currentUser)
        self.rootController?.modalPresentationStyle = .fullScreen
        self.rootController?.present(vc, animated: true, completion: nil)
    }
    
    
}
