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

        hideKeyboardWhenTappedAround()

    }
    init(currentUser : CurrentUser , post : MainPostModel) {
        self.currentUser = currentUser
        self.post = post
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
    }
    


}
//MARK:-  UITableViewDataSource, UITableViewDelegate
extension MainPostCommentVC :  UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: msgCellID, for: indexPath) as! CommentMsgCell
        return cell
    }
    
    
}
