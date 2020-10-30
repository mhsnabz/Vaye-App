//
//  MainPostCommentVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 25.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MapKit
import CoreLocation
private let msgCellID = "msgCellID"
private let sell_buy_header = "cell-buy-header"
private let sell_buy_data_header = "cell-buy-data-header"
class MainPostCommentVC: UIViewController {
    //MARK: - variables
    var currentUser : CurrentUser
    var post : MainPostModel
    var comment = [CommentModel]()
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    weak var messagesListener : ListenerRegistration?
    let target : String
    var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    //MARK:- properties
    
    
    //MARK: -lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboardWhenTappedAround()
        getComments(currentUser: currentUser, postID: post.postId)
        
    }
    init(currentUser : CurrentUser , post : MainPostModel , target : String) {
        self.currentUser = currentUser
        self.post = post
        self.target = target
        super.init(nibName: nil, bundle: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = post.lessonName
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messagesListener?.remove()
        //        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesListener?.remove()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - selectors
    @objc func optionsLauncher(){
        
    }
    @objc func sendMsg(){
        guard let text = textField.text else { return }
        if textField.hasText {
            textField.text = ""
            let commentId  = Int64(Date().timeIntervalSince1970 * 1000).description
            MainPostCommentService.shared.setNewComment(currentUser: currentUser, target: target, commentText: text, postId: post.postId, commentId: commentId) { (_val) in
            }
            MainPostCommentService.shared.send_comment_notificaiton(post: post, currentUser: currentUser, text: text, type: NotificationType.comment_home.desprition)
            for item in text.findMentionText(){
                MainPostCommentService.shared.send_comment_mention_user(username: item, currentUser: currentUser, text: text, type: NotificationType.comment_mention.desprition, post: post)}
        }
    }
    @objc func showMenu(){
        
    }
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
        
        if target == PostType.buySell.despription {
            if post.data.isEmpty{
                tableView.register(SellBuyCommentHeader.self, forHeaderFooterViewReuseIdentifier: sell_buy_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 50 + 35
                self.tableView.reloadData()
            }else{
                
            }
            
        }else if target == PostType.camping.despription {
            
        }else if target == PostType.foodMe.despription {
            
        }else if target == PostType.party.despription{
            
        }
        
        
    }
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
    func getComments(currentUser : CurrentUser , postID : String ){        
        let db = Firestore.firestore().collection("main-post")
            .document(post.postType)
            .collection("post")
            .document(post.postId)
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
    
    private func showUserProfile(post : MainPostModel){
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
                
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                vc.modalPresentationStyle = .fullScreen
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
                
                
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
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                sself.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    private func openInMap(lat  : Double!  , longLat : Double! , locationName : String!){
        let coordinate = CLLocationCoordinate2DMake(lat, longLat)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = locationName
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    func replyAction(at indexPath :IndexPath , tableView : UITableView , comment : CommentModel , currentUser : CurrentUser , post : MainPostModel) ->UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Cevapla") {[weak self] (action, view, completion) in
            guard let sself = self  else { return }
            tableView.reloadData()
            let vc = MainPostReplyVC(comment: comment, currentUser: currentUser, post: post)
            sself.navigationController?.pushViewController(vc, animated: true)
            
        }
        action.backgroundColor = .mainColor()
        
        action.image = UIImage(named: "reply")
        return action
    }
    
}
//MARK:-  UITableViewDataSource, UITableViewDelegate
extension MainPostCommentVC :  UITableViewDataSource, UITableViewDelegate{
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if comment[indexPath.row].senderUid == currentUser.uid {
            let edit = MainPostCommentService.shared.editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete,edit])
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sell_buy_header) as! SellBuyCommentHeader
        
        cell.currentUser = currentUser
        cell.delegate = self
        cell.backgroundColor = .white
        let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
        cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
        cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        cell.bottomBar.anchor(top: nil, left: cell.priceLbl.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
        cell.post = post
        return cell
        
        //        if target == PostType.buySell.despription {
        //            if post.data.isEmpty{
        //                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sell_buy_header) as! SellBuyCommentHeader
        //                return header
        //            }else{
        //
        //            }
        //
        //        }else if target == PostType.camping.despription {
        //
        //        }else if target == PostType.foodMe.despription {
        //
        //        }else PostType.party.despription{
        //
        //        }
    }
    
    
}
//MARK:-CommentDelegate
extension MainPostCommentVC : CommentDelegate{
    func likeClik(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        
        MainPostCommentService.shared.setLike(comment: comment, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            
        }
    }
    
    func replyClick(cell: CommentMsgCell) {
        guard let comment = cell.comment else { return }
        let vc = MainPostReplyVC(comment: comment, currentUser: currentUser, post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllReplies(cell: CommentMsgCell)
    {
        guard let comment = cell.comment else { return }
        let vc = MainPostReplyVC(comment: comment, currentUser: currentUser, post: post)
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
                let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: user)
                sself.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
            }
        }
    }
    
    
}
//MARK:- SellBuyDelegate
extension MainPostCommentVC : SellBuyCommentHeaderDelegate {
    func like(for header: SellBuyCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.buy_sell.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: SellBuyCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.buy_sell.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: SellBuyCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func goProfileByMention(userName: String) {
        
    }
    
    func clickMention(username: String) {
        clickUserName(username: username)
    }
    
    func mapClik(for header: SellBuyCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
    
}
