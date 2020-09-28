//
//  StudentEditPost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
private let image_cell = "img"
private let pdf_cell = "pdf"
private let doc_cell = "doc"
import FirebaseStorage
import FirebaseFirestore
import MobileCoreServices
import SVProgressHUD
class StudentEditPost: UIViewController {
    // MARK:-properties
    var collectionview: UICollectionView!
    var totolDataInMB : Float = 0.0
    var currentUser : CurrentUser
    var post : LessonPostModel
    private var actionSheet : ActionSheetLauncher
    var h : CGFloat
    var link : String?
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var uploadTask : StorageUploadTask?
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
    let cloudLink : UIButton = {
        let btn = UIButton(type: .system)
        
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        btn.setTitleColor(.systemBlue, for: .normal)
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
    let cloudImage : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    let removeLink : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
       
        return btn
    }()
    
    //    MARK:-lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.title = "Gönderiyi Düzenle"
        
        configureCollectionView()
        hideKeyboardWhenTappedAround()
        rigtBarButton()
        detectLink(post.link)
        removeLink.addTarget(self, action: #selector(removeLinkClick), for: .touchUpInside)

    }
    init(currentUser : CurrentUser , post : LessonPostModel , heigth : CGFloat) {
        self.currentUser = currentUser
        self.post = post
        self.h = heigth
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser, target: Target.drive.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK:- selector
    
    @objc func _addLink(){
        actionSheet.delegate = self
        actionSheet.show()
    }
    
    @objc func removeLinkClick(){
        //İSTE/lesson-post/post/1600774976770
        if post.link != ""{
            let db = Firestore.firestore().collection(currentUser.short_school)
                .document("lesson-post").collection("post").document(post.postId)
            db.updateData(["link":""] as [String:Any]) {[weak self] (err) in
                if err == nil {
                    Utilities.succesProgress(msg: "Bağlantıyı Kaldırdınız")
                    self?.cloudDriveLink.isHidden = true
                    self?.removeLink.isHidden = true
                }
            }
        }
       
    }
    @objc func setNewPost(){
        text.endEditing(true)
        guard !text.text.isEmpty else {
            
            Utilities.errorProgress(msg: "Gönderiniz Boş Olamaz")
            return
        }
        
        if text.text == post.text {
            Utilities.errorProgress(msg: "Hiç Değişklik Yapmadınız")
            return
        }
        
        var val = [Data]()
        var dataType = [String]()
//        let url = [String]()
        for number in 0..<(data.count) {
            val.append(data[number].data)
            dataType.append(data[number].type)
        }
       
        if data.isEmpty {
            PostService.shared.updatePost(currentUser: currentUser, postId: post.postId, msgText: text.text) { (_) in
                Utilities.succesProgress(msg: "Gönderiniz Güncellendi")
            }
        }
    }
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    @objc func _addImage(){
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
                 
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
    
    //    MARK:- functions
    private func goToLink(_ target : String)
    {  if let url = URL(string: target){
        UIApplication.shared.open(url) }
        
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
            removeLink.isHidden = false

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
            removeLink.isHidden = true
            Utilities.errorProgress(msg: "Bu Bağlantıyı Tanımayamadık")
        }
        
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
    
    fileprivate func configureCollectionView() {
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 80)
        
        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: h)
        //        text.delegate = self
        text.isScrollEnabled = true
        //        textViewDidChange(text)
        text.pleaceHolder.text = ""
        let stack = UIStackView(arrangedSubviews: [addImage,addDoc,addPdf,addLink])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 20) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        view.addSubview(cloudDriveLink)
        cloudDriveLink.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, bottom: nil, rigth: nil, marginTop: 5, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        cloudDriveLink.isHidden = true
        
        view.addSubview(removeLink)
        removeLink.anchor(top: stack.bottomAnchor, left: nil, bottom: nil, rigth: stack.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 20, width: 0, heigth: 25)

        removeLink.isHidden = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        view.addSubview(collectionview)
        
        collectionview.anchor(top: cloudDriveLink.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth:view.rightAnchor, marginTop: 5, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        collectionview.register(StudentEditPostDocCell.self, forCellWithReuseIdentifier: doc_cell)
        collectionview.register(StudentEditPostPdfCell.self, forCellWithReuseIdentifier: pdf_cell)
        collectionview.register(StudentEditPostImageCell.self, forCellWithReuseIdentifier: image_cell)
        view.addSubview(visualEffectView)
        visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        visualEffectView.alpha = 0
        
        loadVariables()
    }
    fileprivate func loadVariables(){
        
        name = NSMutableAttributedString(string: (currentUser.name)!, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(currentUser.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        lessonName.text = post.lessonName
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        text.text = post.text
        
        
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
    
    private func deleteData(url : String,postId : String, currentUser : CurrentUser) {
        Utilities.waitProgress(msg: "Siliniyor")
        let storage = Storage.storage()
        let r = storage.reference(forURL: url)
        r.delete { (err) in
            if err == nil {
                //db.updateData(["silent":FieldValue.arrayRemove([currentUser.uid as Any])])
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson-post").collection("post")
                    .document(postId)
                db.updateData(["data":FieldValue.arrayRemove([url as Any])]) { (err) in
                    if err == nil {
                        if let index = self.post.data.firstIndex(of: url) {
                            Utilities.succesProgress(msg: "Dosya Silindi")
                            self.post.data.remove(at: index)
                            self.collectionview.reloadData()
                            
                        }
                    }
                }
            }
        }
    }
    
    private func updateData(url : String , postId : String  , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").document(postId)
        db.updateData(["data":FieldValue.arrayUnion([url as Any])]) { (err) in
            if err == nil {
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson-post").collection("post").document(postId)
                db.updateData(["thumbData":FieldValue.arrayUnion([url as Any])]) { (err) in
                    if err == nil {
                        completion(true)

                    }
                }

            }
        }
        
    }
}
extension StudentEditPost : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.data.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print(URL(string: (post.data[indexPath.row]))!.mimeType() )
        if URL(string: (post.data[indexPath.row]))!.mimeType() == "image/jpeg"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: image_cell, for: indexPath) as! StudentEditPostImageCell
            cell.delegate = self
            cell.url = post.data[indexPath.row]
            return cell
            
        }else if URL(string: (post.data[indexPath.row]))!.mimeType() == DataTypes.pdf.contentType{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdf_cell, for: indexPath) as! StudentEditPostPdfCell
            cell.delegate = self
            cell.url = post.data[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: doc_cell, for: indexPath) as! StudentEditPostDocCell
            cell.delegate = self
            cell.url = post.data[indexPath.row]
            return cell
        }
    }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width  = (view.frame.width - 30 ) / 3
           return CGSize(width: width, height: width)
       }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
    
    
}
//MARK: - UITextViewDelegate
extension StudentEditPost: UITextViewDelegate {
    
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
extension StudentEditPost : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \( myURL.uti)")
        if myURL.uti == "com.microsoft.word.doc"
        {
            do {
//                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
//                self.collectionview.reloadData()
//                 self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
                UploadDataToDatabase.uploadDataBase(postDate: post.postId, currentUser: currentUser, lessonName: post.lessonName, type: ["doc"], data: [try Data(contentsOf: myURL) ]) {[weak self] (val) in
                    print(val[0])
                    self?.updateData(url: val[0], postId: self!.post.postId, currentUser: self!.currentUser) { (_) in
                        self?.post.data.append(val[0])
                        self?.collectionview.reloadData()
                        Utilities.succesProgress(msg: "Dosya Eklendi")
                    }
                    
                }
            }
            catch{
                print(error)
            }
            
        }else if myURL.uti == "com.adobe.pdf"
        {
            do {
//                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.pdf.description))
//
//                self.collectionview.reloadData()
//                self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
                UploadDataToDatabase.uploadDataBase(postDate: post.postId, currentUser: currentUser, lessonName: post.lessonName, type: ["pdf"], data: [try Data(contentsOf: myURL) ]) {[weak self] (val) in
                    print(val[0])
                    self?.updateData(url: val[0], postId: self!.post.postId, currentUser: self!.currentUser) { (_) in
                        self?.post.data.append(val[0])
                        self?.collectionview.reloadData()
                        Utilities.succesProgress(msg: "Dosya Eklendi")
                    }
                    
                    
                    
                }
            }
            catch{
                print(error)
            }
        }else if myURL.uti == "org.openxmlformats.wordprocessingml.document"
        {
            do {
                UploadDataToDatabase.uploadDataBase(postDate: post.postId, currentUser: currentUser, lessonName: post.lessonName, type: ["doc"], data: [try Data(contentsOf: myURL) ]) {[weak self] (val) in
                    print(val[0])
                    self?.updateData(url: val[0], postId: self!.post.postId, currentUser: self!.currentUser) { (_) in
                        self?.post.data.append(val[0])
                        self?.collectionview.reloadData()
                        Utilities.succesProgress(msg: "Dosya Eklendi")
                    }
                    
                    
                    
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
extension StudentEditPost : EditStudentPostDelegate {
    func deleteImage(for cell: StudentEditPostImageCell) {
       guard let url = cell.url else { return }
        self.deleteData(url: url, postId: post.postId, currentUser: currentUser)
    }
    
    func deleteDoc(for cell: StudentEditPostDocCell) {
        guard let url = cell.url else { return }
        self.deleteData(url: url, postId: post.postId, currentUser: currentUser)
    }
    
    func deletePdf(for cell: StudentEditPostPdfCell) {
        guard let url = cell.url else { return }
        self.deleteData(url: url, postId: post.postId, currentUser: currentUser)
    }
    
    
}
extension StudentEditPost : UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    //İSTE/Bilgisayar Mühendisliği/Bilişim Hukuku/@mhsnabz/1600038956210
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let date = Int64(Date().timeIntervalSince1970 * 1000).description
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return}
        let metaDataForImage = StorageMetadata()
        metaDataForImage.contentType = "image/jpeg"
        guard let uploadData = selectedImage.jpegData(compressionQuality: 1) else { return }
        let filename = date + ".jpg"
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(post.lessonName).child(currentUser.username)
            .child(post.postId).child(filename)
        SVProgressHUD.setBackgroundColor(.black)
        SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setBorderColor(.white)
        SVProgressHUD.setForegroundColor(.white)
        
      uploadTask =  storageRef.putData(uploadData, metadata: metaDataForImage, completion: { (metadata, err) in
            if err != nil {
                SVProgressHUD.showError(withStatus: "Hata Oluştu")
                print("failed upload image")
                return
            }
            Utilities.waitProgress(msg: "Resim Yükleniyor")
            storageRef.downloadURL {[weak self] (url, err) in
                if err == nil {
                    guard let url = url?.absoluteString else {
                        print("DEBUG : profile Image url is null")
                        return
                    }
                    guard let sself = self else { return }
                    ///İSTE/lesson-post/post/1599978424725
                    let db = Firestore.firestore().collection(sself.currentUser.short_school).document("lesson-post")
                        .collection("post").document(sself.post.postId)
                    //db.updateData(["data":FieldValue.arrayRemove([url as Any])])
                    db.updateData(["data":FieldValue.arrayUnion([url as Any])]) { (err) in
                        if err == nil
                        {
                            
                            sself.post.data.append(url)
                            sself.collectionview.reloadData()
                            Utilities.dismissProgress()
                            Utilities.succesProgress(msg: "Resim Yüklendi")
                            sself.dismiss(animated: true, completion: nil)
                        }else{
                            SVProgressHUD.showError(withStatus: "Hata Oluştu")
                        }
                        
                        
                    }
                   
                   
                }
               
            }
            
        })
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
   
        if uploadTask != nil {
                    _ = uploadTask!.observe(.progress) { snapshot in
                        
                        Utilities.waitProgress(msg: "Resim Yükleniyor")

                    }
                }
               
            }
    }
   

extension StudentEditPost : ActionSheetLauncherDelegate  {
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
extension StudentEditPost: PopUpDelegate {
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
                guard let sself = self else { return }
                let db = Firestore.firestore().collection(sself.currentUser.short_school)
                    .document("lesson-post").collection("post").document(sself.post.postId)
                db.updateData(["link":url] as [String:Any]) {[weak self] (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Yeni Bir Bağlantı Eklediniz")
                        self?.cloudDriveLink.isHidden = false
                        self?.removeLink.isHidden = false
                        self?.post.link = url
                    }
                }
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
