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
    init(currentUser : CurrentUser , postId : String) {
        self.currentUser = currentUser
        self.postId = postId
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
    }
    
    private func getAllComment(postId : String ){
        let db = Firestore.firestore().collection("comment")
            .document(postId)
            .collection("comment")
            .limit(toLast: 10).order(by: "commentId")
        
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
            cell.contentView.isUserInteractionEnabled = false
            cell.currentUser  = currentUser
            return cell
        }else{
            cell.comment = commentModel[indexPath.row]
            cell.backgroundColor = .white
            let h = commentModel[indexPath.row].comment?.height(withConstrainedWidth: view.frame.width - 83, font: UIFont(name: Utilities.font, size: 13)!)
            cell.msgText.frame = CGRect(x: 56, y: 30, width: view.frame.width - 83, height: h! + 4)
            cell.line.isHidden = true
            cell.totalRepliedCount.isHidden = true
            cell.contentView.isUserInteractionEnabled = false
            cell.currentUser  = currentUser

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
        return CGSize(width: view.frame.width, height: 15)
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
                
                let read = SwipeAction(style: .default, title: "Cevapla") { action, indexPath in }
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
                let read = SwipeAction(style: .default, title: "Cevapla") { action, indexPath in }
                read.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
                read.hidesWhenSelected = true
                read.accessibilityLabel = "cevapla"
               // configure(action: read, with: .read)
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
