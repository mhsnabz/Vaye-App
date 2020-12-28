//
//  CommentVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 23.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
private let reuseIdentifier = "Cell"
private let msgCellID = "msg_cell_id"
private let headerId = "header_id"
private let headerId_data = "header_id_data"
class CommentVC: UIViewController, DismisDelegate {
    func dismisMenu() {
        inputAccessoryView?.isHidden = false
    }
    
    
    
    //MARK:- variables
    
    private  var actionSheet : ActionSheetHomeLauncher
    private var actionOtherUserSheet : ActionSheetOtherUserLaunher
    
    var comment = [CommentModel]()
    var currentUser : CurrentUser
    var post : LessonPostModel
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    weak var messagesListener : ListenerRegistration?
    
     var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    //MARK: -lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureUI()
        getComments(currentUser: currentUser, postID: post.postId)

    }
    init(currentUser : CurrentUser , post : LessonPostModel) {
        self.currentUser = currentUser
        self.post = post
        self.actionSheet = ActionSheetHomeLauncher(currentUser: currentUser  , target: TargetHome.ownerPost.description)
        self.actionOtherUserSheet = ActionSheetOtherUserLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = post.lessonName
        print("appaer")

    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        messagesListener?.remove()
//        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messagesListener?.remove()
//        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesListener?.remove()
    }
   
    
    //MARK:- functions
    
    private func deleteToStorage(data : [String],thumdata : [String], postId : String , completion : @escaping(Bool) -> Void){
        if data.count == 0{
            completion(true)
            return
        }
        deleteThumbToStorage(thumbData: thumdata) { (_) in
            for item in data{
                
                let ref = Storage.storage().reference(forURL: item)
                ref.delete { (err) in
                    completion(true)
                }
            }
        }
      
    }
    
    private func deleteThumbToStorage(thumbData : [String],completion : @escaping(Bool) -> Void ){
        if thumbData.count == 0{
            completion(true)
            return
        }
        for item in thumbData{
            let ref = Storage.storage().reference(forURL: item)
            ref.delete { (err) in
                completion(true)
            }
        }
    }
    
    fileprivate func configureUI(){
        
        let rigthBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(optionsLauncher))
        navigationItem.rightBarButtonItem = rigthBtn
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentMsgCell.self, forCellReuseIdentifier: msgCellID)
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        if post.data.isEmpty{
            tableView.register(CommentVCHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            self.tableView.sectionHeaderHeight = 60 + 4 + h + 4  + 4 + 25 + 30
            self.tableView.reloadData()
        }else{
            tableView.register(CommentVCDataHeader.self, forHeaderFooterViewReuseIdentifier: headerId_data)
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            self.tableView.sectionHeaderHeight = 60 + 4 + h + 4 + 100 + 4 + 25 + 30
                self.tableView.reloadData()
        }
        
        
    }
    
   
    func getComments(currentUser : CurrentUser , postID : String ){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(post.postId).collection("comment")
        messagesListener = db.addSnapshotListener({ (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documentChanges else {
                    
                    return
                }
                if !snap.isEmpty {
                    for item in snap{
                        if item.type == .added{
                            self.comment.append(CommentModel.init(ID: item.document.documentID, dic: item.document.data()))
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        })
    }
    private func getOtherUser(userId : String , completion : @escaping(OtherUser)->Void){
        let db = Firestore.firestore().collection("user")
            .document(userId)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    Utilities.dismissProgress()
                    return }
                if snap.exists {
                    completion(OtherUser.init(dic: docSnap!.data()!))
                }
            }
        }
    }
    
    private func setLike(post : LessonPostModel , completion : @escaping(Bool) ->Void){
        
        if !post.likes.contains(currentUser.uid){
            post.likes.append(self.currentUser.uid)
            post.dislike.remove(element: self.currentUser.uid)
            tableView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) {[weak self] (err) in
                guard let sself = self else { return }
                db.updateData(["dislike":FieldValue.arrayRemove([sself.currentUser.uid as String])]) { (err) in
                    
                    completion(true)
     
                    NotificaitonService.shared.send_post_like_comment_notification(post: post, currentUser: sself.currentUser, text: Notification_description.like_home.desprition, type: NotificationType.home_like.desprition)
              
                }
            }
        }else{
            post.likes.remove(element: self.currentUser.uid)
            tableView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {[weak self]  (err) in
                guard let sself = self else { return }
                NotificaitonService.shared.send_home_remove_like_notification(post: post, currentUser: sself.currentUser)
                completion(true)
            }
        }
        
      
    }
    private func setFav(post : LessonPostModel , completion : @escaping(Bool) ->Void){
        if !post.favori.contains(currentUser.uid){
            post.favori.append(currentUser.uid)
            tableView.reloadData()
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
            tableView.reloadData()
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
            tableView.reloadData()
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
            tableView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                completion(true)
            }
        }
    }
    
    //MARK:- keyboard
    override var inputAccessoryView: UIView?{
        if customInputView == nil {
            customInputView = CustomView()
            customInputView.backgroundColor = .white
            textField.placeholder = "Yeni Bir Yorum Yap..."
            textField.font = UIFont(name: Utilities.font, size: 14)
            textField.layer.cornerRadius = 5
            customInputView.autoresizingMask = .flexibleHeight
        
            customInputView.addSubview(textField)
            
            sendButton = UIButton()
            sendButton.isEnabled = true
            sendButton.setImage(UIImage(named: "send")!.withRenderingMode(.alwaysOriginal), for: .normal)
            sendButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                               sendButton.addTarget(self, action: #selector(sendMsg), for: .touchUpInside)
            customInputView?.addSubview(sendButton)
            addMediaButtom = UIButton()
            addMediaButtom.setImage(#imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), for: .normal)
            addMediaButtom.isEnabled = true
            //addMediaButtom.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            
            addMediaButtom.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
           addMediaButtom.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
            customInputView?.addSubview(addMediaButtom)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            addMediaButtom.translatesAutoresizingMaskIntoConstraints = false
            sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            
            addMediaButtom.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            addMediaButtom.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            
            textField.maxHeight = 80
            
            addMediaButtom.leadingAnchor.constraint(
                equalTo: customInputView.leadingAnchor,
                constant: 8
            ).isActive = true
            
            addMediaButtom.trailingAnchor.constraint(
                equalTo: textField.leadingAnchor,
                constant: -8
            ).isActive = true
            
            addMediaButtom.topAnchor.constraint(
                equalTo: customInputView.topAnchor,
                constant: 8
            ).isActive = true
            
            addMediaButtom.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
            
            textField.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: 0
            ).isActive = true
            
            textField.topAnchor.constraint(
                equalTo: customInputView.topAnchor,
                constant: 8
            ).isActive = true
            
            textField.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
            
            sendButton.leadingAnchor.constraint(
                equalTo: textField.trailingAnchor,
                constant: 0
            ).isActive = true
            
            sendButton.trailingAnchor.constraint(
                equalTo: customInputView.trailingAnchor,
                constant: -8
            ).isActive = true
            
            sendButton.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
        }
        return customInputView
    }
    
    var shouldBecomeFirstResponder:Bool = true

    override var canBecomeFirstResponder: Bool {
    return shouldBecomeFirstResponder
    }
    

    
    //MARK:-selectorsü
    
    @objc func optionsLauncher(){
       
        if post.senderUid == currentUser.uid
        {
            actionSheet.delegate = self
            actionSheet.show(post: post)
            actionSheet.dismisDelgate = self
            inputAccessoryView?.isHidden = true
//            guard let  index = collectionview.indexPath(for: cell) else { return }
//            selectedIndex = index
//            selectedPostID = lessonPost[index.row].postId
        }else{
            Utilities.waitProgress(msg: nil)
            actionOtherUserSheet.delegate = self
            actionOtherUserSheet.dismisDelgate = self
            inputAccessoryView?.isHidden = true
//            guard let  index = collectionview.indexPath(for: cell) else { return }
//            selectedIndex = index
//            selectedPostID = lessonPost[index.row].postId
            getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                Utilities.dismissProgress()
                sself.actionOtherUserSheet.show(post: sself.post, otherUser: user)
                
            }
            
            
        }
    }
    @objc func sendMsg()
    {
        guard let text = textField.text else { return }
        
        if textField.hasText {
            textField.text = ""
            let commentId  = Int64(Date().timeIntervalSince1970 * 1000).description
             CommentService.shared.setNewComment(currentUser: currentUser, commentText: text, postId: post.postId, commentId: commentId) {[weak self] (_val) in
                guard let sself = self else { return }
                 if _val {
                    NotificaitonService.shared.send_post_like_comment_notification(post: sself.post, currentUser: sself.currentUser, text: text, type: NotificationType.comment_home.desprition)
                    for item in text.findMentionText(){
                        NotificaitonService.shared.send_replied_comment_bymention(username: item.trimmingCharacters(in: .whitespaces), currentUser: sself.currentUser, text: text, type: NotificationType.comment_mention.desprition, post: sself.post)
                    }
                 }
                
             }
        }
        
       
    }
      
    @objc func showMenu(){
        print("menu show")
    }
    
    //MARK: - functions
    
    
    
    
    func removeComment(commentID : String , postID : String){
        let db = Firestore.firestore().collection(currentUser.short_school).document("lesson-post")
            .collection("post").document(postID).collection("comment").document(commentID)
        db.delete()
    }
    
    func deleteAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Sil") {[weak self] (action, view, completion) in
            guard let sself = self else { return }
            sself.removeComment(commentID: sself.comment[indexPath.row].commentId!, postID: sself.comment[indexPath.row].postId!)
            sself.comment.remove(at: indexPath.row)
            sself.tableView.reloadData()
        }
        action.backgroundColor = .red
    
        action.image = UIImage(named: "remove")
        
        return action
    }
    
    func editAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Düzenle") { (action, view, completion) in
            completion(true)
        }
        action.backgroundColor = .systemGreen
        
        action.image = UIImage(named: "duzenle")
        return action
    }
    func replyAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Cevapla") {[weak self] (action, view, completion) in
            guard let sself = self  else { return }
            sself.tableView.reloadData()
            let vc = RepliesComment(comment : sself.comment[indexPath.row] , currentUser : sself.currentUser , post: sself.post)
         
            sself.navigationController?.pushViewController(vc, animated: true)
        }
        action.backgroundColor = .mainColor()
        
        action.image = UIImage(named: "reply")
        return action
    }
    func reportAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Şikayet Et") { (action, view, completion) in
            completion(true)
        }
        action.backgroundColor = .systemRed
        
        action.image = UIImage(named: "report-msg")
        return action
    }
    
    private func setLike(comment : CommentModel , completion : @escaping(Bool) ->Void){
        
        if !(comment.likes?.contains(currentUser.uid))!{
            comment.likes?.append(currentUser.uid)
            tableView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(comment.postId!).collection("comment").document(comment.commentId!)
            db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as Any])]) {[weak self] (err) in
                guard let sself = self else { return }
                if err != nil{
                    print("like err \(err?.localizedDescription as Any)")
                }else{
                    NotificaitonService.shared.send_post_like_comment_notification(post: sself.post, currentUser: sself.currentUser, text: Notification_description.comment_like.desprition, type: NotificationType.comment_like.desprition)
                }
            }
        }else{
            comment.likes?.remove(element: currentUser.uid)
            tableView.reloadData()
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(comment.postId!).collection("comment").document(comment.commentId!)
            db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as Any])]) {[weak self] (err) in
                guard let sself = self else { return }
                if err != nil{
                    
                    print("like err \(err?.localizedDescription as Any)")
                }else{
                    NotificaitonService.shared.remove_comment_like(post: sself.post, currentUser: sself.currentUser)
                }
        }
    }
    }
 

}

class CustomView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}

extension CommentVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: msgCellID, for: indexPath) as! CommentMsgCell
        cell.selectionStyle = .none
        if comment[indexPath.row].replies!.count > 0 {
            cell.comment = comment[indexPath.row]
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 43, y: 35, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = false
            cell.totalRepliedCount.isHidden = false
            cell.delegate = self
            cell.contentView.isUserInteractionEnabled = false
            cell.currentUser  = currentUser
            return cell
        }else{
            cell.comment = comment[indexPath.row]
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 43, y: 35, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = true
            cell.totalRepliedCount.isHidden = true
            cell.contentView.isUserInteractionEnabled = false
            cell.currentUser  = currentUser

            cell.delegate = self
            return cell
        }
        
      
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if comment[indexPath.row].replies!.count > 0 {
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 14)!)
            return 35 + h! + 45 + 30
        }else{
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 14)!)
            return 35 + h! + 45
        }
       
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if comment[indexPath.row].senderUid == currentUser.uid {
            let edit = editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete,edit])
        }
        else
        {
            let report = reportAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [report])
        }
        
     
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reply = replyAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [reply])
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if post.data.isEmpty{
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! CommentVCHeader
            cell.delegate = self
            cell.currentUser = currentUser
            cell.backgroundColor = .white
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.post = post
       
            return cell
        }else{
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId_data) as! CommentVCDataHeader
            
            cell.backgroundColor = .white
            cell.delegate = self
            cell.currentUser = currentUser
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 11)!)
            cell.msgText.frame = CGRect(x: 70, y: 58, width: view.frame.width - 78, height: h + 4)
            
            cell.filterView.frame = CGRect(x: 70, y: 60 + 8 + h + 4 + 4 , width: cell.msgText.frame.width, height: 100)
            
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.post = post
          
            cell.contentView.backgroundColor = .white
            return cell
        }
        
      
    }
    
}

extension CommentVC : CommentDelegate {
    func likeClik(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        setLike(comment: comment) { (_) in
            print("succes")
        }
    }
    
    func replyClick(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        let vc = RepliesComment(comment: comment, currentUser: currentUser, post: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllReplies(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        let vc = RepliesComment(comment: comment, currentUser: currentUser, post: post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func goProfile(cell: CommentMsgCell) {
        Utilities.waitProgress(msg: nil)
        guard let comment = cell.comment else { return }
        if comment.senderUid == currentUser.uid {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
            }
           
            
        }else{
            UserService.shared.fetchOtherUser(uid: comment.senderUid!) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
            }
        }
    }
    
    
}

extension Array where Element: Equatable {

    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }

    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.firstIndex(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }

}

//MARK: - data delegate
extension CommentVC : CommentVCDataDelegate {
    func options(for header: CommentVCDataHeader) {
        
    }
    
    func like(for header: CommentVCDataHeader) {
        guard let post = header.post else { return }
        setLike(post: post) { (_) in  }
    }
    
    func dislike(for header: CommentVCDataHeader) {
        guard let post = header.post else { return }
        setDislike(post: post){ (_) in  }
    }
    
    func fav(for header: CommentVCDataHeader) {
        guard  let post = header.post else {
            return
        }
        setFav(post: post){ (_) in  }
    }
  
    func linkClick(for header: CommentVCDataHeader) {
        guard let post = header.post else { return }
        guard let url = URL(string: post.link) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for header: CommentVCDataHeader) {
        guard  let post = header.post else {
            return
        }
      
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{
            Utilities.waitProgress(msg: nil)
            getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }

        
            }
        }
    }
    
    func goProfileByMention(userName: String) {
        if "@\(userName)" == currentUser.username {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: userName) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
               
            }
        }
    }
    
    
}

//MARK: - delegate
extension CommentVC : CommentVCHeaderDelegate {
    func clickMention(username: String) {
        if "@\(username)" == currentUser.username {
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
               
            }
        }
    }
    func like(for header: CommentVCHeader) {
        guard let post = header.post else { return }
        setLike(post: post) { (_) in  }
    }
    
    func dislike(for header: CommentVCHeader) {
        guard let post = header.post else { return }
        setDislike(post: post){ (_) in  }
    }
    
    func fav(for header: CommentVCHeader) {
        guard  let post = header.post else {
            return
        }
        setFav(post: post){ (_) in  }
    }
    func linkClick(for header: CommentVCHeader) {
        guard let post = header.post else { return }
        guard let url = URL(string: post.link) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func showProfile(for header: CommentVCHeader) {
        guard  let post = header.post else {
            return
        }
      
        if post.senderUid == currentUser.uid{
            UserService.shared.checkCurrentUserSocialMedia(currentUser: currentUser) {[weak self] (val) in
                guard let self = self else { return }
                if val{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 285)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = ProfileVC(currentUser: self.currentUser, width: 235)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{
            Utilities.waitProgress(msg: nil)
            getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
               
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    UserService.shared.checkOtherUserSocialMedia(otherUser: user) { (val) in
                        if val {
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 285)
                           
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }else{
                            let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model, width: 235)
                
                            sself.navigationController?.pushViewController(vc, animated: true)
                            Utilities.dismissProgress()
                        }
                        
                    }
                }
                
            }
        }
    } 
}
//MARK: - ActionSheetHomeLauncherDelegate
extension CommentVC : ActionSheetHomeLauncherDelegate {
    func didSelect(option: ActionSheetHomeOptions) {
        switch option {
        
        case .editPost(_):
                let h = post.text.height(withConstrainedWidth: view.frame.width - 24, font: UIFont(name: Utilities.font, size: 13)!)
                let vc = StudentEditPost(currentUser: currentUser , post : post , heigth : h )
                let controller = UINavigationController(rootViewController: vc)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            break
        case .deletePost(_):
            
                Utilities.waitProgress(msg: "Siliniyor")
               
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson-post")
                    .collection("post")
                    .document(post.postId)
                db.delete {[weak self] (err) in
                    guard let sself = self else { return }
                    if err == nil {
                        sself.deleteToStorage(data: sself.post.data , thumdata: sself.post.thumbData, postId: sself.post.postId) { (_val) in
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
//MARK: -ActionSheetOtherUserLauncherDelegate
extension CommentVC : ActionSheetOtherUserLauncherDelegate {
    func didSelect(option: ActionSheetOtherUserOptions) {
        switch option {
        
        case .fallowUser(_):
            break
        case .slientUser(_):
            break
        case .deleteLesson(_):
            break
        case .slientLesson(_):
            break
        case .slientPost(_):
            break
        case .reportPost(_):
            let vc = ReportingVC(target: ReportTarget.homePost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportPost.description)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .reportUser(_):
            let vc = ReportingVC(target: ReportTarget.homePost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportUser.description)
            navigationController?.pushViewController(vc, animated: true)
            break
      
        }
    }
    
    
}
