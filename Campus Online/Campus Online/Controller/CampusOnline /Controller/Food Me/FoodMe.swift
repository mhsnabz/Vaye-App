//
//  FoodMe.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 8.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
import FirebaseFirestore
class FoodMe: UIViewController {
    var topic : String =  "food-me"
    var currentUser : CurrentUser
    
    //MARK:-properties
    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
    
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
        navigationItem.title = "Food Me"

        
    }
    init(currentUser : CurrentUser  ){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        
        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Food Me"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .collectionColor()
        configure()
        MainPostService.shared.checkFollowTopic(currentUser: currentUser, topic: topic) {[weak self] (_val) in
            guard let sself = self else { return }
            sself.setNavigationBarItems(val: _val)
        }
        
    }
    
    
    //MARK:-functions
    fileprivate func configure(){
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
    }
    fileprivate  func setNavigationBarItems(val : Bool) {
        if val {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(#imageLiteral(resourceName: "bell-selected"), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(enableNotification), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.setImage(#imageLiteral(resourceName: "info"), for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn2.addTarget(self, action: #selector(aboutPage), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: btn2)
            self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
            
        }else{
            let btn1 = UIButton(type: .custom)
            btn1.setImage(#imageLiteral(resourceName: "not"), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(enableNotification), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.setImage(#imageLiteral(resourceName: "info"), for: .normal)
            btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn2.addTarget(self, action: #selector(aboutPage), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: btn2)
            self.navigationItem.setRightBarButtonItems([item2,item1], animated: true)
            
        }
        
        
        
    }
    
    private func followTopic(currentUser : CurrentUser, topic : String , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        MainPostService.shared.checkFollowTopic(currentUser: currentUser, topic: topic) { [weak self] (_val) in
            guard let sself = self else { return }
            if _val{
                ///main-post/sell-buy/post/1603292156873
                
                let db = Firestore.firestore().collection("main-post")
                    .document(topic)
                    .collection("followers")
                    .document(currentUser.uid)
                db.delete { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Kapandı")
                        sself.setNavigationBarItems(val: false)
                    }
                }
            }else{
                
                let db = Firestore.firestore().collection("main-post")
                    .document(topic)
                    .collection("followers").document(currentUser.uid)
                
                db.setData(["userId":currentUser.uid as Any , "school":currentUser.short_school as Any] as [String : Any], merge: true) { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Açıldı")
                        sself.setNavigationBarItems(val: true)
                    }
                }
            }
        }
        
    }
    
    
    
    //MARK: -selectors
    @objc func enableNotification(){
        followTopic(currentUser: currentUser , topic : topic) { (_) in
            print("succes")
        }
    }
    @objc func aboutPage(){
        print("about")
    }
    @objc func newPost(){
        Utilities.waitProgress(msg: nil)
        UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (currentUserFollowers) in
            guard let sself = self else { return }
            let vc = SetNewFoodMePost(currentUser : sself.currentUser, currentUserFollowers: currentUserFollowers)
            sself.navigationController?.pushViewController(vc, animated: true)
            Utilities.dismissProgress()
            
        }
        
    }
    
}
