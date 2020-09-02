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
    
    
    
    var gallery: GalleryController!
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var selectedLesson : String? {
        didSet {
            navigationItem.title = selectedLesson
        }
    }
    
    var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
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
//    lazy var text : UITextView = {
//        let text = UITextView()
//        text.backgroundColor = .white
//        text.font = UIFont(name: Utilities.font, size: 14)
//        text.isEditable = true
//        text.dataDetectorTypes = [.all]
//        text.isScrollEnabled = false
//        text.isUserInteractionEnabled = true
//        text.isScrollEnabled = true
//        text.isSelectable = true
//        return text
//    }()
    let text : ActiveLabel = {
        let lbl = ActiveLabel()
        return lbl
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
    
    //MARK:- lifeCycle
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(setNewPost))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        text.becomeFirstResponder()
    }
    
    
    
    
    //MARK: - func
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    fileprivate func configureCollectionView() {
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 80)
        
        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 100)
//        text.delegate = self
//        text.isScrollEnabled = true
//        textViewDidChange(text)
        
        let stack = UIStackView(arrangedSubviews: [addUser,addImage,addDoc,addPdf])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 20) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
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
        
        collectionview.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth:view.rightAnchor, marginTop: 20, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        collectionview.register(NewPostImageCell.self, forCellWithReuseIdentifier: imageCell)
        collectionview.register(NewPostPdfCell.self, forCellWithReuseIdentifier: pdfCell)
        collectionview.register(NewPostDocCell.self, forCellWithReuseIdentifier: docCell)
        
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
    @objc func _addUser(){
        
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
                        self.data.append(SelectedData.init(data : img_data , type : "jpeg"))
                        self.collectionview.reloadData()
                        
                    }
                    
                }
            }
//            self.sizeOfData.text = self.getSizeOfData(data: self.data)
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
                //                  constraint.constant = estimatedSize.height
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
                    self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: "doc"))
                    self.collectionview.reloadData()
                }
                catch{
                    print(error)
                }
            
        }else if myURL.uti == "com.adobe.pdf"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: "pdf"))
                self.collectionview.reloadData()
            }
            catch{
                print(error)
            }
        }else if myURL.uti == "org.openxmlformats.wordprocessingml.document"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: "doc"))
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
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
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
