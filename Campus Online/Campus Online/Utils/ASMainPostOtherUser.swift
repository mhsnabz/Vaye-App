//
//  ASMainPostOtherUser.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//
import UIKit
import FirebaseFirestore
class ASMainPostOtherUser : NSObject {
    //MARK: -properties
    private let currentUser : CurrentUser
    private let target : String
    weak var dismisDelegate : DismisDelegate?
    private var otherUser : OtherUser?{
        didSet{
            guard let user = otherUser else { return }
            UserService.shared.checkFollowers(currentUser: currentUser, otherUser: user.uid) {[weak self] (val) in
                guard let sself = self else { return }
                sself.isFallowingUser = val
                sself.tableView.reloadData()
            }
        }
    }
    private lazy var viewModel = ASMainPostOtherUserVM(currentUser: currentUser, target: target)
    private let tableView = UITableView()
    weak var delegate : ASMainOtherUserDelegate?

    private var window : UIWindow?
    private var tableViewHeight : CGFloat?
    var post : MainPostModel?
    lazy var lessonIsSlient : Bool = true
    lazy var postIsSlient : Bool = false
    lazy var userIsSlient : Bool = false
    lazy var isFallowingUser : Bool = false
    weak var centrelController : UIViewController!
    private lazy var cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Vazgeç", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.backgroundColor = .cancelColor()
        button.titleLabel?.font = UIFont(name: Utilities.font, size: 18)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    private lazy var footerView : UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 0)
        cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cancelButton.layer.cornerRadius = 20
        return view
    }()
    private lazy var blackView : UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tap)
        return view
    }()
    lazy var fallowBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Yükleniyor", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.75
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(fallowUser), for: .touchUpInside)
        return btn
    }()
    init(currentUser : CurrentUser , target : String) {
        self.currentUser = currentUser
        self.target = target
        super.init()
        configureTableView()
    }
    
    //MARK:- functions
    func show(post : MainPostModel , otherUser : OtherUser){
        self.post = post
        self.otherUser = otherUser
        self.tableView.reloadData()
        guard let window = UIApplication.shared.windows.first(where: { ($0.isKeyWindow)}) else { return }
        self.window = window
        window.addSubview(blackView)
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        let heigth = CGFloat( viewModel.imageOptions.count * 50 ) + 60
        self.tableViewHeight = heigth
        tableView.frame = CGRect(x: 0, y: window.frame.height,
                                 width: window.frame.width, height: heigth)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.tableView.frame.origin.y -= heigth
        }
        
    }
   
    func configureTableView()
    {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        tableView.register(ASMainPostOtherUserCell.self, forCellReuseIdentifier: "id")
        
    }
   
    //main-post/post/post/1607266298521
    private func setPostSlient(post : MainPostModel?,completion : @escaping(Bool) ->Void){
        guard let post = post else { return }
        ///main-post/sell-buy/post/1604436850197
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection("main-post")
            .document("post")
            .collection("post")
            .document(post.postId)
        db.updateData(["silent":FieldValue.arrayUnion([currentUser.uid as Any])]) {[weak self] (err) in
            guard let sself = self else {
                Utilities.dismissProgress()
                return}
            if err == nil {
          
                sself.postIsSlient = true
                sself.post?.silent.append(sself.currentUser.uid)
                completion(true)
                sself.tableView.reloadData()
            }else{
           
                sself.postIsSlient = false
                sself.post?.silent.remove(element : sself.currentUser.uid)
                completion(false)
                sself.tableView.reloadData()
            }
        }
    
    }
    private func setNotPostSlient(post: MainPostModel? ,completion : @escaping(Bool) ->Void){
        guard let post = post else { return }
        ///main-post/sell-buy/post/1604436850197
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection("main-post")
            .document("post")
            .collection("post")
            .document(post.postId)
        db.updateData(["silent":FieldValue.arrayRemove([currentUser.uid as Any])])  {[weak self] (err) in
            guard let sself = self else {
                Utilities.dismissProgress()
                return}
            if err == nil {
              
                sself.postIsSlient = false
                 sself.post?.silent.remove(element : sself.currentUser.uid)
                completion(false)

            }else{
               
                sself.postIsSlient = true
                sself.post?.silent.append(sself.currentUser.uid)
                completion(true)

            }
        }
    
    }
    private func setUserSlient(slientUser : [String], otherUserUid : String ,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user").document(otherUserUid)
        db.updateData(["slient":FieldValue.arrayUnion([currentUser.uid as Any])]) {[weak self] (err) in
            guard let sself = self else {
                           Utilities.dismissProgress()
                           return}
                       if err == nil {
                   
                           sself.userIsSlient = true
                        sself.otherUser?.slientUser.append(sself.currentUser.uid)
                           completion(true)
                           sself.tableView.reloadData()
                       }else{
                        
                           sself.userIsSlient = false
                           sself.otherUser?.slientUser.remove(element : sself.currentUser.uid)
                           completion(false)
                           sself.tableView.reloadData()
                       }
        }
    }
    
    private func setUserNotSlient(slientUser : [String], otherUserUid : String ,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user").document(otherUserUid)
        db.updateData(["slient":FieldValue.arrayRemove([currentUser.uid as Any])]) {[weak self] (err) in
                   guard let sself = self else {
                                  Utilities.dismissProgress()
                                  return}
                              if err == nil {
                                  
                                  sself.userIsSlient = false
                                    sself.otherUser?.slientUser.remove(element : sself.currentUser.uid)
                                  completion(false)
                                  sself.tableView.reloadData()
                              }else{
                                  sself.userIsSlient = true
                                    sself.otherUser?.slientUser.append(sself.currentUser.uid)
                                  completion(true)
                                  sself.tableView.reloadData()
                              }
               }
    }
    private func checkIamSlient(slientUser : [String] , completion : @escaping(Bool) ->Void){
        if slientUser.isEmpty{
            userIsSlient = false
            completion(false)
            return
        }
        if slientUser.contains(currentUser.uid){
                  userIsSlient = true
            completion(true)
        }else{
                  userIsSlient = false
            completion(false)
        }
    }
    fileprivate  func showTableView(_ shouldShow : Bool)
    {
        guard let window = window else { return }
        guard let heigth = tableViewHeight else { return }
        let y = shouldShow ? window.frame.height - heigth : window.frame.height
        tableView.frame.origin.y = y
        
        if !shouldShow {
            self.blackView.removeFromSuperview()
        }
        
    }
    //MARK: -selectors
    @objc func fallowUser(){
        Utilities.waitProgress(msg: "")
        guard let user = otherUser else { return }
        if isFallowingUser{
            let db = Firestore.firestore().collection("user")
                .document(user.uid).collection("fallowers").document(currentUser.uid)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    
                    UserService.shared.checkFollowers(currentUser: sself.currentUser, otherUser: sself.otherUser!.uid) { (val) in
                        sself.isFallowingUser = val
                        sself.tableView.reloadData()
                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                        .collection("following").document(sself.otherUser!.uid)
                    db.delete { (err) in
                        if err == nil {
                            UserService.shared.removeFromFriendList(currentUserUid: sself.currentUser, otherUserUid: sself.otherUser!)
                            Utilities.succesProgress(msg: "Takip Etmeyi Bıraktınız ")
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                
                
                }
            }
        }else{
            let db = Firestore.firestore().collection("user")
                .document(user.uid).collection("fallowers").document(currentUser.uid)
            db.setData(["user":currentUser.uid as Any] as [String:Any], merge: true) {[weak self] (err) in
                if err == nil {
                    guard let sself = self else { return }
                
                    UserService.shared.checkFollowers(currentUser: sself.currentUser, otherUser: sself.otherUser!.uid) { (val) in
                        sself.isFallowingUser = val
                        sself.tableView.reloadData()
                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(sself.currentUser.uid)
                        .collection("following").document(sself.otherUser!.uid)
                  
                    db.setData(["user":sself.otherUser!.uid as Any], merge: true) { (err) in
                        if err == nil{
                            UserService.shared.addAsMessagesFriend(currentUserUid: sself.currentUser, otherUserUid: sself.otherUser! )
                            Utilities.succesProgress(msg: "Takip Ediliyor")
                            FollowNotificationService.shared.followingNotification(postType: NotificationPostType.follow.name, currentUser: sself.currentUser, otherUser: sself.otherUser!, text: FollowNotification.follow_you.desp, type: FollowNotification.follow_you.type)
                          
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                  
                }
            }
        }
        
    }
    @objc  func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            let heigth = CGFloat( self.viewModel.imageOptions.count * 50 ) + 60
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += heigth
            self.dismisDelegate?.dismisMenu()
            
        }
    }
}
extension ASMainPostOtherUser : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id",for: indexPath) as! ASMainPostOtherUserCell
        cell.options = viewModel.imageOptions[indexPath.row]
        
        if cell.titleLabel.text == ASMainPostOtherUserOptions.fallowUser(currentUser).description{
           
            cell.titleLabel.text = otherUser!.username
            cell.logo.layer.cornerRadius = 25 / 2
            cell.logo.sd_setImage(with: URL(string: otherUser!.thumb_image))
            cell.logo.layer.borderColor = UIColor.lightGray.cgColor
            cell.logo.layer.borderWidth = 0.75
            cell.addSubview(fallowBtn)
            fallowBtn.anchor(top: nil, left: nil
                , bottom: nil, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 125, heigth: 25)
            fallowBtn.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            if isFallowingUser{
                fallowBtn.setTitle("Takibi Bırak", for: .normal)
                fallowBtn.setBackgroundColor(color: .red, forState: .normal)
                fallowBtn.setTitleColor(.white, for: .normal)
                fallowBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
                fallowBtn.layer.borderColor = UIColor.red.cgColor
            }else{
                fallowBtn.setTitle("Takip Et", for: .normal)
                fallowBtn.setBackgroundColor(color: .mainColor(), forState: .normal)
                fallowBtn.setTitleColor(.white, for: .normal)
                fallowBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
                fallowBtn.layer.borderColor = UIColor.mainColor().cgColor
            }
            
        }
        else  if cell.titleLabel.text == ASMainPostOtherUserOptions.reportUser(currentUser).description{
            cell.titleLabel.textColor = .red
            cell.titleLabel.font = UIFont(name: Utilities.fontBold, size: 13)
        }
        else if cell.titleLabel.text == ASMainPostOtherUserOptions.reportPost(currentUser).description { }
     
        
        else if cell.titleLabel.text == ASMainPostOtherUserOptions.slientUser(currentUser).description{

            if otherUser?.slientUser != nil {
                checkIamSlient(slientUser: otherUser!.slientUser) { (val) in
                    if val {
                        cell.titleLabel.text = "Kullanıcıyı Sessizden Al"
                        cell.logo.image = #imageLiteral(resourceName: "mute-user").withRenderingMode(.alwaysOriginal)
                    }else{
                        cell.titleLabel.text = ActionSheetOtherUserOptions.slientUser(self.currentUser).description
                        cell.logo.image = #imageLiteral(resourceName: "loud-user").withRenderingMode(.alwaysOriginal)
                    }
                }
            }
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.cellForRow(at: indexPath) as! ASMainPostOtherUserCell
        if indexPath.row == 2 {
           //FIXME: Report Post
        }else if indexPath.row == 1 {
          //FIXME: slient post
            if postIsSlient {
                setNotPostSlient(post: post) { (_) in
                    Utilities.dismissProgress()
                    tableView.reloadData()
                }
            }
            else{
                setPostSlient(post: post) { (_) in
                    Utilities.dismissProgress()
                    tableView.reloadData()
                }
            }
            
        }else if indexPath.row == 3 {
            //FIXME: Slient sender user
            if userIsSlient {
                setUserNotSlient(slientUser: otherUser?.slientUser ?? [], otherUserUid: otherUser!.uid) { (_) in
                    Utilities.dismissProgress()
                    tableView.reloadData()
                }
            }else{
                setUserSlient(slientUser: otherUser?.slientUser ?? [], otherUserUid: otherUser!.uid) { (_) in
                    Utilities.dismissProgress()
                    tableView.reloadData()
                }
            }
        }
        else if indexPath.row == 4 {
            //FIXME: report user
        }
    
        dismissTableView(indexPath)
    }
    fileprivate func dismissTableView(_ indexPath: IndexPath) {
        let option = viewModel.imageOptions[indexPath.row]
           delegate?.didSelect(option: option)
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.showTableView(false)
        }) { (_) in
            self.tableView.reloadData()
//            self.delegate?.didSelect(option: option)
        }
    }
}
