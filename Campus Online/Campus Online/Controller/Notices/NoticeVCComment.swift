//
//  NoticeVCComment.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore


private let msgCellID = "msgCellID"
private let headerID = "headerId"
private let headerDataID = "headerDataId"
class NoticeVCComment: UIViewController ,DismisDelegate {

    func dismisMenu() {
        inputAccessoryView?.isHidden = false
    }
    
    //MARK: - variables
    var currentUser : CurrentUser
    var post : NoticesMainModel
    var comment = [CommentModel]()
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    var size : CGFloat!
    weak var messagesListener : ListenerRegistration?
    private var actionSheetOtherUser : ASNoticesPostLaunher
   private var actionSheetCurrentUser : ASNoticesPostCurrentUserLaunher
    var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
//    MARK:-lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboardWhenTappedAround()
        getComment(currentUser: currentUser, postID: post.postId)

    }
    init(currentUser : CurrentUser , post :  NoticesMainModel) {
        self.post = post
        self.currentUser = currentUser
        self.actionSheetOtherUser = ASNoticesPostLaunher(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        self.actionSheetCurrentUser = ASNoticesPostCurrentUserLaunher(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
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
        navigationItem.title = post.clupName
        inputAccessoryView?.isHidden = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        messagesListener?.remove()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messagesListener?.remove()
        //        navigationController?.navigationBar.isHidden = true
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
//            addMediaButtom.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
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
    override var canBecomeFirstResponder: Bool {  return true  }
    //MARK: -functions
    fileprivate func  configureUI(){
        let rigthBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(optionsLauncher))
        navigationItem.rightBarButtonItem = rigthBtn
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentMsgCell.self, forCellReuseIdentifier: msgCellID)
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        if post.data.isEmpty {
            tableView.register(NoticesCommentHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            size = h
            self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 50 + 35
            self.tableView.reloadData()
        }else{
            tableView.register(NoticesCommentDataHeader.self, forHeaderFooterViewReuseIdentifier: headerDataID)
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            size = h
            self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 100 + 50 + 35
            self.tableView.reloadData()
        }
    }
    
    private func showUserProfile(post : NoticesMainModel){
        if post.senderUid == currentUser.uid{
            let vc = ProfileVC(currentUser: currentUser)
            vc.currentUser = currentUser
            navigationController?.pushViewController(vc, animated: true)
        }else{
            Utilities.waitProgress(msg: nil)
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else {
                    Utilities.dismissProgress()
                    return }
                
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
            }
        }
    }
    func clickUserName(username: String) {
        if "@\(username)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    vc.modalPresentationStyle = .fullScreen
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
              
                
            }
        }
    }
    
    
    func getComment(currentUser : CurrentUser , postID : String){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(postID)
            .collection("comment")
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
    
    func deleteAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Sil") {[weak self] (action, view, completion) in
            guard let sself = self else { return }
            //main-post/sell-buy/post/1604436850197
            sself.removeComment(commentID: sself.comment[indexPath.row].commentId!, postID: sself.comment[indexPath.row].postId!) { (val) in
                sself.post.comment = val
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(sself.post.postId)
                db.setData(["comment":val], merge: true) { (err) in
                    if err == nil {
                        print("succes")
                    }
                }
            }
            sself.comment.remove(at: indexPath.row)
            sself.tableView.reloadData()
        }
        action.backgroundColor = .red
        
        action.image = UIImage(named: "remove")
        
        return action
    }
    func removeComment(commentID : String , postID : String , completion : @escaping(Int) -> Void){
        //main-post/sell-buy/post/1603888561458/comment/1603986010312
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(post.postId)
            .collection("comment")
            .document(commentID)
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                sself.removeRepliedComment(commentID: commentID)
                sself.getTotolCommentCount { (val) in
                    completion(val)
                }
            }
        }
    }
    func removeRepliedComment(commentID : String){
        //main-post/sell-buy/post/1603888561458/comment/1603986010312
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(post.postId)
            .collection("comment")
            .document(commentID)
        db.getDocument {[weak self] (docSnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = docSnap else { return }
                if snap.get("replies") != nil{
                    let repliedComment = snap.get("replies") as! [String]
                    for item in repliedComment{
                        //main-post/sell-buy/post/1603888561458/comment-replied/comment/1603986010312/1604077583715
                        let dbc = Firestore.firestore().collection(sself.currentUser.short_school)
                            .document("notices")
                            .collection("post")
                            .document(sself.post.postId)
                            .collection("comment-replied")
                            .document("comment")
                            .collection(commentID)
                            .document(item)
                        dbc.delete()
                    }
                }
            }
            
        }
        
    }
    func getTotolCommentCount(completion : @escaping(Int) -> Void){
        ///main-post/sell-buy/post/1604436850197/comment/1604773265884
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(post.postId)
            .collection("comment")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documents.count else {
                    completion(0)
                    return
                }
                completion(snap)
            }
        }
    }
    func replyAction(at indexPath :IndexPath , tableView : UITableView , comment : CommentModel , currentUser : CurrentUser , post : NoticesMainModel) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Cevapla") {[weak self] (action, view, completion) in
            guard let sself = self  else { return }
            tableView.reloadData()
            let vc = NoticesReplyCommentVC(comment: comment, currentUser: currentUser, post: post)
            sself.navigationController?.pushViewController(vc, animated: true)
            
        }
        action.backgroundColor = .mainColor()
        
        action.image = UIImage(named: "reply")
        return action
    }
    //MARK:-seletors
    @objc func sendMsg(){
        guard let text = textField.text else { return }
        if textField.hasText {
            textField.text = ""
            let commentId  = Int64(Date().timeIntervalSince1970 * 1000).description
            NoticesService.shared.setNewComment(currentUser: currentUser, target: PostType.notice.despription, commentText: text, postId: post.postId, commentId: commentId) {[weak self] (val) in
                guard let sself = self else { return }
                NoticesService.shared.send_comment_notificaiton(post: sself.post, currentUser: sself.currentUser, text: text, type: NotificationType.notices_new_comment.desprition)
                for item in text.findMentionText(){
                    NoticesService.shared.send_comment_mention_user(username: item, currentUser: sself.currentUser, text: text, type: NotificationType.comment_mention.desprition, post: sself.post)
                }
                
            }
        }
    }
    @objc func optionsLauncher(){
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.dismisDelgate = self
            actionSheetCurrentUser.show(post: post)
            inputAccessoryView?.isHidden = true
        }else{
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                sself.actionSheetOtherUser.show(post: sself.post, otherUser: user)
                sself.actionSheetOtherUser.dismisDelegate = self
                sself.inputAccessoryView?.isHidden = true
                
            }
        }
    }
}
//MARK:-  UITableViewDataSource, UITableViewDelegate
extension NoticeVCComment :  UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: msgCellID, for: indexPath) as! CommentMsgCell
        cell.selectionStyle = .none
        if comment[indexPath.row].replies!.count > 0 {
            cell.comment = comment[indexPath.row]
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 14)!)
            cell.msgText.frame = CGRect(x: 43, y: 35, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = false
            cell.totalRepliedCount.isHidden = false
            cell.delegate = self
            cell.contentView.isUserInteractionEnabled = false
            cell.currentUser  = currentUser
            return cell
        }else{
            cell.comment = comment[indexPath.row]
            let h = comment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 14)!)
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if post.data.isEmpty {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as!
                NoticesCommentHeader
            cell.delegate = self
            cell.currentUser = currentUser
            cell.backgroundColor = .white
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 70, y: 60, width: view.frame.width - 78, height: h + 4)
           
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.post = post
            return cell
        }else{
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerDataID) as! NoticesCommentDataHeader
            
            cell.delegate = self
            cell.backgroundColor = .white
            cell.currentUser = currentUser
            let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 70, y: 60, width: view.frame.width - 78, height: h + 4)
            
            cell.filterView.frame = CGRect(x: 70, y: 50 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
            
            cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
            cell.post = post
            return cell
            
           
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if comment[indexPath.row].senderUid == currentUser.uid {
            let delete = deleteAction(at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete])
        }
        else
        {
            let report = MainPostCommentService.shared.reportAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [report])
        }
        
        
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reply = replyAction(at: indexPath, tableView: self.tableView, comment: comment[indexPath.row], currentUser: currentUser, post: post)
        return UISwipeActionsConfiguration(actions: [reply])
    }
}
//MARK:-NoticesCommenHeaderDelegate
extension NoticeVCComment : NoticesCommenHeaderDelegate {
    func like(for header: NoticesCommentHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.like( tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for header: NoticesCommentHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.dislike( tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func showProfile(for header: NoticesCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func clickMention(username: String) {
        clickUserName(username: username)
    }
    
    
}
//MARK:-NoticesCommenDataHeaderDelegate
extension NoticeVCComment : NoticesCommenDataHeaderDelegate {
    func like(for header: NoticesCommentDataHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.like( tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for header: NoticesCommentDataHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.dislike( tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("disliked")
        }
    }
    
    func showProfile(for header: NoticesCommentDataHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    
}
//MARK:-ASMainPostLaungerDelgate
extension NoticeVCComment : ASMainPostLaungerDelgate  {
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        
        case .editPost(_):
            
            let vc = EditNoticesPost(currentUser: currentUser, post: post, h: size)
            let controller = UINavigationController(rootViewController: vc)
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
            
           
        case .deletePost(_):
            Utilities.waitProgress(msg: "Siliniyor")
           
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("notices")
                .collection("post")
                .document(post.postId)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil{
                    NoticesService.shared.deleteToStorage(data: sself.post.data, postId: sself.post.postId) { (_val) in
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
        case .slientPost(_):
            break
        }
    }
    
    
}
//MARK:-CommentDelegate
extension NoticeVCComment : CommentDelegate {
    func likeClik(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        
        NoticesService.shared.setLike(comment: comment, tableView: tableView, currentUser: currentUser, post: post) { (_) in
        }
        
    }
    
    func replyClick(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        let vc = NoticesReplyCommentVC(comment: comment, currentUser: currentUser, post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllReplies(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        let vc = NoticesReplyCommentVC(comment: comment, currentUser: currentUser, post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goProfile(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        if comment.senderUid == currentUser.uid
        {
            let vc = ProfileVC(currentUser: currentUser)
            navigationController?.pushViewController(vc, animated: true)
        }else{
            Utilities.waitProgress(msg: nil)
            guard let uid = comment.senderUid else {
                Utilities.dismissProgress()
                return}
            UserService.shared.getOtherUser(userId: uid) {[weak self] (user) in
                guard let sself = self else { return }
                UserService.shared.getProfileModel(otherUser: user, currentUser: sself.currentUser) { (model) in
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user , profileModel: model)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }
            }
        }
    }
    
    
}
