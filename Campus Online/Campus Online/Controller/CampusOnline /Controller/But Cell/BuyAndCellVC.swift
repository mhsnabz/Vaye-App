//
//  BuyAndCellVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 8.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
import FirebaseFirestore
class BuyAndCellVC: UIViewController {

    var currentUser : CurrentUser
    var waitAnimation = AnimationView()
    lazy var followers = [String]()
    
    
    
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
//    MARK: -lifeCycle
    init(currentUser : CurrentUser){
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
        navigationItem.title = "Al - Sat"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        animationView()
        
        UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (user) in
            if let sself = self {
                sself.followers = user
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        waitAnimation.play()
        checkFollowingTopic(currentUser: currentUser) { [weak self] (_val) in
            guard let sself = self else { return }
            sself.setNavigationBarItems(val: _val)
        }
    }
    //MARK:-functions
    fileprivate func animationView() {
        waitAnimation = .init(name : "cell")
        waitAnimation.animationSpeed = 1
        waitAnimation.loopMode = .loop
        
        view.addSubview(waitAnimation)
        waitAnimation.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 20, marginRigth: 0, width: 0, heigth: 0)
        waitAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
        msg_text =  NSMutableAttributedString(string: "Yakınlarda Yeni Bir İlan Yok\n", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        msg_text.append(NSAttributedString(string: "Hemen Bir İlan Ver", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.black ]))
        label.attributedText = msg_text
        
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
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
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
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
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
        }
        
            
    }

  
    
    
    private func checkFollowingTopic(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        //İSTE/sell-buy/followers/StTsYlJUVX4zOUzhRzXt
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("sell-buy").collection("followers").document(currentUser.uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return
                }
                if snap.exists{
                    completion(true)
                }
                else{
                    completion(false)
                }
            }else{
                completion(false)
            }
        }
    }
    private func followTopic(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        checkFollowingTopic(currentUser: currentUser) {[weak self] (_val) in
            guard let sself = self else { return }
            
            if _val{
                let db = Firestore.firestore().collection(currentUser.short_school)
               .document("sell-buy").collection("followers").document(currentUser.uid)
                db.delete { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Kapandı")
                        sself.setNavigationBarItems(val: false)
                    }
                }
            }else{
                 let db = Firestore.firestore().collection(currentUser.short_school)
                .document("sell-buy").collection("followers").document(currentUser.uid)
            db.setData(["userId":currentUser.uid as Any] as [String : Any], merge: true) { (err) in
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
        followTopic(currentUser: currentUser) { (_) in
            print("succes")
        }
    }
    @objc func aboutPage(){
        print("about")
    }
    @objc func newPost(){
        Utilities.waitProgress(msg: nil)
        SellBuyService.shared.getTopicFollowers(currentUser: currentUser) {[weak self] (user) in
            guard let sself = self else { return }
            UserService.shared.getFollowers(uid: sself.currentUser.uid) { (currentUserFollowers) in
                let vc = SetNewBuySellVC(currentUser : sself.currentUser, followers : user , currentUserFollowers: currentUserFollowers)
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
            }
            
        }
      
    }

}
