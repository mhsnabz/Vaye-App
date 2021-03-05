//
//  EditNoticesPost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseStorage
private let imageCell = "cell"
import SDWebImage
import FirebaseFirestore
class EditNoticesPost: UIViewController {
    //MARK:-variable
    var currentUser : CurrentUser
    var post : NoticesMainModel
    var collectionview: UICollectionView!
    lazy var heigth : CGFloat = 0.0
    var h : CGFloat
    
    
    //MARK:-properties
    let profileImage : UIImageView = {
        let imagee = UIImageView()
        imagee.clipsToBounds = true
        imagee.contentMode = .scaleAspectFit
        imagee.layer.borderColor = UIColor.lightGray.cgColor
        imagee.layer.borderWidth = 0.5
        
        return imagee
        
    }()
    lazy var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
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
        profileImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 40, heigth: 40)
        profileImage.layer.cornerRadius = 20
        view.addSubview(userName)
        userName.anchor(top: profileImage.topAnchor, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        
        view.addSubview(lessonName)
        lessonName.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: userName.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 18)
        
        return view
    }()
    let addImage : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "gallery")!.withRenderingMode(.alwaysOriginal), for: .normal)
                   btn.addTarget(self, action: #selector(_addImage), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()
        navigationItem.title = "Gönderiyi Düzenle"
        configureHeader()
        hideKeyboardWhenTappedAround()
        configureCollectionView()
        rigtBarButton()
        
    }
    
    //MARK:-lifeCycle
    init(currentUser : CurrentUser , post : NoticesMainModel , h : CGFloat) {
        self.h = h
        self.currentUser = currentUser
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    MARK:-functions
    
    private func configureHeader(){
        name = NSMutableAttributedString(string: (currentUser.name)!, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(currentUser.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        text.text = post.text
        text.pleaceHolder.text = ""
        lessonName.text = post.clupName
        
    }
    
    private func configureCollectionView(){
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 64)
        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: h)
        text.delegate = self
        text.isScrollEnabled = true
        textViewDidChange(text)
        let stack = UIStackView(arrangedSubviews: [addImage])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 40) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        view.addSubview(collectionview)
        
        collectionview.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth:view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        collectionview.register(EditFoodMeCell.self, forCellWithReuseIdentifier: imageCell)
    }
    func rigtBarButton()  {
        
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
    
//    MARK:-selector
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func setNewPost(){
        text.endEditing(true)
        guard !text.text.isEmpty else {
            
            Utilities.errorProgress(msg: "Gönderiniz Boş Olamaz")
            return
        }
        NoticesService.shared.updatePost(post: post, text: text.text, currentUser: currentUser) { [weak self] (val) in
            guard let sself = self else {
                Utilities.errorProgress(msg: "Hata Oluştu")
                return
            }
            if val{
                Utilities.succesProgress(msg: "Gönderiniz Güncellendi")
                sself.navigationController?.popViewController(animated: true)
            }else{
                Utilities.errorProgress(msg: "Hata Oluştu")
            }
        }
    }
    @objc func _addImage(){
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
//MARK:-UITextViewDelegate
extension EditNoticesPost : UITextViewDelegate {
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
//MARK:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
extension EditNoticesPost :  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EditFoodMeCell
        cell.delegate = self
        cell.url = post.data[indexPath.row]
        return cell
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
extension EditNoticesPost : EditFoodMePostDelegate {
    func deleteImage(for cell: EditFoodMeCell) {
        guard let url = cell.url else { return }
         guard let index = collectionview.indexPath(for: cell) else {
             return
         }
        NoticesService.shared.deleteData(index: index, post: post, currentUser: currentUser, collectionview: collectionview, url: url)
    }
    
    
}
//MARK:-: UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension EditNoticesPost : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Utilities.waitProgress(msg: "Resim Ekleniyor")
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return}
        let metaDataForImage = StorageMetadata()
        metaDataForImage.contentType = "image/jpeg"
        guard let uploadData = selectedImage.jpegData(compressionQuality: 0.8) else { return }
        var dataType : [String] = []
        var data : [Data] = []
        data.append(uploadData)
        dataType.append(DataTypes.image.description )
        NoticesService.shared.uploadToDataBase(postDate: post.postId, clupName: post.clupName, currentUser: currentUser, postType: PostType.notice.despription, type: dataType, data: data) {[weak self] (url) in

            guard let sself = self else { return }
            sself.post.data.append(contentsOf: url)
            sself.collectionview.reloadData()
            sself.dismiss(animated: true) {
                
                let db = Firestore.firestore().collection(sself.currentUser.short_school)
                        .document("notices")
                        .collection("post")
                    .document(sself.post.postId)
                for item in url{
                    db.updateData(["data": FieldValue.arrayUnion([item])])
                }
             
            }
            NoticesService.shared.setThumbDatas(currentUser: sself.currentUser, postId: sself.post.postId) { (_) in
                
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    
    }
}
