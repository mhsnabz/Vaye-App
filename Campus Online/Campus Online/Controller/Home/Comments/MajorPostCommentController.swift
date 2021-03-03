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
class MajorPostCommentController: UIViewController {
    var buttonStyle: ButtonStyle = .backgroundColor
     var currentUser : CurrentUser
    var postId : String
    var defaultOptions = SwipeOptions()
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    weak var snapShotListener : ListenerRegistration?
    var page : DocumentSnapshot? = nil
    var commentModel = [CommentModel]()
    var firstPage : DocumentSnapshot? = nil
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
    
        layout.minimumLineSpacing = .zero
        layout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
 
        return cv
    }()
    
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
    
    //MARK:-functions
    
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collecitonView.register(SwipeCommentCell.self, forCellWithReuseIdentifier: commentCell)
        collecitonView.register(MessageDateReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCell)
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
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
            var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .fill : .selection
        options.backgroundColor = defaultOptions.backgroundColor

            switch buttonStyle {
            case .backgroundColor:
                options.buttonSpacing = 11
            case .circular:
                options.buttonSpacing = 4
            #if canImport(Combine)
                if #available(iOS 13.0, *) {
                    options.backgroundColor = UIColor.systemGray6
                } else {
                    options.backgroundColor = #colorLiteral(red: 0.2327457368, green: 0.5623961091, blue: 0.9373269677, alpha: 1)
                }
            #else
                options.backgroundColor = #colorLiteral(red: 0.009416126646, green: 0.562579155, blue: 0.9707954526, alpha: 1)
            #endif
            }
        
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if currentUser.uid == currentUser.uid {
            if orientation == .right {
                let deleteAction = SwipeAction(style: .destructive, title: "Sil") { action, indexPath in
                    // handle action by updating model with deletion
                }
                configure(action: deleteAction, with: .trash)
                return [deleteAction]
            }
            else{
                
                let read = SwipeAction(style: .default, title: nil) { action, indexPath in }
                read.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
                read.hidesWhenSelected = true
                read.accessibilityLabel = "cevapla"
                configure(action: read, with: .flag)
                return [read]
            }
        }else{
            
            if orientation == .left {
                let read = SwipeAction(style: .default, title: "Cevapla") { action, indexPath in }
                read.image = #imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal)
                read.hidesWhenSelected = true
                read.accessibilityLabel = "cevapla"
                configure(action: read, with: .read)
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
