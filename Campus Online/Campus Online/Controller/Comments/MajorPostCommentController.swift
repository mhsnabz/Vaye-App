//
//  MajorPostCommentController.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 3.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let commentCell = "commentCell"
private let headerCell = "headerCell"
import FirebaseFirestore
import SwipeCellKit
class MajorPostCommentController: UIViewController ,DismisDelegate {
    func dismisMenu() {
        inputAccessoryView?.isHidden = false
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return control
    }()
    private var isLoadMore : Bool = true
    var buttonStyle: ButtonStyle = .backgroundColor
     var currentUser : CurrentUser
    var postId : String
    var defaultOptions = SwipeOptions()
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    weak var snapShotListener : ListenerRegistration?
    var page : DocumentSnapshot? = nil
    var commentModel = [CommentModel]()
    var firstPage : DocumentSnapshot? = nil
    var customInputView: UIView!
    var sendButton: UIButton!
    let textField = FlexibleTextView()
    var addMediaButtom: UIButton!
    var lessonPost : LessonPostModel?
    var noticesPost : NoticesMainModel?
    var mainPost : MainPostModel?
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
    
        layout.minimumLineSpacing = .zero
      
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    //MARK:-lifeCycle
    init(currentUser : CurrentUser , postId : String   ,lessonPost : LessonPostModel? , noticesPost : NoticesMainModel? , mainPost : MainPostModel?) {
        self.currentUser = currentUser
        self.postId = postId
        self.noticesPost = noticesPost
        self.lessonPost = lessonPost
        self.mainPost = mainPost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        navigationItem.title = "Yorumlar"
        configureUI()
        getAllComment(postId: postId)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
   

    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
      
        snapShotListener?.remove()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        snapShotListener?.remove()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        snapShotListener?.remove()
    }

 

    
    //MARK:-keyboard
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
            addMediaButtom.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
           // addMediaButtom.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
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
    //MARK:-functions

    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collecitonView.register(SwipeCommentCell.self, forCellWithReuseIdentifier: commentCell)
        collecitonView.register(MessageDateReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCell)
        collecitonView.refreshControl = refreshControl
    }
    private func loadBeforePage(){
        guard let page = firstPage else {
            refreshControl.endRefreshing()
            isLoadMore = false
            collecitonView.reloadData()
            return
        }
        let db = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment")
            .order(by: "commentId")
            .end(beforeDocument: page)
            .limit(toLast: 5)
        
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else {
                
                return }
            if err == nil {
                guard let snap = querySnap else {
                    sself.refreshControl.endRefreshing()
                    sself.isLoadMore = false
                    sself.collecitonView.reloadData()
                    return }
                if snap.isEmpty {
                    sself.refreshControl.endRefreshing()
                    sself.isLoadMore = false
                    sself.collecitonView.reloadData()
                    return
                }
                for item in snap.documents{
                    sself.commentModel.append(CommentModel.init(ID: item.documentID, dic: item.data()))
                    
                
                    sself.commentModel.sort { (msg1, msg2) -> Bool in
                        return msg1.time?.dateValue() ?? Date() < msg2.time?.dateValue() ?? Date()
                    }
                    sself.collecitonView.reloadData()
                    
                    
                }
                sself.firstPage = snap.documents.first

                sself.refreshControl.endRefreshing()
                sself.isLoadMore = true
                
            }else{
                sself.refreshControl.endRefreshing()
                sself.isLoadMore = false
                sself.collecitonView.reloadData()
            }
        }
        
        
    }
    private func getAllComment(postId : String ){
        let db = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment")
            .limit(toLast: 5).order(by: "commentId")
        
        snapShotListener = db.addSnapshotListener{[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else { return }
                for item in snap.documentChanges {
                    if item.type == .added {
                        
                        sself.commentModel.append(CommentModel.init(ID: item.document.documentID, dic: item.document.data()))
    
                    }
                    sself.collecitonView.reloadData()
                    sself.page = snap.documents.last
                    sself.firstPage = snap.documents.first
                    
                }
            }
        }
        guard let page = self.page else { return }
        let next = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment").order(by: "commentId")
            .start(atDocument: page)
            .limit(to: 1)
        next.addSnapshotListener { [weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else { return }
                for item in snap.documentChanges {
                    if item.type == .added {
                        sself.commentModel.append(CommentModel.init(ID: item.document.documentID, dic: item.document.data()))
                    }
                    sself.collecitonView.reloadData()
                    sself.page = snap.documents.last
                    sself.firstPage = snap.documents.first
                   
                }
            }
        }
       
        
    }
    //MARK:-objc
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            collecitonView.contentInset = .zero
        } else {
            collecitonView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textField.scrollIndicatorInsets = textField.contentInset

        if commentModel.count > 0  {
            let indexPath = IndexPath(item: commentModel.count - 1, section: 0)
            collecitonView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
  
    @objc func sendMsg(){
        guard let text = textField.text else { return }
        if textField.hasText {
            textField.text = ""
            let commentId = Int64(Date().timeIntervalSince1970 * 1000).description
            
            if let post = self.lessonPost {
            CommentService.shared.sendNewComment(postType : PostName.lessonPost.name,currentUser: currentUser, commentText: text, postId: postId, commentId: commentId) {[weak self] (_val) in
                guard let sself = self else { return }
                //FIXME:- send notification
              
                CommentNotificationService.shared.newLessonPostCommentNotification(post: post, currentUser: sself.currentUser, text: text, type: MajorPostNotification.new_comment.type)
                    for item in text.findMentionText(){
                        CommentNotificationService.shared.newLessonPostMentionedComment(username: item.trimmingCharacters(in: .whitespaces), post: post, currentUser: sself.currentUser, text: text, type: MajorPostNotification.new_mentioned_comment.type)
                    }
                
                }
                
                let indexPath = IndexPath(item: self.commentModel.count - 1, section: 0)
                self.collecitonView.scrollToItem(at: indexPath, at: .bottom, animated: true)

               
            }else if let post = self.noticesPost {
                CommentService.shared.sendNewComment(postType : PostName.NoticesPost.name,currentUser: currentUser, commentText: text, postId: postId, commentId: commentId) {[weak self] (_val) in
                    guard let sself = self else { return }
                    //FIXME:- send notification
                  
                        CommentNotificationService.shared.newNoticesPostCommentNotification(post: post, currentUser: sself.currentUser, text: text, type: NoticesPostNotification.new_comment.type)
                        for item in text.findMentionText(){
                            CommentNotificationService.shared.newNoticesPostMentionedComment(username: item.trimmingCharacters(in: .whitespaces), post: post, currentUser: sself.currentUser, text: text, type: NoticesPostNotification.new_mentioned_comment.type)
                        }
                    
                    }
                    
                    let indexPath = IndexPath(item: self.commentModel.count - 1, section: 0)
                    self.collecitonView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }else if let post = self.mainPost {
                CommentService.shared.sendNewComment(postType: PostName.MainPost.name, currentUser: currentUser, commentText: text, postId: post.postId, commentId: commentId) {[weak self] (_val) in
                    if _val{
                        guard let sself = self else { return }
                        //FIXME:- send notification
                        CommentNotificationService.shared.newMainPostCommentNotification(post: post, currentUser: sself.currentUser, text: text, type: MainPostNotification.new_comment.type)
                        for item in text.findMentionText(){
                            CommentNotificationService.shared.newMainPostMentionedComment(username: item.trimmingCharacters(in: .whitespaces), post: post, currentUser: sself.currentUser, text: text, type: MainPostNotification.new_mentioned_comment.type)
                        }
                        
                    }
                }
            }
        }
        
    }
    @objc func loadData(){
        loadBeforePage()
    }
  
    var shouldBecomeFirstResponder:Bool = true

    override var canBecomeFirstResponder: Bool {
     
    return shouldBecomeFirstResponder
    }
    
    
    
 
    
    
}

extension MajorPostCommentController :  UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCell, for: indexPath) as! SwipeCommentCell
        cell.currentUser = currentUser
        
        if commentModel[indexPath.row].replies!.count > 0 {
            cell.comment = commentModel[indexPath.row]
            cell.backgroundColor = .white
            let h = commentModel[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 56, y: 30, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = false
            cell.totalRepliedCount.isHidden = false
            cell.delegate = self
            cell.contentView.isUserInteractionEnabled = true
            cell.currentUser  = currentUser
            cell.commentDelegate = self
        
            return cell
        }else{
            cell.comment = commentModel[indexPath.row]
            cell.backgroundColor = .white
            let h = commentModel[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 56, y: 30, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = true
            cell.totalRepliedCount.isHidden = true
            cell.contentView.isUserInteractionEnabled = true
            cell.currentUser  = currentUser
            cell.commentDelegate = self
            cell.delegate = self
            return cell
        }
     

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if commentModel[indexPath.row].replies!.count > 0 {
            let h = commentModel[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 70, font: UIFont(name: Utilities.font, size: 13)!)
            return CGSize(width: view.frame.width, height: 35 + h! + 45 + 30)
        }else{
            let h = commentModel[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 70, font: UIFont(name: Utilities.font, size: 13)!)
            return CGSize(width: view.frame.width, height: 35 + h! + 45)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isLoadMore {
            return CGSize(width: view.frame.width, height: 20)
        }else{
            return .zero
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCell, for: indexPath) as! MessageDateReusableView
        header.label.text = "Önceki Yorumları Yükle"
        return header
    }
    
}

extension MajorPostCommentController : SwipeCollectionViewCellDelegate {
        
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if commentModel[indexPath.row].senderUid == currentUser.uid {
            if orientation == .right {
                let deleteAction = SwipeAction(style: .destructive, title: "Sil") { action, indexPath in
                    // handle action by updating model with deletion
                }
                deleteAction.image = #imageLiteral(resourceName: "remove")
                return [deleteAction]
            }
            else{
                
                let read = SwipeAction(style: .default, title: "Cevapla") { [weak self] action, indexPath in
                    guard let sself = self else { return }
                    let vc = RepliyCommentVC(targetCommentModel:sself.commentModel[indexPath.row],currentUser: sself.currentUser, postId: sself.commentModel[indexPath.row].postId!, commentId: sself.commentModel[indexPath.row].commentId!,lessonPost: sself.lessonPost,noticesPost: sself.noticesPost,mainPost: sself.mainPost)
                    sself.navigationController?.pushViewController(vc, animated: true)

                }
                read.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
                read.hidesWhenSelected = true
                read.accessibilityLabel = "cevapla"
                read.backgroundColor = .mainColor()
                read.fulfill(with: .reset)
             //   configure(action: read, with: .flag)
                return [read]
            }
        }else{
            
            if orientation == .left {
                let read = SwipeAction(style: .default, title: "Cevapla") {[weak self] action, indexPath in
                    guard let sself = self else { return }
                  let vc =  RepliyCommentVC(targetCommentModel:sself.commentModel[indexPath.row],currentUser: sself.currentUser, postId: sself.commentModel[indexPath.row].postId!, commentId: sself.commentModel[indexPath.row].commentId!,lessonPost: sself.lessonPost,noticesPost: sself.noticesPost,mainPost: sself.mainPost)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }
                read.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
                read.hidesWhenSelected = true
                read.accessibilityLabel = "cevapla"
                read.backgroundColor = .mainColor()
             
                return [read]
            }else{
                return nil
            }
               
            
        }
        
        
        
    }
    
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color(forStyle: buttonStyle)
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color(forStyle: buttonStyle)
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
    
  
}


extension MajorPostCommentController : SwipeCommentCellDelegate {
    func likeClik(cell: SwipeCommentCell) {

        guard let commentModel = cell.comment else { return }
        CommentService.shared.checkLike(commentModel: commentModel, currentUser: currentUser) {[weak self] (_val) in
            guard let sself = self else { return }
            if _val{
          
                commentModel.likes?.append(sself.currentUser.uid)
                sself.collecitonView.reloadData()
               
                if let post = sself.lessonPost {
                    CommentService.shared.likeMainComment(commentModel: commentModel, currentUser: sself.currentUser) { (val) in
                        if val{
                            CommentNotificationService.shared.likeLessonPostComment(post: post, commentModel: commentModel, currentUser: sself.currentUser,text: commentModel.comment!, type: MajorPostNotification.comment_like.type)
                        }
                    }
                    
                    
                }else if let noticesPost = sself.noticesPost
                {
                    CommentService.shared.likeMainComment(commentModel: commentModel, currentUser: sself.currentUser) { (val) in
                        if val{
                            CommentNotificationService.shared.likeNoticesComment(post: noticesPost, commentModel: commentModel, currentUser: sself.currentUser,text:  commentModel.comment!, type: NoticesPostNotification.comment_like.type)
                        }
                    }
                }else if let mainPost = sself.mainPost {
                    CommentService.shared.likeMainComment(commentModel: commentModel, currentUser: sself.currentUser) { (val) in
                        if val{
                            CommentNotificationService.shared.likeMainPostComment(post: mainPost, commentModel: commentModel, currentUser: sself.currentUser,text: commentModel.comment!, type: MainPostNotification.comment_like.type)
                        }
                    }
                }

                    
                    //FIXME:- send notificaiton and push notificaiton
                
            }else{
               
                //removeLike
                commentModel.likes?.remove(element: sself.currentUser.uid)
                sself.collecitonView.reloadData()
                
                CommentService.shared.removeMainLikeComment(commentModel: commentModel, currentUser: sself.currentUser)
            }
        }
        
    }
    
    func replyClick(cell: SwipeCommentCell) {
        guard let commentModel = cell.comment else { return }
        
        
        let vc = RepliyCommentVC(targetCommentModel:commentModel,currentUser: self.currentUser, postId: commentModel.postId!, commentId: commentModel.commentId!,lessonPost: self.lessonPost,noticesPost: self.noticesPost,mainPost: self.mainPost)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllReplies(cell: SwipeCommentCell) {
        
    }
    
    func goProfile(cell: SwipeCommentCell) {
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
    
    
}
