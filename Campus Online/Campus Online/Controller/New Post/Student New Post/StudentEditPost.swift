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
class StudentEditPost: UIViewController {
    // MARK:-properties
    var collectionview: UICollectionView!
    var totolDataInMB : Float = 0.0
    var currentUser : CurrentUser
    var post : LessonPostModel
    var h : CGFloat
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    
    lazy var popUpWindow: PopUpWindow = {
        let view = PopUpWindow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        //        view.delegate = self
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
        //           btn.addTarget(self, action: #selector(_addDoc), for: .touchUpInside)
        return btn
    }()
    let addPdf : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "pdf")!.withRenderingMode(.alwaysOriginal), for: .normal)
        //           btn.addTarget(self, action: #selector(_addPdf), for: .touchUpInside)
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
        //           btn.addTarget(self, action: #selector(_addLink), for: .touchUpInside)
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
    //    MARK:-lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.title = "Gönderiyi Düzenle"
        
        configureCollectionView()
    }
    init(currentUser : CurrentUser , post : LessonPostModel , heigth : CGFloat) {
        self.currentUser = currentUser
        self.post = post
        self.h = heigth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK:- selector
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    @objc func _addImage(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
                 
    }
    
    //    MARK:- functions
    
    
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
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                self.collectionview.reloadData()
                 self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
            }
            catch{
                print(error)
            }
            
        }else if myURL.uti == "com.adobe.pdf"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.pdf.description))
                self.collectionview.reloadData()
                self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
            }
            catch{
                print(error)
            }
        }else if myURL.uti == "org.openxmlformats.wordprocessingml.document"
        {
            do {
                self.data.append(SelectedData.init(data: try Data(contentsOf: myURL) , type: DataTypes.doc.description))
                
                self.collectionview.reloadData()
                 self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
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
        print("pdf deleted")
    }
    
    
}
extension StudentEditPost : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
}
