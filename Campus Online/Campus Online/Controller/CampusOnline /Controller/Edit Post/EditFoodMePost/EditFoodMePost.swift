//
//  EditFoodMePost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import SDWebImage
import FirebaseFirestore
import CoreLocation
import ImagePicker
import Lightbox
import Gallery
import FirebaseStorage
private let imageCell = "cell"

class EditFoodMePost: UIViewController
{
    
    //MARK:-variable
    var currentUser : CurrentUser
    var post : MainPostModel
    var collectionview: UICollectionView!
    lazy var heigth : CGFloat = 0.0
    var h : CGFloat
    var locationManager : CLLocationManager!
    var locationName : String?
    var geoPoing : GeoPoint?{
        didSet{
            guard let loacaiton = geoPoing else { return }
            Utilities.succesProgress(msg: "Konum Eklendi")
            print("lat : \(loacaiton.latitude)")
            print("lat : \(loacaiton.longitude)")
        }
    }
    //MARK:-properties
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
    lazy var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    
    lazy var headerView : UIView = {
        let view = UIView()
        view.addSubview(profileImage)
        profileImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 40, heigth: 40)
        profileImage.layer.cornerRadius = 20
        view.addSubview(userName)
        userName.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        userName.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        return view
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
    let addImage : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "gallery")!.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addImage), for: .touchUpInside)
        return btn
    }()
    
    let addLocations : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addLocation), for: .touchUpInside)
        return btn
    }()
    let pin : UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "pin").withRenderingMode(.alwaysOriginal)
        return img
    }()
    let value_image : UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "timer").withRenderingMode(.alwaysOriginal)
        return img
    }()
    let value_description : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        return lbl
    }()
    let pinDespriction : UILabel = {
        let lbl = UILabel()
        lbl.text = "Konum Eklendi"
        lbl.font = UIFont(name: Utilities.font, size: 14)
        return lbl
    }()
    lazy var remove_Value : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(removeValue), for: .touchUpInside)
        return btn
    }()
    lazy var removeLaciton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(removeLocation), for: .touchUpInside)
        return btn
    }()
    
    lazy var pinView : UIView = {
        let view = UIView()
        let stackPin = UIStackView(arrangedSubviews: [pin,pinDespriction])
        stackPin.axis = .horizontal
        view.addSubview(stackPin)
        stackPin.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        
        view.addSubview(removeLaciton)
        removeLaciton.anchor(top: nil, left: nil, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 5, width: 25, heigth: 25)
        removeLaciton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
   
    
    //MARK:-lifeCycle
    init(currentUser : CurrentUser , post : MainPostModel , h : CGFloat) {
        self.h = h
        self.currentUser = currentUser
        self.post = post
        Utilities.dismissProgress()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()
        navigationItem.title = "Gönderiyi Düzenle"
//        configureHeader()
        hideKeyboardWhenTappedAround()
        configureCollectionView()
        rigtBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureHeader()

        Utilities.waitProgress(msg: nil)
        navigationItem.title = "Gönderiyi Düzenle"
        
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("coordinate").document("locaiton")
        db.getDocument {[weak self] (docSnap, err) in
            guard let sself = self else {
                Utilities.dismissProgress()
                self?.pinView.isHidden = true
                return
            }
            if err == nil {
                guard let snap = docSnap else {
                    Utilities.dismissProgress()
                    return
                }
                if snap.exists{
                    sself.pinView.isHidden = false
                    sself.geoPoing = snap.get("geoPoint") as? GeoPoint
                    sself.locationName = snap.get("locationName")  as? String
                    Utilities.succesProgress(msg: "Konum Eklendi")
                }
            }
        }
    }
    
    //MARK:-functions
    
    
    
    private func configureCollectionView(){
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 64)
        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: h)
        text.delegate = self
        text.isScrollEnabled = true
        textViewDidChange(text)
        let stack = UIStackView(arrangedSubviews: [addImage,addLocations])
        stack.axis = .horizontal
        stack.spacing = (view.frame.width - 40) / (100)
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        
        stack.anchor(top: text.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        view.addSubview(pinView)
        pinView.anchor(top: stack.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 8 , marginLeft: 30, marginBottom: 0, marginRigth: 30, width: 0, heigth: 25)
        pinView.isHidden = true
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        view.addSubview(collectionview)
        
        collectionview.anchor(top: pinView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth:view.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        collectionview.register(EditFoodMeCell.self, forCellWithReuseIdentifier: imageCell)
    }
    
    private func configureHeader(){
        name = NSMutableAttributedString(string: (currentUser.name)!, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(currentUser.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        text.text = post.text
        text.pleaceHolder.text = ""
        geoPoing = post.geoPoint
        locationName = post.locationName
        
        if  post.geoPoint != nil {
            pinView.isHidden = false
        }else{
            pin.isHidden = true
        }
        
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
    //MARK:-selectors
    
    @objc func setNewPost(){
        text.endEditing(true)
        guard !text.text.isEmpty else {
            
            Utilities.errorProgress(msg: "Gönderiniz Boş Olamaz")
            return
        }
        MainPostService.shared.updatePost(post: post, text: text.text, locaitonName: locationName, geoPoint: geoPoing) {[weak self] (val) in
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
    
    @objc func removeValue(){
        
    }
    @objc func removeLocation(){
        Utilities.waitProgress(msg: "Konum Siliniyor")
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("coordinate").document("locaiton")
        db.delete {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
   
                sself.geoPoing = nil
                sself.locationName = nil
                sself.pinView.isHidden = true
                
                
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(sself.post.postId)
                let dc = ["geoPoint":"","locationName":"" ] as [String : Any]
                db.setData(dc, merge: true) { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Konum Silindi")
                    }
                }
          
            }
        }
 
    }
    @objc func _addLocation(){
        let vc = MapVC(currentUser: currentUser)
        vc.locationManager = locationManager
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func _addImage(){
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: UITextViewDelegate
extension EditFoodMePost : UITextViewDelegate {
    
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
//MARK:-:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension EditFoodMePost :  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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

//MARK:- EditFoodMePostDelegate
extension EditFoodMePost : EditFoodMePostDelegate {
    func deleteImage(for cell: EditFoodMeCell) {
        guard let url = cell.url else { return }
         guard let index = collectionview.indexPath(for: cell) else {
             return
         }
        MainPostService.shared.deleteData(index: index, post: post, currentUser: currentUser, collectionview: collectionview, url: url)
    }
    
    
}
//MARK:-: UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension EditFoodMePost  : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        MainPostUploadService.shareed.uploadDataBase(postDate: post.postId, currentUser: currentUser, postType: PostType.foodMe.despription, type: dataType, data: data) {[weak self] (url) in

            guard let sself = self else { return }
            sself.post.data.append(contentsOf: url)
            sself.collectionview.reloadData()
            sself.dismiss(animated: true) {
                
                       let db = Firestore.firestore().collection("main-post")
                        .document("post").collection("post").document(sself.post.postId)
                for item in url{
                    db.updateData(["data": FieldValue.arrayUnion([item])])
                }
             
            }
            MainPostUploadService.shareed.setThumbDatas(currentUser: sself.currentUser, postType: PostType.foodMe.despription, postId: sself.post.postId) { (_val) in
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    
    }
}
