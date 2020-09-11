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
private let cellID = "cell_image"
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
    //MARK:-properties
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
       
  
        return btn
    }()
   
    //MARK:- lifeCycle
    
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
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
            
        PostService.shared.fetchLessonPost(currentUser: self.currentUser) { (post) in
                               self.lessonPost = post
                               self.collectionview.reloadData()
                           }
    }
    
   
    fileprivate func configureUI(){
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .collectionColor()
        
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
//        collectionview.refreshControl?.isEnabled = true
        collectionview.register(NewPostHomeVC.self, forCellWithReuseIdentifier: cellID)
//        collectionview.alwaysBounceVertical = true
//        collectionview.refreshControl = refresher
//        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
//        refresher.tintColor = .white

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
    // /İSTE/lesson/Bilgisayar Mühendisliği
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewPostHomeVC
        cell.backgroundColor = .white
        
        let size = CGSize(width: view.frame.width , height: 1000)
        let atr = [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)]
        let estimadefFrame = NSString(string:lessonPost[indexPath.row].text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: atr as [NSAttributedString.Key : Any], context: nil)
//        cell.msgText.frame = CGRect(x: 70, y: 60, width: view.frame.width, height: estimadefFrame.height)
        cell.msgText.anchor(top:  cell.headerView.bottomAnchor, left:  cell.headerView.leftAnchor, bottom: nil, rigth: cell.headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: estimadefFrame.height)
        cell.bottomBar.anchor(top: nil, left: cell.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
        cell.msgText.backgroundColor = .red
        cell.headerView.backgroundColor = .blue
        cell.lessonPostModel = lessonPost[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: view.frame.width, height: 1000)
        let atr = [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)]
        let estimadefFrame = NSString(string:lessonPost[indexPath.row].text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: atr as [NSAttributedString.Key : Any], context: nil)
        
        return CGSize(width: view.frame.width, height: 60 + 8 + estimadefFrame.height + 4 + 30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
