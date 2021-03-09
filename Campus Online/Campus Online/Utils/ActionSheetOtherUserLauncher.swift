//
//  ActionSheetOtherUserLauncher.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
class ActionSheetOtherUserLaunher : NSObject{
    //MARK: -properties
    weak var dismisDelgate : DismisDelegate?
    private let currentUser : CurrentUser
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
    private let target : String
    private let tableView = UITableView()
    private var window : UIWindow?
    private lazy var viewModel = ActionSheetHomeOtherUserViewModel(currentUser: currentUser, target: target)
    weak var delegate : ActionSheetOtherUserLauncherDelegate?
    private var tableViewHeight : CGFloat?
    var post : LessonPostModel?
    lazy var isFallowingLesson : Bool = false
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
    let image : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.75
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.backgroundColor = .lightGray
        return img
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
    
    init(currentUser : CurrentUser , target : String ) {
        self.currentUser = currentUser
        self.target = target
        super.init()
        configureTableView()

    }
    //MARK:- helper
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
    
    func show(post : LessonPostModel , otherUser : OtherUser){
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
        tableView.register(ActionOtherUserCell.self, forCellReuseIdentifier: "id")
        
    }
    @objc  func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            let heigth = CGFloat( self.viewModel.imageOptions.count * 50 ) + 60
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += heigth
            self.dismisDelgate?.dismisMenu()
        }
    }
    private func addSlient(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post")
            .collection("post")
            .document(post!.postId)
        db.updateData(["silent":FieldValue.arrayUnion([currentUser.uid as Any])]) { (err) in
            if err == nil {
                Utilities.succesProgress(msg: "Bildirimler Kapatıldı")
                self.post?.silent.append(currentUser.uid)
                completion(true)
                
            }
        }
        
    }
    private func removeSlient(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post")
            .collection("post")
            .document(post!.postId)
        
        db.updateData(["silent":FieldValue.arrayRemove([currentUser.uid as Any])]) { (err) in
            if err == nil {
                
                
                if let index = self.post?.silent.firstIndex(of: currentUser.uid) {
                    Utilities.succesProgress(msg: "Bildirimler Açıldı")
                    self.post?.silent.remove(at: index)
                    completion(true)
                } else {
                    Utilities.errorProgress(msg: "Hata Oluştu")
                    completion(false)
                }
                
            }
        }
    }

    private func setSlientLesson(currentUser : CurrentUser , lessonName : String , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
                  .document("lesson").collection(currentUser.bolum).document(lessonName).collection("notification_getter").document(currentUser.uid)
        db.delete { (err) in
            if err == nil {
                Utilities.succesProgress(msg: "Bildirimler Kapatıldı")
                self.lessonIsSlient = false
                completion(false)
                
            }
        }
      
    }
    private func setNotSlientLesson(currentUser : CurrentUser , lessonName : String , completion : @escaping(Bool) ->Void){
          Utilities.waitProgress(msg: nil)
          let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson").collection(currentUser.bolum).document(lessonName).collection("notification_getter").document(currentUser.uid)
        
        let dic = ["uid":currentUser.uid as Any] as [String:Any]
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                    completion(false)
                return }
            if err == nil {
                Utilities.succesProgress(msg: "Bildirimler Kapatıldı")
                sself.lessonIsSlient = true
                completion(true)
                
            }else{
                 Utilities.succesProgress(msg: "Bildirimler Açıldı")
                sself.lessonIsSlient = false
                completion(false)
            }
        }
        
      }
    private func isPostSlient(slientUser : [String], completion: @escaping(Bool) ->Void){
        if slientUser.contains(currentUser.uid){
            completion(true)
        }else{
            completion(false)
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
    
    private func checkFollowingLesson(userId : String,lessonName : String , completion : @escaping(Bool) -> Void){
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama/fallowers/@deneme
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson").collection(currentUser.bolum).document(lessonName).collection("fallowers").document(currentUser.username)
        db.getDocument { (docSnap, err) in
            guard let snap = docSnap else {
                completion(false)
                return}
            if snap.exists {
                completion(true)
            }else{
                completion(false)
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
                           Utilities.dismissProgress()
                           sself.userIsSlient = true
                        sself.otherUser?.slientUser.append(sself.currentUser.uid)
                           completion(true)
                           sself.tableView.reloadData()
                       }else{
                           Utilities.dismissProgress()
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
                                  Utilities.dismissProgress()
                                  sself.userIsSlient = false
                                    sself.otherUser?.slientUser.remove(element : sself.currentUser.uid)
                                  completion(false)
                                  sself.tableView.reloadData()
                              }else{
                                  Utilities.dismissProgress()
                                  sself.userIsSlient = true
                                    sself.otherUser?.slientUser.append(sself.currentUser.uid)
                                  completion(true)
                                  sself.tableView.reloadData()
                              }
               }
    }
    private func removeLesson (lessonName : String! ,completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: "Ders Siliniyor")
       
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!)
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                let abc = Firestore.firestore().collection(sself.currentUser.short_school)
                    .document("lesson").collection(sself.currentUser.bolum)
                    .document(lessonName!).collection("fallowers").document(sself.currentUser.username)
                abc.delete { (err) in
                    if err == nil {
                        sself.getAllPost(currentUser: sself.currentUser, lessonName: lessonName) { (val) in
                            sself.removeAllPost(postId: val, currentUser: sself.currentUser) { (_) in
                                completion(true)
                                Utilities.succesProgress(msg : "Ders Silindi")
                            }
                        }
                        
                    }else{
                        completion(false)
                        Utilities.errorProgress(msg: "Ders Silinemedi")
                    }
                }
            }else{
                completion(false)
                Utilities.errorProgress(msg: "Ders Silinemedi")
            }
        }
    }
    private func getAllPost(currentUser : CurrentUser , lessonName : String , completion : @escaping([String]) ->Void){
         //İSTE/lesson-post/post/1599800825321
         var postId = [String]()
         let db = Firestore.firestore().collection(currentUser.short_school)
             .document("lesson-post").collection("post").whereField("lessonName", isEqualTo: lessonName)
         db.getDocuments { (querySnap, err) in
             if err == nil {
                 guard let snap = querySnap else {
                     completion([])
                     return }
                 for doc in snap.documents {
                     postId.append(doc.documentID)
                 }
                 completion(postId)
             }
         }
     }
    private func removeAllPost(postId : [String] , currentUser : CurrentUser , completion : @escaping(Bool) -> Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson-post/1599800825321
        for item in postId {
           let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").document(item)
            db.delete { (err) in
                if err == nil {
                    completion(true)
                    let dbFav = Firestore.firestore().collection("user")
                        .document(currentUser.uid).collection("fav-post").document(item)
                    dbFav.getDocument { (docSnap, err) in
                        if err == nil {
                          
                            if docSnap!.exists{
                                dbFav.delete()
                            }else{
                               
                            }
                        }
                     
                    }
                    
                }else{
                    completion(false)
                }
            }
        
        }
 
        
    }
    private func addAllPost(postId : [String] , currentUser : CurrentUser , completion : @escaping(Bool) -> Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson-post/1599800825321
        for item in postId {
           let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson-post").document(item)
            db.setData(["postId":item], merge: true) { (err) in
                if err == nil {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
        
    }
    private func getLessonInfo(lessonName : String,completion : @escaping(LessonInfoModel) ->Void){
        let db =  Firestore.firestore().collection(currentUser.short_school)
            .document("lesson").collection(currentUser.bolum)
            .document(lessonName)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else { return }
                if snap.exists {
                    completion(LessonInfoModel.init(dic: snap.data()!))
                }
            }
        }
    }
    private func addLesson(lessonName : String! ,teacherName : String!, teacherID : String! , teacherEmail : String! )
    {
        Utilities.waitProgress(msg: "Ekleniyor")
        
        
        let dic = ["teacherName":teacherName as Any,
                   "teacherId":teacherID as Any,
                   "teacherEmail":teacherEmail as Any,
                   "lessonName":lessonName!] as [String:Any]
        
        Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!).setData(dic, merge: true) {[weak self] (err) in
                guard let sself = self else {
                    
                    return }
                if err == nil {
                    //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
                    let abc = Firestore.firestore().collection(sself.currentUser.short_school)
                        .document("lesson").collection(sself.currentUser.bolum)
                        .document(lessonName!).collection("fallowers").document(sself.currentUser.username)
                    
                    let dict = ["username":sself.currentUser.username as Any,"name":sself.currentUser.name as Any,"email":sself.currentUser.email as Any,"number":sself.currentUser.number as Any,"thumb_image":sself.currentUser.thumb_image ?? "" , "uid" : sself.currentUser.uid as Any] as [String:Any]
                    abc.setData(dict, merge: true) { (err) in
                        if err == nil {
                            sself.getAllPost(currentUser: sself.currentUser, lessonName: lessonName) { (val) in
                                sself.addAllPost(postId: val, currentUser: sself.currentUser) { (_val) in
                                    if _val {
                                        Utilities.succesProgress(msg : "Ders Eklendi")
//                                        sself.tableView.reloadData()
                                    }else{
                                        Utilities.succesProgress(msg : "Ders Eklenemedi")
//                                        sself.tableView.reloadData()
                                    }
                                }
                            }
                           
                        }else{
                            Utilities.errorProgress(msg: "Eklenemedi")
                        }
                    }
                }else{
                    Utilities.errorProgress(msg: "Eklenemedi")
                }
        }
    }
    
  
}

extension ActionSheetOtherUserLaunher : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id",for: indexPath) as! ActionOtherUserCell
        cell.options = viewModel.imageOptions[indexPath.row]
        if cell.titleLabel.text == ActionSheetOtherUserOptions.fallowUser(currentUser).description{
           
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
        else  if cell.titleLabel.text == ActionSheetOtherUserOptions.reportUser(currentUser).description{
            cell.titleLabel.textColor = .red
            cell.titleLabel.font = UIFont(name: Utilities.fontBold, size: 13)
        }
        else if cell.titleLabel.text == ActionSheetOtherUserOptions.reportPost(currentUser).description {
                //FIXME: report post
          
            
        }
      
      
        else if cell.titleLabel.text == ActionSheetOtherUserOptions.slientUser(currentUser).description{

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
        else if cell.titleLabel.text == ActionSheetOtherUserOptions.deleteLesson(currentUser).description{
            checkFollowingLesson(userId: currentUser.uid, lessonName: post!.lessonName) {[weak self] (val) in
                if val {
                    cell.titleLabel.text = "Dersi Takip Etmeyi Bırak"
                    cell.logo.image = #imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal)
                    self?.isFallowingLesson = true
                }else{
                    cell.titleLabel.text = "Dersi Takip Et"
                    cell.logo.image = #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal)
                    self?.isFallowingLesson = false
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
        
        _ = tableView.cellForRow(at: indexPath) as! ActionOtherUserCell
        if indexPath.row == 3 {
            if lessonIsSlient
            {
                setNotSlientLesson(currentUser: currentUser, lessonName: post!.lessonName) { (_) in
                    tableView.reloadData()
                }
            }
            else
            {
                setSlientLesson(currentUser: currentUser, lessonName: post!.lessonName) { (_) in
                    tableView.reloadData()
                }
            }
        }
        else if indexPath.row == 4 {
            if userIsSlient {
                setUserNotSlient(slientUser: otherUser?.slientUser ?? [], otherUserUid: otherUser!.uid) { (_) in
                    tableView.reloadData()
                }
            }else{
                setUserSlient(slientUser: otherUser?.slientUser ?? [], otherUserUid: otherUser!.uid) { (_) in
                    tableView.reloadData()
                }
            }
        }else if indexPath.row == 5 {
            if isFallowingLesson {
                removeLesson(lessonName: post!.lessonName) { (_val) in
                    
                }
                tableView.reloadData()
            }else{
                getLessonInfo(lessonName: post!.lessonName!) {[weak self] (model) in
                    self?.addLesson(lessonName: model.lessonName, teacherName: model.teacherName, teacherID: model.teacherName, teacherEmail: model.teacherEmail)}

            }
        }
        print("indexpath : \(indexPath.row)")
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


