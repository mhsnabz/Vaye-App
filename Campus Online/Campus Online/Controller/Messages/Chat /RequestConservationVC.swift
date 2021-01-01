//
//  RequestConservationVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MessageKit
import SDWebImage
import CoreLocation
import FirebaseFirestore
import MapKit
import InputBarAccessoryView

class RequestConservationVC:MessagesViewController, InputBarAccessoryViewDelegate {
    
    private lazy var messages = [Message]()
     var currentUser : CurrentUser
     var otherUser : OtherUser
    var page : DocumentSnapshot? = nil
    var firstPage : DocumentSnapshot? = nil
    var customInputView: UIView!
    private let selfSender : Sender?
    weak var snapShotListener : ListenerRegistration?
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return control
    }()
    
    lazy var requestView : UIView = {
       let v = UIView()
      
        v.addSubview(topline)
        topline.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: nil
                       , rigth: v.rightAnchor, marginTop: 0, marginLeft: 5, marginBottom: 0, marginRigth: 5, width: 0, heigth: 1.5)
        v.addSubview(line)
        line.anchor(top: v.topAnchor, left: nil
                    , bottom: v.bottomAnchor, rigth: nil, marginTop: 2, marginLeft: 0, marginBottom: 2, marginRigth: 0, width: 1, heigth: 0)
        line.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        v.addSubview(accepButton)
        accepButton.anchor(top: topline.bottomAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: line.leftAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        v.addSubview(cancelButton)
        cancelButton.anchor(top: topline.bottomAnchor, left: line.rightAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    
    lazy var accepButton :UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 14)
        btn.setTitle("Kabul Et", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        return btn
    }()
    lazy var cancelButton :UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 14)
        btn.setTitle("Sil", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    let line : UIView = {
        let v = UIView()
         v.backgroundColor = .lightGray
         return v
    }()
    let topline : UIView = {
        let v = UIView()
         v.backgroundColor = .lightGray
         return v
    }()
    override var inputAccessoryView: UIView?{
        if customInputView == nil {
            customInputView = CustomView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
            customInputView.backgroundColor = .white
            customInputView.addSubview(requestView)
            requestView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            requestView.trailingAnchor.constraint(
                equalTo: customInputView.trailingAnchor,
                constant: 0
            ).isActive = true
            requestView.leadingAnchor.constraint(
                equalTo: customInputView.leadingAnchor,
                constant: 0
            ).isActive = true
            requestView.topAnchor.constraint(
                equalTo: customInputView.topAnchor,
                constant: 8
            ).isActive = true
            
            requestView.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true

        }
        return customInputView
    }
    
    var shouldBecomeFirstResponder:Bool = true

    override var canBecomeFirstResponder: Bool {
    return shouldBecomeFirstResponder
    }
    
    //MARK:--lifeCycl
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputAccessoryView?.isHidden = false
        messageInputBar.inputTextView.isHidden = false
        messageInputBar.contentView = requestView
        navigationItem.title = otherUser.name
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        snapShotListener?.remove()
         
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        snapShotListener?.remove()
        audioController.stopAnyOngoingPlaying()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setMessagesSetting()
        configureNavBar()
        getAllMessages(currentUser: currentUser, otherUser: otherUser)
        
        view.addSubview(requestView)
        requestView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 56)
        // Do any additional setup after loading the view.
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
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    fileprivate func setMessagesSetting() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.isHidden = true
        messagesCollectionView.register(MessageDateReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        //      messagesCollectionView.showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
       
        
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
    func getAllMessages(currentUser : CurrentUser , otherUser : OtherUser){
        
        let db = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid).limit(toLast: 10).order(by: "id")
        
        
        snapShotListener =  db.addSnapshotListener {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else { return }
                for item in snap.documentChanges{
                    if item.type == .added {
                        
                        var profileUrl = ""
                        if (item.document.get("senderUid") as! String) == currentUser.uid{
                            profileUrl = currentUser.thumb_image
                        }else{
                            profileUrl = otherUser.thumb_image
                        }
                        
                        let sender = Sender(senderId: item.document.get("senderUid") as! String, displayName: item.document.get("name") as! String , profileImageUrl: profileUrl)
                        let date = item.document.get("date") as? Timestamp
                        
                        if (item.document.get("type") as! String) == "photo" {
                            let h = item.document.get("heigth") as! CGFloat
                            let w = item.document.get("width") as! CGFloat
                            let url = item.document.get("content") as! String
                            guard let val = URL(string: url) else { return }
                            if url.contains("doc") {
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "doc-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }else if url.contains("pdf"){
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "pdf-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }else if url.contains("jpg"){
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "camping_icon"), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }
                            
                            
                        }
                        else if (item.document.get("type") as! String) == "text"{
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.text(item.document.get("content") as! String)))
                        }else if (item.document.get("type") as! String) == "location"{
                            let h = item.document.get("heigth") as! CGFloat
                            let w = item.document.get("width") as! CGFloat
                            let val = item.document.get("content") as! GeoPoint
                            let locaiton = Location(location: CLLocation(latitude: val.latitude, longitude: val.longitude), size: CGSize(width: w, height: h))
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .location(locaiton)))
                        }else if (item.document.get("type") as! String) == "audio"{
                            //                            let h = item.document.get("heigth") as! CGFloat
                            //                            let w = item.document.get("width") as! CGFloat
                            let url = item.document.get("content") as! String
                            let duration = item.document.get("duration") as! Float
                            
                            guard let val = URL(string: url) else { return }
                            let audio = Audio(url: val , duration: duration, size: CGSize(width: 200, height: 40), fileName: "fileName")
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .audio(audio)))
                        }
                        sself.messagesCollectionView.reloadDataAndKeepOffset()
                        sself.page = snap.documents.last
                        sself.firstPage = snap.documents.first
                        
                    }
                }
            }
            
        }
        
        guard let page = self.page else { return }
        let next = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid).order(by: "id").start(afterDocument: page).limit(to: 1)
        snapShotListener = next.addSnapshotListener {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            
            if err == nil {
                guard let snap = querySnap else { return }
                for item in snap.documentChanges{
                    if item.type == .added {
                        
                        var profileUrl = ""
                        if (item.document.get("senderUid") as! String) == currentUser.uid{
                            profileUrl = currentUser.thumb_image
                        }else{
                            profileUrl = otherUser.thumb_image
                        }
                        
                        let sender = Sender(senderId: item.document.get("senderUid") as! String, displayName: item.document.get("name") as! String , profileImageUrl: profileUrl)
                        let date = item.document.get("date") as? Timestamp
                        if (item.document.get("type") as! String) == "photo" {
                            let h = item.document.get("heigth") as! CGFloat
                            let w = item.document.get("width") as! CGFloat
                            let url = item.document.get("content") as! String
                            guard let val = URL(string: url) else { return }
                            if url.contains("doc") {
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "doc-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }else if url.contains("pdf"){
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "pdf-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }else if url.contains("jpg"){
                                let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "camping_icon"), size: CGSize(width: w, height: h))
                                sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                            }
                            
                        }
                        else if (item.document.get("type") as! String) == "text"{
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.text(item.document.get("content") as! String)))
                        }else if (item.document.get("type") as! String) == "location"{
                            let h = item.document.get("heigth") as! CGFloat
                            let w = item.document.get("width") as! CGFloat
                            let val = item.document.get("content") as! GeoPoint
                            let locaiton = Location(location: CLLocation(latitude: val.latitude, longitude: val.longitude), size: CGSize(width: w, height: h))
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .location(locaiton)))
                        }else if (item.document.get("type") as! String) == "audio"{
                            //                            let h = item.document.get("heigth") as! CGFloat
                            //                            let w = item.document.get("width") as! CGFloat
                            let url = item.document.get("content") as! String
                            let duration = item.document.get("duration") as! Float
                            guard let val = URL(string: url) else { return }
                            let fileName = item.document.get("fileName") as! String
                            let audio = Audio(url: val , duration: duration, size: CGSize(width: 200, height: 40), fileName: fileName)
                            sself.messages.append(Message(sender: sender, messageId: item.document.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .audio(audio)))
                        }
                        sself.messagesCollectionView.reloadDataAndKeepOffset()
                        sself.page = snap.documents.last
                        sself.firstPage = snap.documents.first
                        
                    }
                }
            }
        }
    }
    private func loadBeforePage(){
        
        guard let page = firstPage else {
            refreshControl.endRefreshing()
            return }
        let db = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid).order(by: "id").end(beforeDocument: page).limit(toLast: 10)
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else {
                    sself.refreshControl.endRefreshing()
                    return
                }
                if snap.isEmpty {
                    sself.refreshControl.endRefreshing()
                    return
                }
                for item in snap.documents{
                    var profileUrl = ""
                    if (item.get("senderUid") as! String) == sself.currentUser.uid{
                        profileUrl = sself.currentUser.thumb_image
                    }else{
                        profileUrl = sself.otherUser.thumb_image
                    }
                    
                    let sender = Sender(senderId: item.get("senderUid") as! String, displayName: item.get("name") as! String , profileImageUrl: profileUrl)
                    
                    let date = item.get("date") as? Timestamp
                    
                    if (item.get("type") as! String) == "photo" {
                        let h = item.get("heigth") as! CGFloat
                        let w = item.get("width") as! CGFloat
                        let url = item.get("content") as! String
                        guard let val = URL(string: url) else { return }
                        if url.contains("doc") {
                            let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "doc-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                            sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                        }else if url.contains("pdf"){
                            let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "pdf-holder").withRenderingMode(.alwaysOriginal), size: CGSize(width: w, height: h))
                            sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                        }else if url.contains("jpg"){
                            let media = Media(url: val, image: nil, placeholderImage:  #imageLiteral(resourceName: "camping_icon"), size: CGSize(width: w, height: h))
                            sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.photo(media)))
                        }
                        
                    }
                    else if (item.get("type") as! String) == "text"{
                        sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind:.text(item.get("content") as! String)))
                    }else if (item.get("type") as! String) == "location"{
                        let h = item.get("heigth") as! CGFloat
                        let w = item.get("width") as! CGFloat
                        let val = item.get("content") as! GeoPoint
                        let locaiton = Location(location: CLLocation(latitude: val.latitude, longitude: val.longitude), size: CGSize(width: w, height: h))
                        sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .location(locaiton)))
                    }else if (item.get("type") as! String) == "audio"{
                        //                        let h = item.get("heigth") as! CGFloat
                        //                        let w = item.get("width") as! CGFloat
                        let url = item.get("content") as! String
                        let duration = item.get("duration") as! Float
                        guard let val = URL(string: url) else { return }
                        let fileName = item.get("fileName") as! String
                        let audio = Audio(url: val , duration: duration, size: CGSize(width: 200, height: 40), fileName: fileName)
                        sself.messages.append(Message(sender: sender, messageId: item.get("id") as! String, sentDate: date?.dateValue() ?? Date(), kind: .audio(audio)))
                    }
                    
                    sself.messages.sort { (msg1, msg2) -> Bool in
                        return msg1.sentDate < msg2.sentDate
                    }
                    sself.messagesCollectionView.reloadDataAndKeepOffset()
                    sself.firstPage = snap.documents.first
                    
                }
                sself.refreshControl.endRefreshing()
            }else{
                sself.refreshControl.endRefreshing()
            }
        }
    }
    //MARK:-selector
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
    @objc func optionsMenu(){
        
    }
    @objc func loadData(){
        
        loadBeforePage()
    }
}


extension RequestConservationVC : MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        var url = [String]()
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        switch message.kind{
        case .photo(let mediaItem):
            guard let imageUrl = mediaItem.url else { return }
            
            if imageUrl.absoluteString.contains("pdf") ||
                imageUrl.absoluteString.contains("doc")
            {
                
                UIApplication.shared.open(imageUrl)
            }
            else
            {
                url.append( imageUrl.absoluteString)
                
                for item in messages{
                    switch item.kind {
                    
                    case .text(_):
                        break
                    case .attributedText(_):
                        break
                    case .photo(let allItem):
                        guard let imageUrl = allItem.url else { return }
                        if !url.contains(imageUrl.absoluteString) {
                            url.append(imageUrl.absoluteString)
                        }
                        
                    case .video(_):
                        break
                    case .location(_):
                        break
                    case .emoji(_):
                        break
                    case .audio(_):
                        break
                    case .contact(_):
                        break
                    case .custom(_):
                        break
                    }
                }
                let vc = ImageSliderVC()
                vc.modalPresentationStyle = .fullScreen
                vc.DataUrl = url
                self.present(vc, animated: true, completion: nil)
            }
            
            
            
            
        case .text(_):
            break
        case .attributedText(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
    }
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        switch message.kind{
        
        case .text(_):
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(let item):
            let coordinates = item.location.coordinate
            let lat = coordinates.latitude
            let long = coordinates.longitude
            let coordinate = CLLocationCoordinate2DMake(lat, long)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
    }
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
        
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        
    }
    func didStartAudio(in cell: AudioMessageCell) {
        
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
}
//MARK:--MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate
extension RequestConservationVC : MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate{
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
        
        if message.kind.messageKindString == "audio"  {
            if sender.senderId == currentUser.uid {
                return .mainColor()
            }else{
                return  UIColor.init(white: 0.80, alpha: 0.5)
            }
            
        }else{
            if sender.senderId == selfSender?.senderId {
                return .mainColor()
            }
            return  UIColor.init(white: 0.80, alpha: 0.5)
        }
        
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
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        let sender = message.sender
        if sender.senderId == currentUser.uid {
            cell.playButton.tintColor = .white
            cell.progressView.progressTintColor = .white
            cell.durationLabel.textColor = .white
            cell.progressView.trackTintColor = .lightGray
            cell.activityIndicatorView.tintColor = .white
        }else{
            cell.playButton.tintColor = .black
            cell.progressView.progressTintColor = .black
            cell.durationLabel.textColor = .black
            cell.progressView.trackTintColor = .darkGray
        }
    }
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard  let message = message as? Message else {
            return
        }
        
        switch message.kind{
        case .photo(let media):
            guard let url = media.url else { return }
            if url.absoluteString.contains("doc") {
                imageView.contentMode = .scaleAspectFill
                imageView.image = #imageLiteral(resourceName: "doc-holder").withRenderingMode(.alwaysOriginal)
            }else if url.absoluteString.contains("pdf"){
                imageView.contentMode = .scaleAspectFill
                imageView.image = #imageLiteral(resourceName: "pdf-holder").withRenderingMode(.alwaysOriginal)
            }else if url.absoluteString.contains("jpg"){
                imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
                imageView.sd_setImage(with: url)
            }
            
            
        case .text(_):
            break
        case .attributedText(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
    }
    
    
    
}
