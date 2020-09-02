//
//  HomeMenuController.swift
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
private let cellId = "id"
class HomeMenuController: UITableViewController {
    var listener : ListenerRegistration?
    var currentUser : CurrentUser
    var delegate : HomeControllerDelegate?
    var imageStartingFrame : CGRect?
    var scroolView : UIScrollView?
    var blackBackGround : UIView?
    var uploadTask : StorageUploadTask?
    //    private let target : String
    private var actionSheet : ActionSheetLauncher
    let verticalLine : UIView = {
        let v = UIView()
        v.backgroundColor = .darkGray
        return v
    }()
    
    //MARK: -lifeCycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let task = uploadTask else { return }
        task.removeAllObservers(for: .progress)
        task.removeAllObservers()
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser  , target: Target.profileEdit.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getCurrentUser()
        configureTableView()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    //    private func getCurrentUser () {
    //        guard currentUser == nil else { return }
    //        let db = Firestore.firestore().collection("user")
    //            .document(Auth.auth().currentUser!.uid)
    //        db.getDocument { (docSnap, err) in
    //            if err == nil {
    //                self.currentUser = CurrentUser.init(dic: docSnap!.data()!)
    //                self.tableView.reloadData()
    //            }
    //        }
    //    }
    
    //MARK:- function
    
    
    private func configureTableView(){
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.register(HomeMenuCell.self, forCellReuseIdentifier: cellId)
        tableView.register(SlideMenuHeader.self, forHeaderFooterViewReuseIdentifier: SlideMenuHeader.reuseIdentifier )
        
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomeMenuCell
        cell.backgroundColor = .white
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.homeBtn.setImage(menuOption?.image, for: .normal)
        cell.homeTitle.setTitle(menuOption?.description, for: .normal)
        cell.delegate = self
        cell.selectionStyle = .none
        if indexPath.row == 2 {
            cell.line.isHidden = false
        }
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SlideMenuHeader.reuseIdentifier) as! SlideMenuHeader
        header.delegate = self
        header.currentUser = currentUser
        //        if Auth.auth().currentUser != nil{
        //            let db = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
        //            listener  = db.addSnapshotListener {[weak self] (docSnap, err) in
        //                if docSnap!.exists  {
        //                    self?.currentUser = CurrentUser.init(dic: docSnap!.data()!)
        //                    header.userName.text = (docSnap!.get("username") as! String).description
        //                    self?.tableView.reloadData()
        //                }
        //
        //            }
        //        }
        return header
        
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 250
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .white // Works!
        }
    }
    
    
}
extension HomeMenuController : SlideMenuDelegate {
    func handleSlideMenuItems(for cell: HomeMenuCell) {
        let menuOption = MenuOption(rawValue: self.tableView.indexPath(for: cell)!.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
}
extension HomeMenuController : MenuHeaderDelegate {
    func editImage(for header: SlideMenuHeader)
    {
        actionSheet.delegate = self
        actionSheet.show()
    }
    
    func showProfile() {
        let vc = ProfileVC()
        
        vc.modalPresentationStyle = .fullScreen
        vc.currentUser = currentUser
        self.present(vc, animated: true, completion: nil)
    }
    
    func editProfile() {
        
        let vc = EditProfile(currentUser : currentUser)
        vc.barTitle = "Profilini Düzenle"
        
        vc.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    func dismisMenu() {
        delegate?.handleMenuToggle(forMenuOption: nil)
    }
    @objc func dismissImage(tabGesture : UITapGestureRecognizer){
        
        if  let zoomOutImageView = tabGesture.view {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.blackBackGround?.alpha = 0
                
                
            }) { (bool) in
                zoomOutImageView.removeFromSuperview()
                self.blackBackGround?.removeFromSuperview()
            }
            
            
        }
        
    }}

extension HomeMenuController : ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .removeLesson(_):
            break
        case .lessonInfo(_):
            break
        case .reportLesson(_):
            break
        case .showPicture(_):
            let vc = FullScreenImage()
            vc.image = currentUser.profileImage
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            break
        case .removePicture(_):
            Utilities.waitProgress(msg: "Siliniyor")
            guard let thumbUrl = currentUser.thumb_image else {
                Utilities.dismissProgress()
                return
            }
            guard  let profileUrl = currentUser.profileImage  else {
                Utilities.dismissProgress()
                
                return
            }
            let storage = Storage.storage()
            let ref = storage.reference(forURL: profileUrl)
            ref.delete { (err) in
                if err == nil {
                    let r = storage.reference(forURL: thumbUrl)
                    r.delete { (err) in
                        if err == nil {
                            let db = Firestore.firestore().collection("user")
                                .document(self.currentUser.uid)
                            let dic = ["thumb_image":"","profileImage":""] as [String:Any]
                            db.setData(dic, merge: true) { (err) in
                                if err == nil {
                                    self.currentUser.profileImage = ""
                                    self.currentUser.thumb_image = ""
                                    self.tableView.reloadData()
                                    Utilities.succesProgress(msg: "Resim Silindi")
                                }else{
                                    Utilities.errorProgress(msg: "hata")
                                }
                            }
                            
                            
                        }
                    }
                }
            }
            break
        case .takePicture(_):
            presentCamera()
            break
        case .choosePicture(_):
            presentPhotoPicker()
            break
        case .googleDrive(_):
            break
        case .dropBox(_):
            break
        case .yandexDisk(_):
            break
        case .iClould(_):
            break
        case .oneDrive(_):
            break
        }
        
    }
    
    
}
extension HomeMenuController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
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
        let vc = SlideMenuHeader()
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return}
        vc.profileImage.image = selectedImage
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
         uploadTask = storageRef.putData(uploadData, metadata: metaDataForImage) {
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
                                            Utilities.succesProgress(msg: "Resim Yüklendi")
                                            self?.tableView.reloadData()
                                            vc.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                            vc.profileImage.sd_setImage(with: URL(string: thumb_image), placeholderImage: UIImage(named: "holder_img")!)
                                            self?.currentUser.thumb_image = thumb_image
                                            self?.currentUser.profileImage = profileImageUrl
                                        }}}}}
                }
                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    picker.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        if uploadTask != nil {
            _ = uploadTask!.observe(.progress) { snapshot in
                
                
                let percentComplete = 100.0 * Float(snapshot.progress!.completedUnitCount)
                    / Float(snapshot.progress!.totalUnitCount)
                
                SVProgressHUD.showProgress(percentComplete, status: "Resim Yükleniyor \n \(Float(snapshot.progress!.totalUnitCount / 1_24) / 1000) MB % \(Int(percentComplete))")
                
                print(percentComplete) // NSProgress object
            }
        }
       
    }
}
