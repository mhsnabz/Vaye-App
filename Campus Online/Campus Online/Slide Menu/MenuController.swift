//
//  MenuController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.09.2020.
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
class MenuController: UIViewController {
    var listener : ListenerRegistration?
    var currentUser : CurrentUser
    var delegate : HomeControllerDelegate?
    var imageStartingFrame : CGRect?
    var scroolView : UIScrollView?
    var blackBackGround : UIView?
    var uploadTask : StorageUploadTask?
    var centerController : UIViewController!
    var tableView = UITableView(frame: .zero, style: .grouped)
    private var actionSheet : ActionSheetLauncher
    
    let verticalLine : UIView = {
        let v = UIView()
        v.backgroundColor = .darkGray
        return v
    }()
    //MARK:- lifeCycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let task = uploadTask else { return }
        task.removeAllObservers(for: .progress)
        task.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureTableView()
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser  , target: Target.profileEdit.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- functions
    private func configureTableView(){
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.register(HomeMenuCell.self, forCellReuseIdentifier: HomeMenuCell.reuseIdentifier)
        tableView.register(SlideMenuHeader.self, forHeaderFooterViewReuseIdentifier: SlideMenuHeader.reuseIdentifier )
    }
    
    
}

extension MenuController : UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeMenuCell.reuseIdentifier, for: indexPath) as! HomeMenuCell
        cell.backgroundColor = .white
        if indexPath.item == 1 {
            let menuOption = MenuOption(rawValue: indexPath.row)
            cell.homeBtn.setImage(menuOption?.image, for: .normal)
            cell.homeTitle.setTitle(currentUser.short_school, for: .normal)
            cell.delegate = self
            cell.selectionStyle = .none
        }else{
            let menuOption = MenuOption(rawValue: indexPath.row)
            cell.homeBtn.setImage(menuOption?.image, for: .normal)
            cell.homeTitle.setTitle(menuOption?.description, for: .normal)
            cell.delegate = self
            cell.selectionStyle = .none
        }
      
        if indexPath.row == 2 {
            cell.line.isHidden = false
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SlideMenuHeader.reuseIdentifier) as! SlideMenuHeader
        header.delegate = self
        header.currentUser = currentUser
        return header
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 250
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .white // Works!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = MenuOption(rawValue: indexPath.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
    
}
extension MenuController : SlideMenuDelegate {
    func handleSlideMenuItems(for cell: HomeMenuCell) {
        let menuOption = MenuOption(rawValue: self.tableView.indexPath(for: cell)!.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
}
extension MenuController : MenuHeaderDelegate {
    func editImage(for header: SlideMenuHeader)
    {
        actionSheet.delegate = self
        actionSheet.show()
    }
    
    func showProfile() {
        let vc = ProfileVC(currentUser: currentUser)
        vc.currentUser = currentUser
        navigationController?.pushViewController(vc, animated: true)
        dismisMenu()
        //        controller.modalPresentationStyle = .fullScreen
        //        self.present(controller, animated: true, completion: nil)
    }
    
    func editProfile() {
        
        let vc = EditProfile(currentUser : currentUser)
        vc.barTitle = "Profilini Düzenle"
        centerController = UINavigationController(rootViewController: vc)
        centerController.modalPresentationStyle = .fullScreen
        self.present(centerController, animated: true, completion: nil)
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

extension MenuController : ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .addLesson(_):
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
                }else{
                    print("profile image delete err : \(err?.localizedDescription as Any)")
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
        case .mega(_):
            break
        }
        
    }
    
    
}
extension MenuController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
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
