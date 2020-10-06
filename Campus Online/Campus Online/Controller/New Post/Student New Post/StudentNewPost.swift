//
//  StudentNewPost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let imageCell = "cellId"
private let pdfCell = "pdfCell"
private let docCell = "docCell"
private let headerId = "headerId"
import SDWebImage
import MobileCoreServices
import ImagePicker
import Lightbox
import Gallery
import SVProgressHUD
import PDFKit
import ActiveLabel
import FirebaseFirestore
struct MentionUser {
    let userID : String!
    let username : String!
}

class StudentNewPost: UIViewController, LightboxControllerDismissalDelegate ,GalleryControllerDelegate {
    var postDate : String!
    var dataModel = [DatasModel]()
    var viewController : UIViewController!
    private var actionSheet : ActionSheetLauncher
    private var addUserSheet : AddUserLaunher
    var totolDataInMB : Float = 0.0
    var gallery: GalleryController!
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var success = true
     var fallowers = [LessonFallowerUser]()
    var selectedLesson : String
    var link : String?
    let lbl = UILabel(frame: .zero)
    var userNames = [String]()
    let cloudImage : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    let cloudLink : UIButton = {
        let btn = UIButton(type: .system)
        
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    let removeLink : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
       
        return btn
    }()
    
    lazy var cloudDriveLink : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.addSubview(cloudImage)
        cloudImage.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 5, marginLeft: 0, marginBottom: 5, marginRigth: 0, width: 20, heigth: 20)
        v.addSubview(cloudLink)
        cloudLink.anchor(top: nil, left: cloudImage.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        cloudLink.centerYAnchor.constraint(equalTo: cloudImage.centerYAnchor).isActive = true
       
        return v
    }()
    var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    
    lazy var popUpWindow: PopUpWindow = {
        let view = PopUpWindow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.delegate = self
        return view
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImage : UIImageView = {
        let imagee = UIImageView()
        imagee.clipsToBounds = true
        imagee.contentMode = .scaleAspectFit
        imagee.layer.borderColor = UIColor.lightGray.cgColor
        imagee.layer.borderWidth = 0.5
        
        return imagee
        
    }()
    let userName : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        
        return lbl
    }()
    let lessonName : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    lazy var text : CaptionText = {
        let text = CaptionText()
        text.backgroundColor = .white
        text.font = UIFont(name: Utilities.font, size: 14)
        text.isEditable = true
        text.dataDetectorTypes = [.all]
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = true
        text.isScrollEnabled = true
        text.isSelectable = true
        return text
    }()
    
    
    lazy var headerView : UIView = {
        let view = UIView()
        view.addSubview(profileImage)
        profileImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 56, heigth: 56)
        profileImage.layer.cornerRadius = 56 / 2
        view.addSubview(userName)
        userName.anchor(top: profileImage.topAnchor, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        view.addSubview(lessonName)
        lessonName.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: userName.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 18)
        
        return view
    }()
    
    let addDoc : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "doc")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addDoc), for: .touchUpInside)
        return btn
    }()
    let addPdf : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "pdf")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addPdf), for: .touchUpInside)
        return btn
    }()
    let addImage : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "gallery")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addImage), for: .touchUpInside)
        return btn
    }()
    let addLink : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "link")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addLink), for: .touchUpInside)
        return btn
    }()
    
    //MARK:- lifeCycle
    init(currentUser : CurrentUser ,selectedLesson : String , users : [LessonFallowerUser]) {
        self.currentUser = currentUser
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser, target: Target.drive.description)
        self.addUserSheet = AddUserLaunher(currentUser: currentUser)
        self.selectedLesson = selectedLesson
        self.fallowers = users
        super.init(nibName: nil, bundle: nil)
        self.postDate = Int64(Date().timeIntervalSince1970 * 1000).description
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        view.backgroundColor = .white
        configureCollectionView()
        configure()
        hideKeyboardWhenTappedAround()
        rigtBarButton()
        removeLink.addTarget(self, action: #selector(removeLinkClick), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        text.becomeFirstResponder()
    }
    
    //MARK: - func
    
    @objc func removeLinkClick () {
        link = ""
        self.cloudDriveLink.isHidden = true
        removeLink.isHidden = true
    }
    private func detectLink(_ link : String){
        let url = NSURL(string: link)
        let domain = url?.host
        guard let link = domain else { return }
        print(link)
        if link == "drive.google.com" || link == "www.drive.google.com" {
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = false
            self.cloudImage.image = UIImage(named: "google-drive")
            self.cloudLink.setTitle("Google Drive Bağlantısı", for: .normal)
        }else if link == "dropbox.com" || link == "www.dropbox.com"{
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = true
            self.cloudImage.image = UIImage(named: "dropbox")
            self.cloudLink.setTitle("Dropbox Bağlantısı", for: .normal)
        }else if link == "icloud.com" || link == "www.icloud.com"{
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = false
            self.cloudImage.image = UIImage(named: "icloud")
            self.cloudLink.setTitle("iCloud Bağlantısı", for: .normal)
        }else if link == "disk.yandex.com.tr" || link == "disk.yandex.com" || link == "yadi.sk"{
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = false
            self.cloudImage.image = UIImage(named: "yandex-disk")
            self.cloudLink.setTitle("Yandex Disk Bağlantısı", for: .normal)
        }else if link == "onedrive.live.com" || link == "www.onedrive.live.com" || link == "1drv.ms"{
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = false
            self.cloudImage.image = UIImage(named: "onedrive")
            self.cloudLink.setTitle("OneDrive Bağlantısı", for: .normal)
        }else if link == "mega.nz" || link == "www.mega.nz"{
            self.cloudDriveLink.isHidden = false
            removeLink.isHidden = false
            self.cloudImage.image = UIImage(named: "mega")
            self.cloudLink.setTitle("Mega.nz Bağlantısı", for: .normal)
        }else{
            self.cloudDriveLink.isHidden = true
            removeLink.isHidden = false
            Utilities.errorProgress(msg: "Bu Bağlantıyı Tanımayamadık")
        }
        
    }
    private func checkDataModelHasValue(data : Data) ->Bool{
        dataModel.contains { (model) -> Bool in
           return  model.data == data
        }
    }
    private func goToLink(_ target : String)
    {  if let url = URL(string: target){
        UIApplication.shared.open(url) }
        
    }
    fileprivate func rigtBarButton() {
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setNewPost))
        
        let button: UIButton = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "post-it")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(setNewPost), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }

    fileprivate func configureCollectionView() {
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 80)

        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 100)
        text.delegate = self
        text.isScrollEnabled = true
        textViewDidChange(text)
        
        let stack = UIStackView(arrangedSubviews: [addImage,addDoc,addPdf,addLink])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 20) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        view.addSubview(cloudDriveLink)
        cloudDriveLink.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, bottom: nil, rigth: nil, marginTop: 5, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        
        view.addSubview(removeLink)
        removeLink.anchor(top: stack.bottomAnchor, left: nil, bottom: nil, rigth: stack.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 20, width: 0, heigth: 25)

        removeLink.isHidden = true
        
        cloudDriveLink.isHidden = true
 
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        view.addSubview(collectionview)
        
        collectionview.anchor(top: cloudDriveLink.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth:view.rightAnchor, marginTop: 5, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        collectionview.register(NewPostImageCell.self, forCellWithReuseIdentifier: imageCell)
        collectionview.register(NewPostPdfCell.self, forCellWithReuseIdentifier: pdfCell)
        collectionview.register(NewPostDocCell.self, forCellWithReuseIdentifier: docCell)
        view.addSubview(visualEffectView)
        visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        visualEffectView.alpha = 0
        
    }
    func convertHashtags(text:String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        attrString.beginEditing()
        // match all hashtags
        do {
            // Find all the hashtags in our string
            let regex = try NSRegularExpression(pattern: "(?:\\s|^)(@(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b", options: NSRegularExpression.Options.anchorsMatchLines)
            let results = regex.matches(in: text,
                                        options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, text.count))
            let array = results.map { (text as NSString).substring(with: $0.range) }
            for hashtag in array {
                // get range of the hashtag in the main string
                let range = (attrString.string as NSString).range(of: hashtag)
                // add a colour to the hashtag
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue , range: range)
            }
            attrString.endEditing()
        }
        catch {
            attrString.endEditing()
        }
        return attrString
    }
    
    func handleShowPopUp(target : String) {
        view.addSubview(popUpWindow)
        popUpWindow.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
        popUpWindow.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popUpWindow.heightAnchor.constraint(equalToConstant: view.frame.width - 200).isActive = true
        popUpWindow.widthAnchor.constraint(equalToConstant: view.frame.width - 44).isActive = true
        popUpWindow.target = target
        
        UIView.animate(withDuration: 0.5) {
            self.popUpWindow.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.visualEffectView.alpha = 1
            self.popUpWindow.alpha = 1
            self.popUpWindow.transform = CGAffineTransform.identity
            
        }
        return
    }
    
    private func getSizeOfData(data : [SelectedData]) -> String {
        var val : Float = 0
        for item in data {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useKB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            
            val += Float(item.data.count)
            
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        formatter.numberStyle = .decimal

        return formatter.string(from: val / (1024 * 1024) as NSNumber) ?? "n/a"
        
    }
    private func SizeOfData(data : [SelectedData]) -> Float {
       
        for item in data {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useKB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            
            totolDataInMB += Float(item.data.count)
            
        }
       return totolDataInMB / (1024 * 1024 )
        
    }
    @objc func setNewPost()
    {
        
        text.endEditing(true)
        
        if SizeOfData(data: data) > 14.95 {
            Utilities.errorProgress(msg: "Max 15 mb Yükleyebilirsiniz")
        }
        guard !text.text.isEmpty else {
            
            Utilities.errorProgress(msg: "Gönderiniz Boş Olamaz")
            return
        }
        Utilities.waitProgress(msg: "Paylaşılıyor")
        let date =  Int64(Date().timeIntervalSince1970 * 1000).description
        var val = [Data]()
        var dataType = [String]()
        let url = [String]()
        for number in 0..<(data.count) {
            val.append(data[number].data)
            dataType.append(data[number].type)
        }
           if self.data.isEmpty{
               PostService.shared.setNewLessonPost( link: self.link, currentUser: self.currentUser, postId: date, users: self.fallowers, msgText: self.text.text, datas: url, lessonName: self.selectedLesson, short_school: self.currentUser.short_school, major: self.currentUser.bolum) {[weak self] (_) in
                
                self?.setMyPostOnDatabase(postId: date) {[weak self] (_) in
                    Utilities.succesProgress(msg: "Paylaşıldı")
                 
                }
               }
            self.sendNotification(lessonName: self.selectedLesson, text: self.text.text, type: NotificationType.home_new_post.desprition, postId: date)
           }else {
            
            
            UploadDataToDatabase.uploadDataBase(postDate: date, currentUser: self.currentUser, lessonName: self.selectedLesson, type : dataType , data : val) { (url) in
                PostService.shared.setNewLessonPost( link: self.link, currentUser: self.currentUser, postId: date, users: self.fallowers, msgText: self.text.text, datas: url, lessonName: self.selectedLesson, short_school: self.currentUser.short_school, major: self.currentUser.bolum) {[weak self] (_) in
                    
                    guard let sself = self else { return }
                    
                    PostService.shared.setThumbDatas(currentUser: sself.currentUser, postId: date) {[weak self] (_) in
                        
                        self?.setMyPostOnDatabase(postId: date) { (_) in
                            Utilities.succesProgress(msg: "Paylaşıldı")
                        }
                    }
                    
                }  }
           }
        
    }

  
    
    private func sendNotification(lessonName : String ,text : String , type : String , postId : String){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        var getterUids = [NotificationGetter]()
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson").collection(currentUser.bolum).document(lessonName).collection("notification_getter")
        db.getDocuments {[weak self] (querySnap, err) in
            guard let sself = self else { return }
            guard let snap = querySnap else { return }
            if snap.isEmpty{
           
            }else{
                for item in snap.documents{
                    getterUids.append(NotificationGetter(uid: item.get("uid") as! String))
                }
                NotificaitonService.shared.new_home_post_notification(currentUser: sself.currentUser, postId: postId, getterUids: getterUids,  text: text, type: NotificationType.home_new_post.desprition, lessonName: lessonName, notificaitonId: notificaitonId) { (_) in
                    print("succes")
                }
            }
        }
    }
    
    
    
    //MARK: - getMentions
    private func getMention(completion : @escaping([String]) ->Void){
        guard let text = text.text else { return }
            let val = text.findMentionText()
            for i in val {
                userNames.append(i)
            }
           completion(userNames)
    }
    
    func setMyPostOnDatabase(postId : String , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("my-post")
            .document(postId)
        db.setData(["postId":postId] as [String:Any], merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
  
    @objc func _addPdf(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    @objc func _addDoc(){
        let importMenu = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    @objc func _addLink(){
        
        actionSheet.delegate = self
        actionSheet.show()
        
    }
    @objc func _addImage(){
        
        Config.Camera.recordLocation = false
        Config.tabsToShow = [.imageTab]
        gallery = GalleryController()
        gallery.delegate = self
        gallery.modalPresentationStyle = .fullScreen
        present(gallery, animated: true, completion: nil)
    }
    private func configure(){
        
        name = NSMutableAttributedString(string: (currentUser.name)!, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(currentUser.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        lessonName.text = selectedLesson
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        
    }
    
    //MARK: - imagePickerController
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        lightbox.modalPresentationStyle = .fullScreen
        
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true) {
            for image  in images {
                image.resolve { (img) in
                    
                    if let img_data = img!.jpegData(compressionQuality: 0.8){
                        if self.checkDataModelHasValue(data:  img_data){
                            print("data is exist")
                        }else{
                            self.data.append(SelectedData.init(data : img_data , type : DataTypes.image.description))
                            self.dataModel.append(DatasModel.init(postDate: self.postDate, currentUser: self.currentUser, lessonName: self.selectedLesson, type: DataTypes.image.description, data: img_data))
                            self.collectionview.reloadData()
                            self.navigationItem.title = "\( self.getSizeOfData(data: self.data)) mb"
                        }
                      
                    }
                }
            }
        }
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
}
extension StudentNewPost : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if dataModel[indexPath.row].type == DataTypes.image.description
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as! NewPostImageCell
            cell.backgroundColor = .white
            cell.delegate = self
            cell.data = dataModel[indexPath.row]
            cell.img.image = UIImage(data: data[indexPath.row].data)
            
            return cell
        }else if dataModel[indexPath.row].type == DataTypes.pdf.description {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdfCell, for: indexPath) as! NewPostPdfCell
            cell.delegate = self
            cell.backgroundColor = .white
            cell.pdfView.document = PDFDocument(data: data[indexPath.row].data)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: docCell, for: indexPath) as! NewPostDocCell
            cell.delegate = self
            return cell
        }
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (view.frame.width - 30 ) / 3
        return CGSize(width: width, height: width)
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,                                minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
//MARK: - UITextViewDelegate
extension StudentNewPost: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView)
    {
        textView.attributedText = convertHashtags(text: textView.text)
        let size = CGSize(width: view.frame.width, height: 150)
        let estimatedSize = textView.sizeThatFits(size)
        
        if textView.contentSize.height >= 150
        {
            textView.isScrollEnabled = true
        }
        else
        {
            textView.frame.size.height = textView.contentSize.height
            heigth = textView.contentSize.height
            textView.isScrollEnabled = false // textView.isScrollEnabled = false for swift 4.0
            
        }
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                
                if textView.contentSize.height >= 150
                {
                    textView.isScrollEnabled = true
                    constraint.constant = 150
                    textView.frame.size.height = 150
                    heigth = 150
                    
                }
                else
                {
                    textView.frame.size.height = textView.contentSize.height
                    textView.isScrollEnabled = true // textView.isScrollEnabled = false for swift 4.0
                    constraint.constant = estimatedSize.height
                    heigth = estimatedSize.height
                }
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.attributedText = convertHashtags(text: textView.text)
    }
    
    
    
}
extension StudentNewPost : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \( myURL.uti)")
        if myURL.uti == "com.microsoft.word.doc"
        {
            do {
                if self.checkDataModelHasValue(data: try Data(contentsOf: myURL)) {
                    Utilities.errorProgress(msg: "Bu Dosyayı Zaten Seçtiniz")
                }else{
                    self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                    self.dataModel.append(DatasModel.init(postDate: self.postDate, currentUser: self.currentUser, lessonName: self.selectedLesson, type: DataTypes.doc.description, data:  try Data(contentsOf: myURL)))
                    self.collectionview.reloadData()
                     self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
                }
            }
            catch{
                print(error)
            }
            
        }else if myURL.uti == "com.adobe.pdf"
        {
            do {
                
                if self.checkDataModelHasValue(data: try Data(contentsOf: myURL)) {
                    Utilities.errorProgress(msg: "Bu Dosyayı Zaten Seçtiniz")
                }else{
                    self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.pdf.description))
                    
                   
                    self.dataModel.append(DatasModel.init(postDate: self.postDate, currentUser: self.currentUser, lessonName: self.selectedLesson, type: DataTypes.pdf.description, data:  try Data(contentsOf: myURL)))
                    self.collectionview.reloadData()
                    self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
                }
                
                
            }
            catch{
                print(error)
            }
        }else if myURL.uti == "org.openxmlformats.wordprocessingml.document"
        {
            do {
                
                if self.checkDataModelHasValue(data: try Data(contentsOf: myURL)) {
                    Utilities.errorProgress(msg: "Bu Dosyayı Zaten Seçtiniz")
                }else{
                    self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                    self.dataModel.append(DatasModel.init(postDate: self.postDate, currentUser: self.currentUser, lessonName: self.selectedLesson, type: DataTypes.doc.description, data:  try Data(contentsOf: myURL)))
                    self.collectionview.reloadData()
                     self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
                }
               
            }
            catch{
                print(error)
            }
        }
        else {
            Utilities.errorProgress(msg: "Bilinmeyen Tür")
        }
        
        
        
        
    }
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController)
    {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
}
extension URL {
    
    var uti: String {
        return (try? self.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier ?? "public.data"
    }
    
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
extension StudentNewPost : ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .addLesson(_):
            break
        case .lessonInfo(_):
            break
        case .reportLesson(_):
            break
        case .showPicture(_):
            break
        case .removePicture(_):
            break
        case .takePicture(_):
            break
        case .choosePicture(_):
            break
        case .googleDrive(_):
            handleShowPopUp(target: DriveLinks.googleDrive.descrpiton)
            break
        case .dropBox(_):
            handleShowPopUp(target: DriveLinks.dropbox.descrpiton)
            break
        case .yandexDisk(_):
            handleShowPopUp(target: DriveLinks.yandex.descrpiton)
            break
        case .iClould(_):
            handleShowPopUp(target: DriveLinks.icloud.descrpiton)
            break
        case .oneDrive(_):
            handleShowPopUp(target: DriveLinks.onedrive.descrpiton)
            break
        case .mega(_):
            handleShowPopUp(target: DriveLinks.mega.descrpiton)
            break
        }
    }
}
extension StudentNewPost: PopUpDelegate {
    func addTarget(_ target: String?)
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.popUpWindow.alpha = 0
            self.popUpWindow.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) {[weak self] (_) in
            self?.popUpWindow.removeFromSuperview()
            
            if let url = self?.popUpWindow.link.text {
                
               
                self?.detectLink(url)
                self?.popUpWindow.link.text = ""
                self?.link = url
                
            }
            
        }
    }
    
    func goDrive(_ target: String?) {
        guard let target = target else { return }
        goToLink(target)
    }
    
    
    func handleDismissal() {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.popUpWindow.alpha = 0
            self.popUpWindow.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (_) in
            self.popUpWindow.removeFromSuperview()
            print("Did remove pop up window..")
        }
    }
    
    
}
extension String {
    func findMentionText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(?:\\s|^)(@(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b", options: [])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
}
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
extension StudentNewPost : DeleteDoc  {
    func deleteDoc(for cell: NewPostDocCell) {
        guard let indexPath = self.collectionview.indexPath(for: cell) else { return }
        data.remove(at: indexPath.row)
        self.collectionview.reloadData()
        self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
    }
}
extension StudentNewPost : DeleteImage  {
    func deleteImage(for cell: NewPostImageCell) {
        guard let indexPath = self.collectionview.indexPath(for: cell) else { return }
        data.remove(at: indexPath.row)
        self.collectionview.reloadData()
        self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
    }
    
   
}
extension StudentNewPost : DeletePdf {
    func deletePdf(for cell: NewPostPdfCell) {
        guard let indexPath = self.collectionview.indexPath(for: cell) else { return }
        data.remove(at: indexPath.row)
        self.collectionview.reloadData()
        self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
    }
    
    
}
