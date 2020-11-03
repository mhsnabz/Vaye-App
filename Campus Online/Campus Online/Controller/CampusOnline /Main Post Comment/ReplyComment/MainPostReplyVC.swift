//
//  MainPostReplyVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let msgCellID = "msg_cell_id"
private let headerID = "header_id"
import FirebaseFirestore
class MainPostReplyVC: UIViewController {
    //MARK:- variables
    var comment : CommentModel
    var currentUser : CurrentUser
    var post : MainPostModel
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    var repliedComment = [CommentModel]()
    weak var messagesListener : ListenerRegistration?
    var tableView : UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    //MARK:- lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        getComments(currentUser: currentUser)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messagesListener?.remove()
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messagesListener?.remove()
        navigationController?.navigationBar.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.setNavigationBar()
        self.navigationItem.title = "Yanıtlar"
    }
    init(comment : CommentModel , currentUser : CurrentUser , post : MainPostModel) {
        self.comment = comment
        self.currentUser = currentUser
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    override var canBecomeFirstResponder: Bool {  return true  }
    
    //MARK:-selectors
    @objc func sendMsg()
    {
        guard let text = textField.text else { return }
        print(text.findMentionText())
        if textField.hasText {
            textField.text = ""
            let commentId  = Int64(Date().timeIntervalSince1970 * 1000).description
            MainPostCommentService.shared.setRepliedComment(currentUser: currentUser, post: post, comment: comment, targetCommentId: comment.commentId!, commentId: commentId, commentText: text, postId: post.postId) {[weak self] (_) in
                guard let sself = self else { return }
                MainPostCommentService.shared.send_comment_notificaiton(post: sself.post, currentUser: sself.currentUser, text: text, type: NotificationType.comment_home.desprition)
                for item in text.findMentionText(){
                    MainPostCommentService.shared.send_comment_mention_user(username: item.trimmingCharacters(in: .whitespaces), currentUser: sself.currentUser, text: text, type: NotificationType.comment_mention.desprition, post: sself.post)
                }
                
            }
        }
        
        
    }
    
    @objc func showMenu(){
        print("menu show")
    }
    
    
    //    MARK: -functions
    fileprivate func configureUI(){
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentMsgCell.self, forCellReuseIdentifier: msgCellID)
        tableView.register(RepliedHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        let h = comment.comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 14)!)
        self.tableView.sectionHeaderHeight = 34 + h! + 10
        
    }
    
    
    func getComments(currentUser : CurrentUser ){
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(post.postId)
            .collection("comment-replied")
            .document("comment").collection(comment.commentId!)
        messagesListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap?.documentChanges else {
                    return
                }
                if !snap.isEmpty {
                    for item in snap{
                        if item.type == .added{
                            sself.repliedComment.append(CommentModel.init(ID: item.document.documentID, dic: item.document.data()))
                            sself.tableView.reloadData()
                        }
                        
                    }
                }
                sself.tableView.reloadData()
            }
        })
        
    }
    
    func removeComment(commentID : String  , commentModel : CommentModel){
        
        
        
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(post.postId)
            .collection("comment-replied")
            .document("comment")
            .collection(comment.commentId!)
            .document(commentID)
    
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                let db = Firestore.firestore().collection("main-post")
                    .document(sself.post.postType)
                    .collection("post")
                    .document(sself.post.postId)
                    .collection("comment")
                    .document(sself.comment.commentId!)
                db.updateData(["replies":FieldValue.arrayRemove([commentID as Any])]) { (err) in
                    if err ==  nil {
                    
                    }
                }
            }
        }
        
        
    }
    func replyAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Cevapla") {[weak self] (action, view, completion) in
            guard let sself = self  else { return }
            sself.tableView.reloadData()
            self?.textField.becomeFirstResponder()
            sself.textField.text.append(" \(sself.repliedComment[indexPath.row].username!) ")
            
        }
        action.backgroundColor = .mainColor()
        
        action.image = UIImage(named: "reply")
        return action
    }
    func deleteAction(at indexPath :IndexPath) ->UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Sil") {[weak self] (action, view, completion) in
            guard let sself = self else { return }
            sself.removeComment(commentID: sself.repliedComment[indexPath.row].commentId!, commentModel: sself.comment)
            sself.repliedComment.remove(at: indexPath.row)
            sself.tableView.reloadData()
        }
        action.backgroundColor = .red
        
        action.image = UIImage(named: "remove")
        return action
    }
    func clickUserName(username: String) {
        if "@\(username)" == currentUser.username {
            let vc = ProfileVC(currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            UserService.shared.getUserByMention(username: username) {[weak self] (user) in
                guard let sself = self else { return }
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                sself.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
}

//MARK: UITableViewDataSource ,UITableViewDelegate
extension MainPostReplyVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repliedComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: msgCellID, for: indexPath) as! CommentMsgCell
        cell.selectionStyle = .none
        cell.comment = repliedComment[indexPath.row]
        let h = repliedComment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 14)!)
        cell.msgText.frame = CGRect(x: 43, y: 35, width: view.frame.width - 83, height: h! + 4)
        cell.totalRepliedCount.isHidden = true
        cell.line.isHidden = true
        cell.lblReply.isHidden = true
        cell.contentView.isUserInteractionEnabled = false
        cell.delegate = self
        cell.currentUser = currentUser
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as? RepliedHeader else { return nil}
        
        let h = comment.comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 14)!)
        header.msgText.frame = CGRect(x: 43, y: 35, width: view.frame.width - 83, height: h! + 4)
        header.comment = comment
        header.contentView.backgroundColor = .white
        return header
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let h = repliedComment[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 14)!)
        return 35 + h! + 45
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if repliedComment[indexPath.row].senderUid == currentUser.uid {
            
            let delete = deleteAction(at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            return nil
        }
        
        
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reply = replyAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [reply])
    }
    
    
}
extension MainPostReplyVC : CommentDelegate {
    
    func clickMention(username : String)
    {
        clickUserName(username: username)
    }
    func likeClik(cell: CommentMsgCell) {
        guard let repliedComment = cell.comment else { return }
        
        MainPostCommentService.shared.setRepliedCommentLike(repliedComment: repliedComment, likedCommentId: comment.commentId!, currentUser: currentUser, post: post)
        {[weak self](_val) in
            guard let sself = self else { return }
            if _val{
                sself.tableView.reloadData()
            }
        }
        
    }
    
    func replyClick(cell: CommentMsgCell)
    {
        //        guard let comment = cell.comment else { return }
        //        let vc = MainPostReplyVC(comment: comment, currentUser: currentUser, post: post)
        //        navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllReplies(cell: CommentMsgCell) {
        //        guard let comment = cell.comment else { return }
        //        let vc = MainPostReplyVC(comment: comment, currentUser: currentUser, post: post)
        //        navigationController?.pushViewController(vc, animated: true)
    }
    func goProfile(cell: CommentMsgCell) {
        Utilities.waitProgress(msg: nil)
        guard let comment = cell.comment else { return }
        if comment.senderUid == currentUser.uid {
            let vc = ProfileVC(currentUser: currentUser)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: {
                Utilities.dismissProgress()
            })
            
        }else{
            UserService.shared.fetchOtherUser(uid: comment.senderUid!) { (user) in
                let vc = OtherUserProfile(currentUser: self.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen
                
                self.present(vc, animated: true, completion: {
                    Utilities.dismissProgress()
                    
                })
            }
        }
        
    }
    
    
}
