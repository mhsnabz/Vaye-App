//
//  SetNewFoodMePost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 17.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//


import SDWebImage
import FirebaseFirestore
import CoreLocation
import ImagePicker
import Lightbox
import Gallery

private let imageCell = "cell"

class SetNewFoodMePost: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate{
    
    //MARK:-variables
    var snapShotlistener : ListenerRegistration?
    lazy var totolDataInMB : Float = 0.0
    var currentUserFollowers : [String]
    var locationName : String?
    var currentUser : CurrentUser
    
    lazy var heigth : CGFloat = 0.0
    var locationManager : CLLocationManager!
    var postDate : String!
    
    var gallery: GalleryController!
    lazy var dataModel = [FoodMeModel]()
    lazy var data = [SelectedData]()
    
    var collectionview: UICollectionView!
    var geoPoing : GeoPoint?{
        didSet{
            guard let loacaiton = geoPoing else {
                //                pinView.removeFromSuperview()
                return }
            Utilities.succesProgress(msg: "Konum Eklendi")
            print("lat : \(loacaiton.latitude)")
            print("lat : \(loacaiton.longitude)")
            
            
        }
    }
    
    
    //MARK: -properties
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
    let addTimer : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "timer").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(_addTimer), for: .touchUpInside)
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
    lazy var valuesView : UIView = {
        let view = UIView()
        let stackPin = UIStackView(arrangedSubviews: [value_image,value_description])
        stackPin.axis = .horizontal
        view.addSubview(stackPin)
        stackPin.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 40, width: 0, heigth: 25)
        view.addSubview(remove_Value)
        remove_Value.anchor(top: nil, left: nil, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 5, width: 25, heigth: 25)
        return view
    }()
    
    lazy var popUpWindow: PopUpNumberController = {
        let view = PopUpNumberController()
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
    //MARK:- lifeCycle
    init(currentUser : CurrentUser , currentUserFollowers : [String]){
        self.currentUser = currentUser
        
        self.currentUserFollowers = currentUserFollowers
        super.init(nibName: nil, bundle: nil)
        self.postDate = Int64(Date().timeIntervalSince1970 * 1000).description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()
        navigationItem.title = "Food Me"
        rigtBarButton()
        configureHeader()
        configureCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.waitProgress(msg: nil)
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
                    sself.pinView.isHidden = true
                   
                    Utilities.dismissProgress()
                    return
                }
                if snap.exists{
                    sself.pinView.isHidden = false
                    sself.geoPoing = snap.get("geoPoint") as? GeoPoint
                    sself.locationName = snap.get("locationName")  as? String
                    Utilities.succesProgress(msg: "Konum Eklendi")
                }else{
                    sself.pinView.isHidden = true
                    Utilities.dismissProgress()
                }
            }
        }
        
    }
    //MARK:-functions
    
    fileprivate func rigtBarButton() {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "post-it")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(setNewPost), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func configureHeader(){
        
        name = NSMutableAttributedString(string: (currentUser.name)!, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(currentUser.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userName.attributedText = name
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        
    }
    
    fileprivate func configureCollectionView() {
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 64)
        view.addSubview(text)
        
        text.anchor(top: headerView.bottomAnchor, left: headerView.leftAnchor, bottom: nil, rigth: headerView.rightAnchor, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 100)
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
        collectionview.register(FoodMeCell.self, forCellWithReuseIdentifier: imageCell)
        view.addSubview(visualEffectView)
        visualEffectView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.alpha = 0
        
    }
    
    
    private func checkDataModelHasValue(data : Data) ->Bool{
        dataModel.contains { (model) -> Bool in
            return  model.data == data
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
    
    
    //MARK:-selectors
    
    @objc func setNewPost(){
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
            FoodMeService.shared.setNewFoodMe(currentUser: currentUser, currentUserFollower: currentUserFollowers, location: geoPoing, locationName: locationName, postType: PostType.foodMe.despription, postId: date, msgText: text.text, datas: url, short_school: currentUser.short_school) {[weak self] (_) in
                guard let sself = self else { return }
                Utilities.succesProgress(msg: "Gönderi Paylaşıldı")
                sself.navigationController?.popViewController(animated: true)
                FoodMeService.shared.getTopicFollowers { (user) in
                    FoodMeService.shared.sendNotificaiton(currentUser: sself.currentUser, user: user, text: sself.text.text, type: NotificationType.new_food_me.desprition, postId: date)
                }
            }
        }else{
            MainPostUploadService.shareed.uploadDataBase(postDate: date, currentUser: currentUser,   postType: PostType.foodMe.despription, type: dataType, data: val) {[weak self] (url) in
                guard let sself = self else { return }
                FoodMeService.shared.setNewFoodMe(currentUser: sself.currentUser, currentUserFollower: sself.currentUserFollowers, location: sself.geoPoing, locationName: sself.locationName, postType: PostType.foodMe.despription, postId: date, msgText: sself.text.text, datas: url, short_school: sself.currentUser.short_school) { (_) in
                    MainPostUploadService.shareed.setThumbDatas(currentUser: sself.currentUser, postType: PostType.foodMe.despription, postId: date) { (_) in
                        Utilities.succesProgress(msg: "Paylaşıldı")
                        sself.navigationController?.popViewController(animated: true)
                        FoodMeService.shared.getTopicFollowers { (user) in
                            FoodMeService.shared.sendNotificaiton(currentUser: sself.currentUser, user: user, text: sself.text.text, type: NotificationType.new_food_me.desprition, postId: date)
                        }
                    }
                }
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
        db.delete { (err) in
            if err == nil {
                Utilities.succesProgress(msg: "Konum Silindi")
                self.pinView.isHidden = true
            }
        }
    }
    
    @objc func _addLocation(){
        let vc = MapVC(currentUser: currentUser)
        vc.locationManager = locationManager
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func _addImage(){
        Config.Camera.recordLocation = false
        Config.tabsToShow = [.imageTab]
        gallery = GalleryController()
        gallery.delegate = self
        gallery.modalPresentationStyle = .fullScreen
        present(gallery, animated: true, completion: nil)
    }
    @objc func _addTimer(){
        
    }
    
    
    
    //MARK: -image picker controller
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
               
                image.resolve {[weak self] (img) in
                    guard let sself = self else { return }
                    if let img_data = img!.jpegData(compressionQuality: 0.8){
                        if sself.checkDataModelHasValue(data:  img_data){
                            print("data is exist")
                        }else{
                            sself.data.append(SelectedData.init(data: img_data, type: DataTypes.image.description))
                            sself.dataModel.append(FoodMeModel.init(postDate: sself.postDate, currentUser: sself.currentUser, type: DataTypes.image.description, data: img_data))
                            
                            sself.collectionview.reloadData()
                            sself.navigationItem.title = "\( sself.getSizeOfData(data: sself.data)) mb"
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
        
        Utilities.waitProgress(msg: nil)
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            Utilities.dismissProgress()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}
//MARK:- UICollectionViewDataSource, UICollectionViewDelegate
extension SetNewFoodMePost :  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as! FoodMeCell
        if dataModel[indexPath.row].type == DataTypes.image.description
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as! FoodMeCell
            cell.backgroundColor = .white
            cell.delegate = self
            cell.data = dataModel[indexPath.row]
            
            return cell
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (view.frame.width - 30 ) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,                                minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
//MARK:-UITextViewDelegate
extension SetNewFoodMePost : UITextViewDelegate {
    
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
//MARK:-DeleteImageSetNewFoodMeSell
extension SetNewFoodMePost : DeleteImageSetNewFoodMeSell {
    func deleteImage(for cell: FoodMeCell) {
        guard let indexPath = self.collectionview.indexPath(for: cell) else { return }
        data.remove(at: indexPath.row)
        self.collectionview.reloadData()
        self.navigationItem.title = "\( getSizeOfData(data: data)) mb"
    }
    
    
}

