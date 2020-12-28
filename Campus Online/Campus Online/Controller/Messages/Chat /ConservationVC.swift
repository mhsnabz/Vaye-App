//
//  ConservationVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MessageKit
import SDWebImage
import InputBarAccessoryView
import CoreLocation
import FirebaseFirestore
class ConservationVC: MessagesViewController {
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .short
        formattre.timeStyle = .medium
        formattre.locale = .current
          return formattre
      }()
    var page : DocumentSnapshot? = nil
    var currentUser : CurrentUser
    var otherUser : OtherUser
    private let selfSender : Sender?
    private var messages = [Message]()
    public var isNewConversation = false
    weak var snapShotListener : ListenerRegistration?
    var isLoadMore : Bool?{
        didSet{
            guard let loadMore = isLoadMore else { return }
            if loadMore {
                print("loadMore item")
            }else{
                print("stop item")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMessagesSetting()
        getAllMessages(currentUser: currentUser, otherUser: otherUser)
        configureNavBar()
        setupInputButton()
    }
    
    init(currentUser : CurrentUser , otherUser : OtherUser) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        selfSender = Sender(senderId: currentUser.uid, displayName: currentUser.name, profileImageUrl: currentUser.thumb_image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        messagesCollectionView.scrollToBottom()
        
        
    }
    //MARK: -- functions
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(#imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), for: .normal)
//        button.onTouchUpInside { [weak self] _ in
//            //  self?.presentInputActionSheet()
//        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
        let sendButton = InputBarButtonItem()
        sendButton.setSize(CGSize(width: 35, height: 35), animated: false)
        sendButton.setImage(#imageLiteral(resourceName: "send").withRenderingMode(.alwaysOriginal), for: .normal)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([sendButton], forStack: .right, animated: false)
        sendButton.addTarget(self, action: #selector(sendMessages), for: .touchUpInside)
    }
    fileprivate func setMessagesSetting() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messagesCollectionView.register(MessageDateReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    
        
    }
    
    fileprivate func configureNavBar(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(goProfile))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "options_dots").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(optionsMenu))
        navigationItem.title = otherUser.name
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        
        imageview.contentMode = .scaleAspectFit
        imageview.layer.cornerRadius = 35 / 2
        imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 0.3
        imageview.layer.borderColor = UIColor.darkGray.cgColor
        imageview.addGestureRecognizer(tap)
        imageview.isUserInteractionEnabled = true
        containView.addSubview(imageview)
        let leftButton = UIBarButtonItem(customView: containView)
        
        imageview.sd_imageIndicator = SDWebImageActivityIndicator.white
        imageview.sd_setImage(with: URL(string: otherUser.thumb_image))
        self.navigationItem.leftItemsSupplementBackButton = true
        
        navigationItem.leftBarButtonItems = [leftButton]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           print("y: \(scrollView.contentOffset.y)")
            
           if scrollView.contentOffset.y < 0{
              isLoadMore = true
           }else{
            isLoadMore = false
           }
       }
    
    func getAllMessages(currentUser : CurrentUser , otherUser : OtherUser){
        let db = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid).limit(toLast: 10).order(by: "id")
             
        db.getDocuments  {[weak self] (querySnap, err) in
                        guard let sself = self else { return }
                        if err == nil {
                            guard let snap = querySnap else { return }
                            for item in snap.documents{
                                
            
                                    var profileUrl = ""
                                    if (item.get("senderUid") as! String) == currentUser.uid{
                                        profileUrl = currentUser.thumb_image
                                    }else{
                                        profileUrl = otherUser.thumb_image
                                    }
            
                                    let sender = Sender(senderId: item.get("senderUid") as! String, displayName: item.get("name") as! String , profileImageUrl: profileUrl)
                                    let date = item.get("date") as? Timestamp
            
                                    sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.text(item.get("content") as! String)))
                                    sself.messagesCollectionView.reloadData()
            
                                
                            }
                            sself.page = snap.documents.last
                            print("last documentId : \(snap.documents.first?.documentID)")
                        }
                    }
        
       
//        db.addSnapshotListener {[weak self] (querySnap, err) in
//            guard let sself = self else { return }
//            if err == nil {
//                guard let snap = querySnap else { return }
//                for item in snap.documentChanges{
//                    if item.type == .added {
//
//                        var profileUrl = ""
//                        if (item.document.get("senderUid") as! String) == currentUser.uid{
//                            profileUrl = currentUser.thumb_image
//                        }else{
//                            profileUrl = otherUser.thumb_image
//                        }
//
//                        let sender = Sender(senderId: item.document.get("senderUid") as! String, displayName: item.document.get("name") as! String , profileImageUrl: profileUrl)
//                        let date = item.document.get("date") as? Timestamp
//
//                        sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.text(item.document.get("content") as! String)))
//                        sself.messagesCollectionView.reloadData()
//
//                    }
//                }
//            }
//        }
    }
    

    
    //MARK:-- selectors
    
    @objc func sendMessages(){
 
        guard let text = messageInputBar.inputTextView.text else { return }
        messageInputBar.inputTextView.text = ""
        let message =  Message(sender: selfSender!, messageId: Int64(Date().timeIntervalSince1970 * 1000).description, sentDate: Date(), kind: .text(text) )
        MessagesService.shared.sendMessage(newMessage: message, currentUser: currentUser, otherUser: otherUser , time : Int64(Date().timeIntervalSince1970 * 1000))
        messagesCollectionView.scrollToBottom()
        
    }
    
    @objc func optionsMenu()
    {
        print("options")
    }
    @objc func goProfile(){
        UserService.shared.getProfileModel(otherUser: otherUser, currentUser: currentUser) {[weak self] (model) in
            guard let sself = self else { return }
            UserService.shared.checkOtherUserSocialMedia(otherUser: sself.otherUser) { (val) in
                if val{
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: sself.otherUser, profileModel: model, width: 285)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: sself.otherUser, profileModel: model, width: 235)
                    sself.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
}
//MARK:--MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate
extension ConservationVC : MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return selfSender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            avatarView.sd_setImage(with: URL(string: currentUser.thumb_image), completed: nil)
        }else{
            avatarView.sd_setImage(with: URL(string: otherUser.thumb_image), completed: nil)
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .mainColor()
        }
        return  UIColor.init(white: 0.80, alpha: 0.5)
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .white
        }
        return .black
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        let size = CGSize(width: messagesCollectionView.frame.width, height: 25)
        if section == 0 {
            return size
        }
        
        let currentIndexPath = IndexPath(row: 0, section: section)
        let lastIndexPath = IndexPath(row: 0, section: section - 1)
        let lastMessage = messageForItem(at: lastIndexPath, in: messagesCollectionView)
        let currentMessage = messageForItem(at: currentIndexPath, in: messagesCollectionView)
        
        if currentMessage.sentDate.isInSameDayOf(date: lastMessage.sentDate) {
            return .zero
        }
        
        return size
    }
    
    // MARK: Header
    
    func messageHeaderView( for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView ) -> MessageReusableView {
        let messsage = messageForItem(at: indexPath, in: messagesCollectionView)
        let header = messagesCollectionView.dequeueReusableHeaderView(MessageDateReusableView.self, for: indexPath)
        header.label.text = MessageKitDateFormatter.shared.string(from: messsage.sentDate)
        return header
    }
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 14
    }
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = MessageKitDateFormatter.shared.string(from: messages[[indexPath.section][indexPath.item]].sentDate)
 
        return NSMutableAttributedString(string: "\(dateString)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 10)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    
   
    
    
}
//MARK:--import InputBarAccessoryView

extension ConservationVC : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        print("text : \(text)")
    }
}

class MessageDateReusableView: MessageReusableView {
    var label: PaddingLabel!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = .none
        
        label = PaddingLabel()
        label.backgroundColor = .white
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 11)
        label.paddingLeft = 5
        label.paddingRight = 5
        self.addSubview(label)
        
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = .lightGray
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self.center)
            make.top.equalTo(self.snp.top).offset(2)
            make.bottom.equalTo(self.snp.bottom).offset(-2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class PaddingLabel: UILabel {
    
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
}

