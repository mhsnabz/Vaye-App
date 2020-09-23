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

private let cellID = "cell_text"
private let cellData = "cell_data"
private let cellAds = "cell_ads"
private let loadMoreCell = "cell_load_more"

import FirebaseFirestore
import FirebaseStorage
class ProfileVC: UIViewController {

    //MARK: - variables
    
    lazy var count : Int = 0
    lazy var sizeForItemAt : CGSize = .zero
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    lazy var homePost : Bool = true
    lazy var loadMore_HomePost : Bool = false
    
    lazy var schoolPost : Bool = false
    lazy var loadMore_schoolPost : Bool = false
    
    lazy var coPost : Bool = false
    lazy var loadMore_coPost : Bool = false

    lazy var favPost : Bool = false
    lazy var loadMore_favPost : Bool = false
    
    
    lazy var page_homePost : DocumentSnapshot? = nil
    lazy var page_schoolPost : DocumentSnapshot? = nil
    lazy var page_coPost : DocumentSnapshot? = nil
    lazy var page_favPost : DocumentSnapshot? = nil

    
    lazy var lessonPostModel = [LessonPostModel]()
    lazy var favPostModel = [LessonPostModel]()
    
    
    private var actionSheet : ActionSheetHomeLauncher
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    
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
    
   
    


    //MARK: - lifeCycle
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        self.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        configureUI()
        configureCollectionView()
        titleLbl.text = currentUser.username
        getPost()
    }
    
    
    //MARK:-functions
    
    //MARK: - lesson post
    func fetchLessonPost(currentUser : CurrentUser, completion : @escaping([LessonPostModel])->Void){

        var post = [LessonPostModel]()
      let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("my-post").limit(to: 5).order(by: "postId", descending: true)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion([])
                }else{
                    
                    for postId in snap.documents {
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
                                        .document(currentUser.uid).collection("my-post").document(postId.documentID)
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
    
    fileprivate func getPost(){
          
            lessonPostModel = [LessonPostModel]()
            loadMore_HomePost = true
            collectionview.reloadData()
            
            fetchLessonPost(currentUser: self.currentUser) {[weak self] (post) in
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
    fileprivate func getFavPost(){
          
            favPostModel = [LessonPostModel]()
            loadMore_favPost = true
            collectionview.reloadData()
            
            fetchFavPost(currentUser: self.currentUser) {[weak self] (post) in
            self?.favPostModel = post
//            self?.fetchAds()
                if self?.favPostModel.count ?? -1 > 0{
                    self?.collectionview.refreshControl?.endRefreshing()
                    if  let time_e = self?.favPostModel[(self?.favPostModel.count)! - 1].postTime{
                       
                        self?.favPostModel.sort(by: { (post, post1) -> Bool in
                            return post.postTime?.dateValue() ?? time_e.dateValue()  > post1.postTime?.dateValue() ??  time_e.dateValue()
                        })
                        self?.collectionview.reloadData()
                       
                    }
                }else{
                   
                    self?.collectionview.reloadData()
                }
        }
    }
    //MARK: - fav post
    
    fileprivate func fetchFavPost(currentUser : CurrentUser, completion : @escaping([LessonPostModel])->Void){
    var post = [LessonPostModel]()
        let db = Firestore.firestore().collection("user")
        .document(currentUser.uid).collection("fav-post").limit(to: 5).order(by: "postId", descending: true)
        db.getDocuments {(querySnap, err) in
        if err == nil {
            guard let snap = querySnap else { return }
            if snap.isEmpty {
                completion([])
            }else{
                
                for postId in snap.documents {
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
                                    .document(currentUser.uid).collection("my-post").document(postId.documentID)
                                deleteDb.delete()
                            }
                            completion(post)
                        }
                    }
                    
                }
                
                self.page_favPost = snap.documents.last
//                    self.fetchAds()
                self.loadMore_favPost = true
               
            }
            
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
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
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
    
    
    func configureUI(){
         view.backgroundColor = .white
         view.addSubview(headerBar)
        headerBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 60)
         dissmisButton.addTarget(self, action: #selector(dissmis), for: .touchUpInside)
     }
    
    func configureCollectionView(){
             let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
             collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
//        collectionview.contentInsetAdjustmentBehavior = .never
             collectionview.dataSource = self
             collectionview.delegate = self
             collectionview.backgroundColor = .white
             collectionview.register(ProfileCell.self, forCellWithReuseIdentifier: cellId)
            collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: cellID)
            collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: cellData)
        
        
        collectionview.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileId)
             view.addSubview(collectionview)
        collectionview.anchor(top: headerBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
         }
    
     @objc func dissmis(){
         self.dismiss(animated: true, completion: nil)
     }
   

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ProfileVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if homePost
        {
        count = lessonPostModel.count
        }else if schoolPost{
            
        }else if coPost {
            
        }else if favPost {
            count = favPostModel.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if homePost
        {
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
            
        }else if favPost
        {
            
            if favPostModel[indexPath.row].data.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewPostHomeVC
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = favPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = favPostModel[indexPath.row]
                
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NewPostHomeVCData
                
                cell.backgroundColor = .white
                cell.delegate = self
                cell.currentUser = currentUser
                let h = favPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
                
                cell.filterView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.lessonPostModel = favPostModel[indexPath.row]
                
                return cell
            }
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
            
        }else if favPost {
      
            if favPostModel[indexPath.row].text == nil {
                return .zero
            }
            let h = favPostModel[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            
            if favPostModel[indexPath.row].data.isEmpty{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
            }
            else{
                return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
            }
        }
        
       
        
        return CGSize(width: self.view.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 246)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileId, for: indexPath) as! ProfileHeader
        header.currentUser = currentUser
        header.delegate = self
        return header
    }
    
}
//MARK:- ProfileHeaderDelegate
extension ProfileVC : ProfileHeaderDelegate {
    
    func getMajorPost() {
        homePost = true
        schoolPost = false
        coPost = false
        favPost = false
        
        getPost()
    }
    
    func getSchoolPost() {
        homePost = false
        schoolPost = true
        coPost = false
        favPost = false
    }
    
    func getCoPost() {
        homePost = false
        schoolPost = false
        coPost = true
        favPost = false
    }
    
    func getFav() {
        homePost = false
        schoolPost = false
        coPost = false
        favPost = true
        getFavPost()
    }
    
    
}


extension ProfileVC : NewPostHomeVCDelegate {
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
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
        }
//        else{
//            Utilities.waitProgress(msg: nil)
//            actionOtherUserSheet.delegate = self
//            guard let  index = collectionview.indexPath(for: cell) else { return }
//            selectedIndex = index
//            selectedPostID = lessonPost[index.row].postId
//            getOtherUser(userId: post.senderUid) {[weak self] (user) in
//                guard let sself = self else { return }
//                Utilities.dismissProgress()
//                sself.actionOtherUserSheet.show(post: post, otherUser: user)
//
//            }
//        }
        
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
        print("comment click")
    }
    
    
}
extension ProfileVC : NewPostHomeVCDataDelegate {
    func options(for cell: NewPostHomeVCData) {
        guard  let post = cell.lessonPostModel else {
            return
        }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPostModel[index.row].postId
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
        
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        
    }
    
    func showProfile(for cell: NewPostHomeVCData) {
        
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
                    sself.deleteToStorage(data: sself.lessonPostModel[index.row].data, postId: postId, index: index) { (_val) in
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
    private func deleteToStorage(data : [String], postId : String , index : IndexPath , completion : @escaping(Bool) -> Void){
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
