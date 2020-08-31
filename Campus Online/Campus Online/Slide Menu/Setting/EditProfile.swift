//
//  EditProfile.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SVProgressHUD
import TweeTextField
class EditProfile: UIViewController {
    var currentUser : CurrentUser
    var barTitle : String?
    
    
    //MARK: -init
    let imageView : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .darkGray
        img.isUserInteractionEnabled = true
        return img
    }()
    let addImage : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "add")
        img.isUserInteractionEnabled = true
        return img
    }()
    let userName : TweeAttributedTextField = {
        let txt = TweeAttributedTextField()
        txt.placeholder = "@kullanıcı adınınzı belirleyin"
        txt.font = UIFont(name: Utilities.font, size: 14)!
        txt.activeLineColor =   UIColor.mainColor()
        txt.lineColor = .darkGray
        txt.textAlignment = .center
        txt.activeLineWidth = 1.5
        
        txt.animationDuration = 0.7
        
        txt.infoFontSize = UIFont.smallSystemFontSize
        txt.infoTextColor = .red
        txt.infoAnimationDuration = 0.4
        txt.textContentType = .givenName
        txt.autocorrectionType = .no
        txt.autocapitalizationType = .none
        txt.returnKeyType = .continue
        
        
        return txt
    }()
    let reg : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kaydet", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 16)
        btn.addTarget(self, action: #selector(updateUsername), for: .touchUpInside)
        return btn
    }()
//  MARK: - lifeCycle
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.title = barTitle ?? ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismis))
        // Do any additional setup after loading the view.
        view.addSubview(imageView)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 125, heigth: 125)
        imageView.layer.cornerRadius = 125 / 2
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive =  true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        imageView.addGestureRecognizer(tap)
        view.addSubview(addImage)
        addImage.anchor(top: nil, left: nil, bottom: imageView.bottomAnchor, rigth: imageView.rightAnchor, marginTop: -25, marginLeft: -25, marginBottom: 0, marginRigth:0, width: 25, heigth: 25)
        let tab = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        
        addImage.addGestureRecognizer(tab)
        
        view.addSubview(userName)
        userName.anchor(top: imageView.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 50, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: view.frame.width - 80 , heigth: 50)
        userName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addSubview(reg)
        reg.anchor(top: userName.bottomAnchor, left: userName.leftAnchor, bottom: nil, rigth: userName.rightAnchor, marginTop: 12, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
        Utilities.styleFilledButton(reg)
        
    }
    @objc func updateUsername(){
        guard  userName.text  != nil else {
            return
        }
        Utilities.waitProgress(msg: "Lütfen Bekleyin")
        setUserName()
        let db = Firestore.firestore().collection("username")
        db.getDocuments {[weak self] (querySnap, err) in
            if err == nil {
                for doc in querySnap!.documents {
                    if doc.documentID == self?.userName.text {
                        self?.userName.infoLabel.text = "Bu Kullanıcı Adı Zaten Kullanılıyor"
                        Utilities.dismissProgress()
                        return
                    }else{
                        let dic = ["email":(self?.currentUser.email)! as String,
                                   "uid":(self?.currentUser.uid)! as String,
                                   "username":(self?.userName.text)! as String] as [String:Any]
                        db.document((self?.currentUser.username)!).delete { (err) in
                            if err == nil {
                                db.document((self?.userName.text)!).setData(dic, merge: true) { (err) in
                                    if err == nil {
                                        let db = Firestore.firestore().collection("user")
                                            .document(Auth.auth().currentUser!.uid)
                                        db.setData(["username":(self?.userName.text)! as String], merge: true) { (err) in
                                            if err == nil {
                                                Utilities.dismissProgress()
                                                SVProgressHUD.showSuccess(withStatus: "Güncellendi")
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    func setUserName(){
        let textInput = userName.text
        let str2 = textInput!.replacingOccurrences(of: "\\,*,',?,%,$,^,#", with: "", options: .literal, range: nil)
        let username = str2.removingAllWhitespaces.lowercased().stripped
        userName.text  = "@" + username
        
    }
    
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func imgTapped(){
        presentPhotoActionSheet()
    }
    
}

extension EditProfile : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Profil Resmini Gör", style: .default, handler: {_ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Profil Resmini Sil", style: .default, handler: {_ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Yeni Bir Resim Çek", style: .default, handler: {[weak self]_ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Galeriden Resim Seç", style: .default, handler: {[weak self]_ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
        
    }
    
    
    func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true, completion: nil)
    }
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return}
        self.imageView.image = selectedImage
        let metaDataForImage = StorageMetadata()
        metaDataForImage.contentType = "image/jpeg"
        guard let uploadData = selectedImage.jpegData(compressionQuality: 0.8) else { return }
        let filename = "profileImage" + (Auth.auth().currentUser?.uid)!
        let storageRef = Storage.storage().reference().child("profileImage").child(filename)
        
        SVProgressHUD.setBackgroundColor(.black)
        SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setBorderColor(.white)
        
        SVProgressHUD.setForegroundColor(.white)
        let uploadTask = storageRef.putData(uploadData, metadata: metaDataForImage) {
            (metadata , err ) in
            if err != nil {
                print("failed upload image")
                return
            }
            
            Storage.storage().reference().child("profileImage").child(filename).downloadURL {(downloadUrl, err) in
                guard let profileImageUrl = downloadUrl?.absoluteString else {
                    print("DEBUG : profile Image url is null")
                    return
                }
                let db = Firestore.firestore()
                db.collection("user").document(Auth.auth().currentUser!.uid)
                    .setData(["profileImage" : profileImageUrl], merge: true){
                        (err) in
                        if err != nil {
                            print("failed set prfile image url",err?.localizedDescription as Any)
                        }
                        else{
                            print("succes")
                            guard let thumb = selectedImage.jpegData(compressionQuality: 0.2) else { return }
                            let filename = "thumb_image" + (Auth.auth().currentUser?.uid)!
                            let storageRef = Storage.storage().reference().child("thumb_image").child(filename)
                            storageRef.putData(thumb, metadata: metaDataForImage) {
                                (metadata , err ) in
                                if err != nil {
                                    print("failed upload image")
                                    return
                                }
                                Storage.storage().reference().child("thumb_image").child(filename).downloadURL { [weak self](downloadUrl, err) in
                                    guard let thumb_image = downloadUrl?.absoluteString else {
                                        print("DEBUG : profile Image url is null")
                                        return
                                    }
                                    db.collection("user").document(Auth.auth().currentUser!.uid).setData(["thumb_image":thumb_image], merge: true) { (err) in
                                        if err == nil {
                                            Utilities.dismissProgress()
                                            Utilities.waitProgress(msg: "Lütfen Bekleyin")
                                            self?.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                            self?.imageView.sd_setImage(with: URL(string: thumb_image), placeholderImage: UIImage(named: "holder_img")!)
                                            let db = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
                                            db.getDocument { (docSnap, err) in
                                                if err == nil {
                                                    self?.currentUser.thumb_image = thumb_image
                                                    self?.currentUser.profileImage = profileImageUrl
                                                    let vc = MainTabbar()
                                                    vc.currentUser = CurrentUser.init(dic: docSnap!.data()!)
                                                    SVProgressHUD.showSuccess(withStatus: "Resim Yüklendi")
                                                    SVProgressHUD.dismiss(withDelay: 1000)
                                                }}}}}}}
                }
                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    picker.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        _ = uploadTask.observe(.progress) { snapshot in
            
            
            let percentComplete = 100.0 * Float(snapshot.progress!.completedUnitCount)
                / Float(snapshot.progress!.totalUnitCount)
            
            SVProgressHUD.showProgress(percentComplete, status: "Resim Yükleniyor \n \(Float(snapshot.progress!.totalUnitCount / 1_24) / 1000) MB % \(Int(percentComplete))")
            
            print(percentComplete) // NSProgress object
        }
    }
}
