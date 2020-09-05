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

class StudentNewPost: UIViewController, LightboxControllerDismissalDelegate ,GalleryControllerDelegate {
    var viewController : UIViewController!
    private var actionSheet : ActionSheetLauncher
    private var addUserSheet : AddUserLaunher
    var users : [String]?{
        didSet{
            guard let user = users else { return }
            for i in user {
                text.text += i
            }
        }
    }
    var gallery: GalleryController!
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var success = true
    
    var selectedLesson : String? {
        didSet {
            navigationItem.title = "Yeni Gönderi"
        }
    }
    let lbl = UILabel(frame: .zero)
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
    
    let addUser : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "add-user")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addUser), for: .touchUpInside)
        return btn
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
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser, target: Target.drive.description)
        self.addUserSheet = AddUserLaunher(currentUser: currentUser)
        super.init(nibName: nil, bundle: nil)
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        text.becomeFirstResponder()
    }
    
    
    
    
    //MARK: - func
    private func detectLink(_ link : String){
        let url = NSURL(string: link)
        let domain = url?.host
        guard let link = domain else { return }
        print(link)
        if link == "drive.google.com" || link == "www.drive.google.com" {
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "google-drive")
            self.cloudLink.setTitle("Google Drive Bağlantısı", for: .normal)
        }else if link == "dropbox.com" || link == "www.dropbox.com"{
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "dropbox")
            self.cloudLink.setTitle("Dropbox Bağlantısı", for: .normal)
        }else if link == "icloud.com" || link == "www.icloud.com"{
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "icloud")
            self.cloudLink.setTitle("iCloud Bağlantısı", for: .normal)
        }else if link == "disk.yandex.com.tr" || link == "disk.yandex.com" || link == "yadi.sk"{
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "yandex-disk")
            self.cloudLink.setTitle("Yandex Disk Bağlantısı", for: .normal)
        }else if link == "onedrive.live.com" || link == "www.onedrive.live.com" || link == "1drv.ms"{
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "onedrive")
            self.cloudLink.setTitle("OneDrive Bağlantısı", for: .normal)
        }else if link == "mega.nz" || link == "www.mega.nz"{
            self.cloudDriveLink.isHidden = false
            self.cloudImage.image = UIImage(named: "mega")
            self.cloudLink.setTitle("Mega.nz Bağlantısı", for: .normal)
        }else{
            self.cloudDriveLink.isHidden = true
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
        
        let stack = UIStackView(arrangedSubviews: [addUser,addImage,addDoc,addPdf,addLink])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 20) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        view.addSubview(cloudDriveLink)
        cloudDriveLink.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, bottom: nil, rigth: nil, marginTop: 5, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 25)
        cloudDriveLink.isHidden = true
        //
        //        view.addSubview(sizeOfData)
        //        sizeOfData.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: nil
        //            , rigth: nil, marginTop: 2, marginLeft: 2, marginBottom: 0, marginRigth: 0, width: 0, heigth: 16)
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
        var val : Int64 = 0
        for item in data {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            
            val += Int64(item.data.count)
            
        }
        
        return "\(val) mb"
        
    }
    
    @objc func setNewPost()
    {
        let date = Date().timeIntervalSince1970.description
        var val = [Data]()
        var dataType = [String]()
        for number in 0..<(data.count) {
            
            val.append(data[number].data)
            
            dataType.append(data[number].type)
        }
        UploadDataToDatabase.uploadDataBase(postDate: date, currentUser: currentUser, lessonName: self.selectedLesson!, type : dataType , data : val)
    }
    @objc func _addUser()
    {
        let vc = AddUserTB(currentUser: currentUser)
        viewController = UINavigationController(rootViewController: vc)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: false, completion: nil)
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
                        self.data.append(SelectedData.init(data : img_data , type : DataTypes.image.description))
                        self.collectionview.reloadData()
                        
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
        if data[indexPath.row].type == "jpeg"
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as! NewPostImageCell
            cell.backgroundColor = .white
            cell.img.image = UIImage(data: data[indexPath.row].data)
            return cell
        }else if data[indexPath.row].type == "pdf" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdfCell, for: indexPath) as! NewPostPdfCell
            cell.backgroundColor = .white
            cell.pdfView.document = PDFDocument(data: data[indexPath.row].data)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: docCell, for: indexPath) as! NewPostDocCell
            
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
    
    func textViewDidChange(_ textView: UITextView) {
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
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                self.collectionview.reloadData()
            }
            catch{
                print(error)
            }
            
        }else if myURL.uti == "com.adobe.pdf"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.pdf.description))
                self.collectionview.reloadData()
            }
            catch{
                print(error)
            }
        }else if myURL.uti == "org.openxmlformats.wordprocessingml.document"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                self.collectionview.reloadData()
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
            
        case .removeLesson(_):
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
        case .dropBox(_):
            handleShowPopUp(target: DriveLinks.dropbox.descrpiton)
        case .yandexDisk(_):
            handleShowPopUp(target: DriveLinks.yandex.descrpiton)
        case .iClould(_):
            handleShowPopUp(target: DriveLinks.icloud.descrpiton)
        case .oneDrive(_):
            handleShowPopUp(target: DriveLinks.onedrive.descrpiton)
        case .mega(_):
            handleShowPopUp(target: DriveLinks.mega.descrpiton)
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


