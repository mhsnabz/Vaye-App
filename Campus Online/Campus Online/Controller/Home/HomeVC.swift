//
//  HomeVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
private let cellID = "cell_text"
private let cellData = "cell_data"
class HomeVC: UIViewController {
    
    //MARK: -variables
    var centerController : UIViewController!
    var delegate : HomeControllerDelegate?
    var currentUser : CurrentUser
    var isMenuOpen : Bool = false
    var barTitle : String?
    var menu = UIButton()
    var collectionview: UICollectionView!
    var lessonPost = [LessonPostModel]()
    var refresher = UIRefreshControl()
    var listenerRegistiration : ListenerRegistration?
      private var actionSheet : ActionSheetHomeLauncher
    var selectedIndex : IndexPath?
    var selectedPostID : String?
    //MARK:-properties
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        
        
        return btn
    }()
    
    let newAdded : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 11)
        btn.setTitle("Yeni Gönderiler", for: .normal)
        //        btn.layer.borderColor = UIColor.black.cgColor
        //        btn.layer.borderWidth = 0.75
        btn.backgroundColor = .white
        btn.tintColor = .black
        btn.setTitleColor(.black, for: .normal)
        
        return btn
    }()
    
    //MARK:- lifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenNewPost(currentUser: currentUser) {[weak self] (isNew) in
            if isNew {
                self?.newAdded.isHidden = false
            }
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.listenerRegistiration?.remove()
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        self.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(setLessons))
        } else {
            let rigthBtn = UIBarButtonItem(image: UIImage(named: "menu")!, style: .plain, target: self, action: #selector(menuClick))
            let leftBtn = UIBarButtonItem(image: UIImage(named: "plus")!, style: .plain, target: self, action: #selector(setLessons))
            navigationItem.leftBarButtonItem = rigthBtn
            navigationItem.rightBarButtonItem = leftBtn
        }
        navigationItem.title = currentUser.bolum
        setNavigationBar()
        UserService.shared.fetchUser {[weak self] (currentUser) in
            self?.currentUser = currentUser
        }
        
        configureUI()
        view.backgroundColor = .collectionColor()
        getPost()
        
        
        
    }
    //MARK: - functions
    
    fileprivate func getPost(){
        
        PostService.shared.fetchLessonPost(currentUser: self.currentUser) {[weak self] (post) in
            self?.lessonPost = post
            self?.lessonPost.sort(by: { (post, post1) -> Bool in
                return post.postTime.dateValue() > post1.postTime.dateValue()
            })
            self?.collectionview.reloadData()
            self?.newAdded.isHidden = true
        }
        
    }
    
    
    fileprivate func configureUI(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        
        //        collectionview.refreshControl?.isEnabled = true
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: cellID)
        collectionview.register(NewPostHomeVCData.self, forCellWithReuseIdentifier: cellData)
        collectionview.alwaysBounceVertical = true
        collectionview.refreshControl = refresher
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refresher.tintColor = .white
        
        view.addSubview(newAdded)
        newAdded.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 125, heigth: 40)
        newAdded.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        newAdded.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        newAdded.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        newAdded.layer.shadowOpacity = 1.0
        newAdded.layer.shadowRadius = 5.0
        newAdded.layer.masksToBounds = false
        newAdded.layer.cornerRadius = 20
        newAdded.addTarget(self, action: #selector(loadData), for: .touchUpInside)
        newAdded.isHidden = true
        
    }
    func stopRefresher() {
        
    }
    //MARK:-selectors
    @objc func loadData(){
        collectionview.refreshControl?.beginRefreshing()
        getPost()
        collectionview.refreshControl?.endRefreshing()
        
    }
    
    @objc func newPost(){
        
        let vc = ChooseLessonTB(currentUser: currentUser)
        centerController = UINavigationController(rootViewController: vc)
        centerController.modalPresentationStyle = .fullScreen
        self.present(centerController, animated: true, completion: nil)
        
    }
    @objc func setLessons(){
        
        let vc = LessonList(currentUser: currentUser)
        vc.currentUser = currentUser
        vc.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    @objc func menuClick(){
        self.delegate?.handleMenuToggle(forMenuOption: nil)
        if !isMenuOpen {
            self.isMenuOpen = false
        }
        else{
            self.isMenuOpen = true
            
        }    
    }
    
    private func listenNewPost(currentUser : CurrentUser , completion : @escaping(Bool)->Void){
        let db = Firestore.firestore().collection("user").document(currentUser.uid)
            .collection("lesson-post")
        listenerRegistiration = db.addSnapshotListener { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documentChanges else { return }
                snap.forEach({ (diff) in
                    
                    if (diff.type == .added) {
                        completion(true)
                    }
                    else if (diff.type == .modified) {
                        
                    }
                    else if (diff.type == .removed) {
                        
                    }
                })
            }
        }
    }
    
    private func getBolumName(fakulteName : String){
        
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("fakulte").collection("fakulte").document(fakulteName)
        db.getDocument { (docSnap, err) in
            if err == nil {
                let children = docSnap!.data()
                for (_, value) in children! {
                    let db = Firestore.firestore().collection("İSTE")
                        .document("lesson").collection(value as! String)
                    db.addDocument(data: ["data":"data"])
                    
                }
                
                
            }
        }
    }
    
}

extension HomeVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonPost.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if lessonPost[indexPath.row].data.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewPostHomeVC
            cell.delegate = self
            cell.backgroundColor = .white
            let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.lessonPostModel = lessonPost[indexPath.row]
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellData, for: indexPath) as! NewPostHomeVCData
            
            cell.backgroundColor = .white
            cell.delegate = self
            let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
            
            cell.filterView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: cell.msgText.frame.width, height: 100)
            
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.lessonPostModel = lessonPost[indexPath.row]
            
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let h = lessonPost[indexPath.row].text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
        
        if lessonPost[indexPath.row].data.isEmpty{
            return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 30)
        }else{
            return CGSize(width: view.frame.width, height: 60 + 8 + h + 4 + 4 + 100 + 30)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension HomeVC : NewPostHomeVCDataDelegate {
    func options(for cell: NewPostHomeVCData) {
        guard let post = cell.lessonPostModel else { return }
        if cell.lessonPostModel?.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            guard let  index = collectionview.indexPath(for: cell) else { return }
            selectedIndex = index
            selectedPostID = lessonPost[index.row].postId
        }else{
            
        }
        
    }
    
    func like(for cell: NewPostHomeVCData) {
        cell.like.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func dislike(for cell: NewPostHomeVCData) {
        cell.dislike.setImage(UIImage(named: "dislike-selected")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func fav(for cell: NewPostHomeVCData) {
        cell.addfav.setImage(UIImage(named: "fav-selected")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func comment(for cell: NewPostHomeVCData) {
        print("comment")
    }
    
    func linkClick(for cell: NewPostHomeVCData) {
        guard let url = URL(string: (cell.lessonPostModel?.link)!) else {
            return
        }
        UIApplication.shared.open(url)          
    }
    
    
}

extension HomeVC : NewPostHomeVCDelegate {
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
            selectedPostID = lessonPost[index.row].postId
        }else{
            
        }
        
    }
    
    func like(for cell: NewPostHomeVC) {
        cell.like.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func dislike(for cell: NewPostHomeVC) {
        cell.dislike.setImage(UIImage(named: "dislike-selected")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func fav(for cell: NewPostHomeVC) {
        cell.addfav.setImage(UIImage(named: "fav-selected")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func comment(for cell: NewPostHomeVC) {
        print("comment click")
    }
    
    
}
extension HomeVC : ActionSheetHomeLauncherDelegate{
    func didSelect(option: ActionSheetHomeOptions) {
        switch option {  
        case .editPost(_):
            print("Edit Post Click ")
        case .deletePost(_):
            Utilities.waitProgress(msg: "Siliniyor")
            guard let postId = selectedPostID else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return }
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post")
                .collection("post")
                .document(postId)
            db.delete {[weak self] (err) in
                if err == nil {
                    self?.getPost()
                    Utilities.succesProgress(msg: "Silindi")
                }else{
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
        case .slientPost(_):
            print("slient")
        }
    }
    
    
}
extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.firstIndex(of: element) {
            self.remove(at: i)
        }
    }
}
