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
    
    
    //MARK:-seletors
    @objc func sendMsg(){
        
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
        return cell
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
}
//MARK:-NoticesCommenHeaderDelegate
extension NoticeVCComment : NoticesCommenHeaderDelegate {
    func like(for header: NoticesCommentHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.like(target: MainPostLikeTarget.notices.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for header: NoticesCommentHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.dislike(target: MainPostLikeTarget.notices.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
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
        NoticesService.shared.like(target: MainPostLikeTarget.notices.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("liked")
        }
    }
    
    func dislike(for header: NoticesCommentDataHeader) {
        guard let post = header.post else { return }
        NoticesService.shared.dislike(target: MainPostLikeTarget.notices.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
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
