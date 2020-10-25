//
//  MainPostCommentVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 25.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
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
                self.tableView.sectionHeaderHeight = 40 + 8 + h + 4 + 4 + 50 + 5
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
            let edit = CommentService.shared.editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)
            
            return UISwipeActionsConfiguration(actions: [delete,edit])
        }
        else
        {
            let report = CommentService.shared.reportAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [report])
        }
        
     
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let reply = CommentService.shared.replyAction(at: indexPath, tableView: self.tableView, comment: comment[indexPath.row], currentUser: currentUser, post: post)
        return UISwipeActionsConfiguration(actions: [reply])
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sell_buy_header) as! SellBuyCommentHeader
     
        cell.currentUser = currentUser
        
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
        
        CommentService.shared.setLike(comment: comment, tableView: tableView, currentUser: currentUser, post: post) { (_) in
            
        }
    }
    
    func replyClick(cell: CommentMsgCell) {
        
    }
    
    func seeAllReplies(cell: CommentMsgCell) {
        
    }
    
    func goProfile(cell: CommentMsgCell) {
        
    }
    
    
}
