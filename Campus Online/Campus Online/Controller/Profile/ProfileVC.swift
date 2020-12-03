//
//  ProfileVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let vaye_id = "vaye_id"
private let school_id = "school_id"
private let fav_id = "fav_id"
private let home_id = "home_id"
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
class ProfileVC: UIViewController  , UIScrollViewDelegate, didScroolDelegate{
   
    

    //MARK: - variables
    
    var profileModel : ProfileModel
    var controller : UIViewController!
    lazy var count : Int = 0
    var currentUser : CurrentUser
    var collectionview: UICollectionView!

    //MARK: -properties
    let titleLbl : UILabel = {
       let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let dissmisButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "down-arrow"), for: .normal)
        
        return btn
    }()
    lazy var headerBar : UIView = {
       let v = UIView()
      
        v.addSubview(dissmisButton)
        dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(titleLbl)
        titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        return v
    }()
 
    lazy var menuBar  : MenuBar = {
       let v = MenuBar()

        return v
    }()
    
    //MARK:- header properites
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.6
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .darkGray
        return image
    }()
    lazy var followBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setTitle("Profilini Düzenle", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        return btn
    }()
    lazy var imageSections : UIView = {
        let view = UIView()
         view.addSubview(profileImage)
         profileImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 65, heigth: 65)
        
         profileImage.layer.cornerRadius = 65 / 2
       
         
         view.addSubview(followBtn)
         followBtn.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 50, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
         followBtn.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
       
//         followBtn.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
         return view

    }()
    
    
    let name : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 16)
        lbl.textColor = .black

        return lbl
    }()
    let major : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)

        lbl.textColor = .darkGray
        return lbl
    }()
    let school : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
   
        lbl.textColor = .darkGray
        return lbl
    }()
    let number : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.text = "121503031"
        lbl.textColor = .darkGray
        return lbl
    }()
    lazy var aboutSection : UIView = {
       let v = UIView()
        let stack = UIStackView(arrangedSubviews: [name,number,school,major,number])
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .leading
        v.addSubview(stack)
        stack.anchor(top: nil, left: v.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
        return v
    }()
    
    
    var followers : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    var following : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    let fallowerLabel : UILabel = {
        let lbl = UILabel()
       
        return lbl
    }()
   
    let fallowingLabel : UILabel = {
        let lbl = UILabel()

        return lbl
    }()
    
    
    let github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    let linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goLinkedIn), for: .touchUpInside)
        return btn
    }()
    
    let twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goTwitter), for: .touchUpInside)
        return btn
    }()
    let instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.addTarget(self, action: #selector(goInstagram), for: .touchUpInside)
        return btn
    }()
    
    lazy var stackView : UIStackView = {
        let stackSocial = UIStackView(arrangedSubviews: [github,linkedin,twitter,instagram])
        stackSocial.axis = .horizontal
        stackSocial.distribution = .fillEqually
        stackSocial.spacing = 20
        return stackSocial
    }()
    
    lazy var stackFallow : UIStackView = {
        let stackFallow = UIStackView(arrangedSubviews: [fallowingLabel,fallowerLabel])
        stackFallow.axis = .horizontal
        stackFallow.spacing = 4
        stackFallow.alignment = .leading
        return stackFallow
    }()
    
    lazy var headerView : UIView = {
       let v = UIView()
        v.addSubview(profileImage)
        profileImage.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 65, heigth: 65)
        profileImage.layer.cornerRadius = 65 / 2
         v.addSubview(followBtn)
         followBtn.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: v.rightAnchor, marginTop: 0, marginLeft: 50, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        followBtn.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        v.addSubview(aboutSection)
        aboutSection.anchor(top: profileImage.bottomAnchor, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
       
        v.addSubview(stackFallow)
        stackFallow.anchor(top: aboutSection.bottomAnchor, left: aboutSection.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 12, marginBottom: 0, marginRigth: 20, width: 0, heigth: 20)
        v.addSubview(stackView)
        stackView.anchor(top: stackFallow.bottomAnchor, left: stackFallow.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 40)
        v.addSubview(menuBar)
        menuBar.anchor(top: nil, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
     
        
        return v
    }()
    


    //MARK: - lifeCycle
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
     
        self.profileModel = ProfileModel.init(shortSchool: currentUser.short_school, currentUser: currentUser, major: currentUser.bolum, uid: currentUser.uid)
        super.init(nibName: nil, bundle: nil)
     
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = currentUser.username
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        configureUI()
        configureCollectionView()
        titleLbl.text = currentUser.username
   
    }
   
 
    func configureUI(){
         view.backgroundColor = .white
        name.text = currentUser.name
        school.text = currentUser.schoolName
        major.text = currentUser.bolum
        UserService.shared.getFollowersCount(uid: currentUser.uid) {[weak self] (val) in
            guard let sself = self else { return }
            sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

            sself.fallowerLabel.attributedText = sself.followers
        }
        UserService.shared.getFollowingCount(uid : currentUser.uid){[weak self]  (val) in
            guard let sself = self else { return }
            sself.following = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.following.append(NSAttributedString(string: "  Takip Edilen  ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
            sself.fallowingLabel.attributedText = sself.following
        }
        
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        profileImage.sd_setImage(with: URL(string: currentUser.thumb_image))
        if currentUser.linkedin == "" {
            linkedin.isHidden = true
        }
        if currentUser.instagram == ""{
            instagram.isHidden = true
        }
        if currentUser.twitter == ""{
            twitter.isHidden = true
        }
        if currentUser.github == ""{
            github.isHidden = true
        }
        print("nav bar widrth")
     }
    func configureCollectionView(){
//        view.addSubview(scroolView)
//        scroolView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width:0, heigth: 0)
        view.addSubview(headerView)
//        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width, heigth: 285)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionview.backgroundColor = .white
        layout.scrollDirection = .horizontal
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .red
        
        collectionview.register(VayeAppPostCell.self, forCellWithReuseIdentifier: vaye_id)
        collectionview.register(HomePostCell.self, forCellWithReuseIdentifier: home_id)
        collectionview.register(FavPostCell.self, forCellWithReuseIdentifier: fav_id)
        collectionview.register(SchoolPostCell.self, forCellWithReuseIdentifier: school_id)
        
        view.addSubview(collectionview)
//        collectionview.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: view.frame.height)
//        collectionview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
         }
    func scrollingTo(point: CGFloat) {
        print("scroll to : \(point)")
        let h = max(point,150)
        if point < 20 {
            headerView.frame = CGRect(x: 0, y: 85, width: view.frame.width, height: 285)
//            collectionview.frame = CGRect(x: 0, y: 396, width: view.frame.width, height: view.frame.height - 396 + point)
            collectionview.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
            view.layoutIfNeeded()
            view.needsUpdateConstraints()
        }
       else if point > 20 && point < 150 {
            headerView.frame = CGRect(x: 0, y: -h, width: view.frame.width, height: 285)
        collectionview.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        view.layoutIfNeeded()
        view.needsUpdateConstraints()
        }else{
            headerView.frame = CGRect(x: 0, y: -150, width: view.frame.width, height: 285)
            collectionview.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
            view.layoutIfNeeded()
            view.needsUpdateConstraints()

            
        }
       
    }
    
  
  



    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let y = -scrollView.contentOffset.y
//        print(y)
        let h = max(y,50)
     
        print(h)
//
//        if h <= 230 {
//            stackView.isHidden = true
//        }else{
//            stackView.isHidden = false
//        }
//
//        if h <= 110 {
//            aboutSection.isHidden = true
//        }else{
//            aboutSection.isHidden = false
//        }
//        if h <= 180 {
//            stackFallow.isHidden = true
//        }else{
//            stackFallow.isHidden = false
//        }
        
//        profileImage.frame = CGRect(x: 24, y: 4, width: (h) * ((65 * 100) / 285) / 100 , height: (h) * ((65 * 100) / 285) / 100)
//        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        if profileImage.frame.width <= 30 {
            profileImage.isHidden = true
            followBtn.isHidden = true
        }else{
            profileImage.isHidden = false
            followBtn.isHidden = false
        }

       
    }
    
    
  

   
 
  
   
     @objc func dissmis(){
        self.dismiss(animated: true, completion: nil)
     }
   

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ProfileVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: home_id, for: indexPath) as! HomePostCell
            cell.delegate = self
            return cell
        }else if indexPath.item == 1 {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: school_id, for: indexPath) as! SchoolPostCell
            cell.delegate = self

            return cell
        }else if indexPath.item == 2 {
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: vaye_id, for: indexPath) as! VayeAppPostCell
            return cell
        }else{
            let cell = collectionview.dequeueReusableCell(withReuseIdentifier: fav_id, for: indexPath) as! FavPostCell
            return cell
        }
    }
   
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height + 235)
    }

    
}


