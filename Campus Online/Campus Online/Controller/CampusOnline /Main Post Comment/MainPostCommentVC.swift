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
private let food_me_header = "food_me_header"
private let food_me_data_header = "food_me_data_header"
private let camping_header = "camping_header"
private let camping_data_header = "camping_data_header"
class MainPostCommentVC: UIViewController , DismisDelegate {
    func dismisMenu() {
        inputAccessoryView?.isHidden = false
    }
    
    //MARK: - variables
    var currentUser : CurrentUser
    var post : MainPostModel
    var comment = [CommentModel]()
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    var size : CGFloat!
    weak var messagesListener : ListenerRegistration?
    private var actionSheetCurrentUser : ActionSheetMainPost
    private var actionSheetOtherUser : ASMainPostOtherUser
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
        self.actionSheetCurrentUser = ActionSheetMainPost(currentUser: currentUser, target: TargetASMainPost.ownerPost.description)
        self.actionSheetOtherUser = ASMainPostOtherUser(currentUser: currentUser, target: TargetOtherUser.otherPost.description)
        super.init(nibName: nil, bundle: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = post.lessonName
        inputAccessoryView?.isHidden = false
        
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
    @objc func optionsLauncher()
    {
        if post.senderUid == currentUser.uid
        {
            actionSheetCurrentUser.delegate = self
            actionSheetCurrentUser.dismisDelgate = self
            actionSheetCurrentUser.show(post: post)
            inputAccessoryView?.isHidden = true
        }else{
            actionSheetOtherUser.delegate = self
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
                guard let sself = self else { return }
                sself.actionSheetOtherUser.show(post: sself.post, otherUser: user)
                sself.actionSheetOtherUser.dismisDelegate = self
                sself.inputAccessoryView?.isHidden = true
                
            }
        }
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
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 50 + 35
                self.tableView.reloadData()
            }else{
                tableView.register(SellBuyDataCommentHeader.self, forHeaderFooterViewReuseIdentifier: sell_buy_data_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 100 + 50 + 35
                self.tableView.reloadData()
            }
            
        }
        else if target == PostType.foodMe.despription {
            if post.data.isEmpty{
                tableView.register(FoodMeCommentHeader.self, forHeaderFooterViewReuseIdentifier: food_me_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 45 + 5 
                self.tableView.reloadData()
            }else{
                tableView.register(FoodMeDataCommentHeader.self, forHeaderFooterViewReuseIdentifier: food_me_data_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 100 + 50 + 5
                self.tableView.reloadData()
            }
        }
        else if target == PostType.camping.despription
        {
            if post.data.isEmpty{
                tableView.register(CampingCommentHeader.self, forHeaderFooterViewReuseIdentifier: camping_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 45 + 5
                self.tableView.reloadData()
            }else{
                tableView.register(CampingDataCommentHeader.self, forHeaderFooterViewReuseIdentifier: camping_data_header)
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                size = h
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 100 + 50 + 5
                self.tableView.reloadData()
            }
        }else if target == PostType.party.despription{
            
        }
        
        
    }
    func removeComment(commentID : String , postID : String , completion : @escaping(Int) -> Void){
        //main-post/sell-buy/post/1603888561458/comment/1603986010312
        let db = Firestore.firestore().collection("main-post")
            .document("post")
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
    func getTotolCommentCount(completion : @escaping(Int) -> Void){
        ///main-post/sell-buy/post/1604436850197/comment/1604773265884
        let db = Firestore.firestore().collection("main-post")
            .document("post")
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
    func removeRepliedComment(commentID : String){
        //main-post/sell-buy/post/1603888561458/comment/1603986010312
        let db = Firestore.firestore().collection("main-post")
            .document("post")
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
                        let dbc = Firestore.firestore().collection("main-post")
                            .document("post")
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
    func getComments(currentUser : CurrentUser , postID : String ){        
        let db = Firestore.firestore().collection("main-post")
            .document("post")
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
            UserService.shared.getOtherUser(userId: post.senderUid) {[weak self] (user) in
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
    func clickUserName(username: String) {
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if target == PostType.buySell.despription {
            if post.data.isEmpty{
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
            }else{
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sell_buy_data_header) as! SellBuyDataCommentHeader
                
                cell.currentUser = currentUser
                cell.delegate = self
                cell.backgroundColor = .white
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                cell.priceLbl.anchor(top: cell.msgText.bottomAnchor, left: cell.msgText.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
                
//                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4 + 20 + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.priceLbl.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.post = post
                return cell
            }
            
        }
        else if target == PostType.foodMe.despription {
            if post.data.isEmpty {
                
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: food_me_header) as! FoodMeCommentHeader
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
               
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.post = post
                return cell
                
            }else{
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: food_me_data_header) as! FoodMeDataCommentHeader
                cell.delegate = self
                cell.backgroundColor = .white
                cell.currentUser = currentUser
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                
                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.post = post
                return cell
            }
        }
        else if target == PostType.camping.despription {
            if post.data.isEmpty {
                
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: camping_header) as! CampingCommentHeader
                cell.delegate = self
                cell.currentUser = currentUser
                cell.backgroundColor = .white
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
               
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.post = post
                return cell
                
            }else{
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: camping_data_header) as! CampingDataCommentHeader
                cell.delegate = self
                cell.backgroundColor = .white
                cell.currentUser = currentUser
                let h = post.text.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
                cell.msgText.frame = CGRect(x: 70, y: 38, width: view.frame.width - 78, height: h + 4)
                
                cell.filterView.frame = CGRect(x: 70, y: 40 + 8 + h + 4  + 4 , width: cell.msgText.frame.width, height: 100)
                
                cell.bottomBar.anchor(top: nil, left: cell.msgText.leftAnchor, bottom: cell.bottomAnchor, rigth: cell.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 30)
                cell.post = post
                return cell
            }
            
        }else if target == PostType.party.despription{
            
        }
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sell_buy_data_header) as! SellBuyDataCommentHeader
        return cell
 
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
            guard let uid = comment.senderUid else {
                Utilities.dismissProgress()
                return}
            UserService.shared.getOtherUser(userId: uid) {[weak self] (user) in
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
        clickUserName(username: userName)
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
//MARK:ASMainPostLaungerDelgate
extension MainPostCommentVC : ASMainPostLaungerDelgate {
    func didSelect(option: ASCurrentUserMainPostOptions) {
        switch option {
        case .editPost(_):
           
                if post.postType == PostType.foodMe.despription{
                    let vc = EditFoodMePost(currentUser: currentUser, post: post, h: size)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: {
                                    Utilities.dismissProgress()
                        
                    })
                }else if post.postType == PostType.buySell.despription{
                    let vc = EditSellBuyPost(currentUser: currentUser, post: post, h: size)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: {
                                 Utilities.dismissProgress()
                     
                 })
                }else if post.postType == PostType.camping.despription{
                    let vc = EditCampingPost(currentUser: currentUser, post: post, h: size)
                    let controller = UINavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: {
                                 Utilities.dismissProgress()
                     
                 })
                }
          
           
            break
        case .deletePost(_):
            
            Utilities.waitProgress(msg: "Siliniyor")
            
           
            let db = Firestore.firestore().collection("main-post")
                .document("post")
                .collection("post")
                .document(post.postId)
            
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    
                    MainPostService.shared.deleteToStorage(data: sself.post.data, postId: sself.post.postId) { (_val) in
                        if (_val){
                            Utilities.succesProgress(msg: "Silindi")
                        }
                    }
                }else{
                    Utilities.errorProgress(msg: "Hata Oluştu")
                }
            }
            break
        case .slientPost(_):
            print("slient post")
        }
    }
    
    
}
//MARK: SellBuyDataCommentHeaderDelegate
extension MainPostCommentVC : SellBuyDataCommentHeaderDelegate {
    func like(for header: SellBuyDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.buy_sell.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: SellBuyDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.buy_sell.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: SellBuyDataCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func mapClik(for header: SellBuyDataCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
}
//MARK:-FoodMeCommentHeaderDelegate
extension MainPostCommentVC : FoodMeCommentHeaderDelegate {
    func like(for header: FoodMeCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.food_me.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: FoodMeCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.food_me.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: FoodMeCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func mapClik(for header: FoodMeCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
    
}

//MARK:-FoodMeDataCommentHeaderDelegate
extension MainPostCommentVC : FoodMeDataCommentHeaderDelegate {
    func like(for header: FoodMeDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.food_me.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: FoodMeDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.buy_sell.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: FoodMeDataCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func mapClik(for header: FoodMeDataCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
    
}
//MARK:- CampingCommentHeaderDelegate
extension MainPostCommentVC :  CampingCommentHeaderDelegate{
    func like(for header: CampingCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.camping.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: CampingCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.camping.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: CampingCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func mapClik(for header: CampingCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
    
}
//MARK:- CampingDataCommentHeaderDelegate
extension MainPostCommentVC :  CampingDataCommentHeaderDelegate{
    func like(for header: CampingDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderLikePost(target: MainPostLikeTarget.camping.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func dislike(for header: CampingDataCommentHeader) {
        guard let post = header.post else { return }
        MainPostService.shared.setHeaderDislike(target: MainPostLikeTarget.camping.description, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            print("succes")
        }
    }
    
    func showProfile(for header: CampingDataCommentHeader) {
        guard  let post = header.post else {
            return
        }
        showUserProfile(post: post)
    }
    
    func mapClik(for header: CampingDataCommentHeader) {
        guard let post = header.post else { return }
        guard let locaitonName = post.locationName else { return }
        guard let lat = post.geoPoint?.latitude else { return }
        guard let longLat = post.geoPoint?.longitude else { return }
        openInMap(lat: lat, longLat: longLat, locationName: locaitonName)
    }
    
    
}
extension MainPostCommentVC : ASMainOtherUserDelegate {
    func didSelect(option: ASMainPostOtherUserOptions) {
        switch option {
        
        case .fallowUser(_):
            break
        case .slientUser(_):
            break
        case .slientPost(_):
            break
        case .reportPost(_):
            
            
            if post.postType == PostType.buySell.despription {
                let vc = ReportingVC(target: ReportTarget.buySellPost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportPost.description)
                navigationController?.pushViewController(vc, animated: true)
                
            }else if post.postType == PostType.foodMe.despription{
                let vc = ReportingVC(target: ReportTarget.foodMePost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportPost.description)
                navigationController?.pushViewController(vc, animated: true)
            }else if post.postType == PostType.camping.despription{
                let vc = ReportingVC(target: ReportTarget.campingPost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportPost.description)
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .reportUser(_):
           
            if post.postType == PostType.buySell.despription {
                let vc = ReportingVC(target: ReportTarget.buySellPost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportUser.description)
                navigationController?.pushViewController(vc, animated: true)
                
            }else if post.postType == PostType.foodMe.despription{
                let vc = ReportingVC(target: ReportTarget.foodMePost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportUser.description)
                navigationController?.pushViewController(vc, animated: true)
            }else if post.postType == PostType.camping.despription{
                let vc = ReportingVC(target: ReportTarget.campingPost.description, currentUser: currentUser, otherUser: post.senderUid, postId: post.postId, reportType: ReportType.reportUser.description)
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        }
    }
    
    
}
