//
//  Profile_Header.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SnapKit
import FirebaseFirestore
import GoogleMobileAds

protocol HeaderSelectedIndex : class {
    func selectedIndex ( _ index : IndexPath)
}
class Profile_Header: UICollectionReusableView
{
    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
    var interstitalGithub : GADInterstitial!
    var interstitalInsta : GADInterstitial!
    var interstitalLinked : GADInterstitial!
    var interstitalTwitter : GADInterstitial!
    var target : String = ""
    var controller : OtherUserProfile?
    weak var delegate : HeaderSelectedIndex?
    func didSelec(_ index: IndexPath) {
        delegate?.selectedIndex(index)
    }
  
    weak var profileHeaderDelegate : ProfileHeaderMenuBarDelegate?
    
    //MARK:-properties
    var profileModel : ProfileModel?{
        didSet{
            menuBar.profileModel = profileModel

            guard let currentUser = profileModel?.currentUser else { return }
            guard let otherUserUid = profileModel?.uid else { return }
            UserService.shared.checkFollowers(currentUser: currentUser, otherUser: otherUserUid) {[weak self] (_val) in
                guard let sself = self else { return }
                sself.isFallowingUser = _val

            }
        }
    }
    
    
    var currentUser : CurrentUser!
    var user : OtherUser!{
        didSet{
            
            configure()
        }
    }
    
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.6
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .darkGray
        return image
    }()
    lazy var sendMsgButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(#imageLiteral(resourceName: "msg").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    lazy var followBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setTitle("yükleniyor...", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
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
        
        view.addSubview(sendMsgButton)
        sendMsgButton.anchor(top: nil , left: profileImage.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        sendMsgButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        view.addSubview(followBtn)
        followBtn.anchor(top: nil, left: sendMsgButton.rightAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 30)
        followBtn.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        followBtn.addTarget(self, action: #selector(fallowUser), for: .touchUpInside)
        return view
    }()
    
    let name : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 16)
        lbl.textColor = .black
        lbl.text = "Selim Abuzeyitoğlu"
        return lbl
    }()
    let major : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.text = "Bilgisayar Mühendisliği"
        lbl.textColor = .darkGray
        return lbl
    }()
    let school : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.text = "İskenderun Teknik Üniversitesi"
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
       let view = UIView()
        let stack = UIStackView(arrangedSubviews: [name,number,school,major,number])
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .leading
        view.addSubview(stack)
        stack.anchor(top: nil, left: view.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
        return view
    }()
    
    let github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    let linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goLinkedIn), for: .touchUpInside)
        return btn
    }()
    
    let twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goTwitter), for: .touchUpInside)
        return btn
    }()
    let instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goInstagram), for: .touchUpInside)
        return btn
    }()
    
    lazy var stackView : UIStackView = {
        let stackSocial = UIStackView(arrangedSubviews: [github,linkedin,twitter,instagram])
        stackSocial.axis = .horizontal
        stackSocial.distribution = .fillEqually
        stackSocial.spacing = 20
        return stackSocial
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
    lazy var menuBar  : MenuBar = {
       let v = MenuBar()

        return v
    }()
     var isFallowingUser : Bool?{
        didSet{
            guard let val = isFallowingUser else { return }
            if val{
                followBtn.setTitle("Takibi Bırak", for: .normal)
                followBtn.setBackgroundColor(color: .red, forState: .normal)
                followBtn.setTitleColor(.white, for: .normal)
                followBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
                followBtn.layer.borderColor = UIColor.red.cgColor
            }else{
                followBtn.setTitle("Takip Et", for: .normal)
                followBtn.setBackgroundColor(color: .mainColor(), forState: .normal)
                followBtn.setTitleColor(.white, for: .normal)
                followBtn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
                followBtn.layer.borderColor = UIColor.mainColor().cgColor
            }
        }
    }

  
    
    //MARK:-lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageSections)
        imageSections.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 70)
        addSubview(aboutSection)
        aboutSection.anchor(top: imageSections.bottomAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 75)
        let stackFallow = UIStackView(arrangedSubviews: [fallowingLabel,fallowerLabel])
     
        stackFallow.axis = .horizontal
        stackFallow.spacing = 4
        stackFallow.alignment = .leading
        addSubview(stackFallow)
        stackFallow.anchor(top: aboutSection.bottomAnchor, left: aboutSection.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 12, marginBottom: 0, marginRigth: 20, width: 0, heigth: 20)
        addSubview(stackView)
        stackView.anchor(top: stackFallow.bottomAnchor, left: stackFallow.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 40)
       addSubview(menuBar)
        menuBar.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
        menuBar.filterDelagate = self
        interstitalTwitter = createAd()
        interstitalGithub = createAd()
        interstitalLinked = createAd()
        interstitalInsta = createAd()
        menuBar.setupHorizantalVar(size: 1)

    }
    private func createAd() ->GADInterstitial {
        let ad = GADInterstitial(adUnitID: adUnitID)
        ad.delegate = self
        ad.load(GADRequest())
        return ad
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-selectors
    @objc func fallowUser(){
        guard let isFallowingUser = isFallowingUser else {return}
        Utilities.waitProgress(msg: "")
        guard let user = user else { return }
        guard let currentUser = profileModel?.currentUser else { return }
        if isFallowingUser{
            let db = Firestore.firestore().collection("user")
                .document(user.uid).collection("fallowers").document(currentUser.uid)
            db.delete {[weak self] (err) in
                guard let sself = self else { return }
                if err == nil {
                    
                    UserService.shared.checkFollowers(currentUser: currentUser, otherUser: user.uid) { (val) in
                        sself.isFallowingUser = val
              
                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(currentUser.uid)
                        .collection("following").document(user.uid)
                    db.delete { (err) in
                        if err == nil {
                            Utilities.succesProgress(msg: "Takip Etmeyi Bıraktınız ")
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                
                
                }
            }
        }else{
            let db = Firestore.firestore().collection("user")
                .document(user.uid).collection("fallowers").document(currentUser.uid)
            db.setData(["user":currentUser.uid as Any] as [String:Any], merge: true) {[weak self] (err) in
                if err == nil {
                    guard let sself = self else { return }
                
                    UserService.shared.checkFollowers(currentUser: currentUser, otherUser: user.uid) { (val) in
                        sself.isFallowingUser = val

                        Utilities.succesProgress(msg: nil)
                    }
                    let db = Firestore.firestore().collection("user")
                        .document(currentUser.uid)
                        .collection("following").document(user.uid)
                  
                    db.setData(["user":user.uid as Any], merge: true) { (err) in
                        if err == nil{
                            Utilities.succesProgress(msg: "Takip Ediliyor")
                            NotificaitonService.shared.start_following_you(currentUser: currentUser, otherUser: user, text: Notification_description.following_you.desprition, type: NotificationType.following_you.desprition) { (_) in
                                
                            }
                        }else{
                            Utilities.errorProgress(msg: nil)
                        }
                    }
                  
                }
            }
        }
    }
    
    @objc func goGithub(){
        if interstitalGithub.isReady {
            guard let vc = controller else {
                target = "github"
                print("go github")
                return
            }
            target = "github"
            interstitalGithub.present(fromRootViewController: vc)
        }else{
            guard let otherUser = user else { return }
            
             guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goInstagram(){
        if interstitalInsta.isReady {
            guard let vc = controller else {
                target = "instagram"
                print("go github")
                return
            }
            target = "instagram"
            interstitalInsta.present(fromRootViewController: vc)
        }else{
            guard let otherUser = user else { return }
             guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goTwitter(){
        if interstitalTwitter.isReady {
            guard let vc = controller else {
                target = "twitter"
                print("go github")
                return
            }
            target = "twitter"
            interstitalTwitter.present(fromRootViewController: vc)
        }else{
            guard let otherUser = user else { return }
             guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
             UIApplication.shared.open(url)
        }
    }
    @objc func goLinkedIn(){
        if interstitalLinked.isReady {
            guard let vc = controller else {
                target = "linkedin"
                print("go github")
                return
            }
            target = "linkedin"
            interstitalLinked.present(fromRootViewController: vc)
        }else{
            guard let otherUser = user else { return }
            guard let url = URL(string: otherUser.linkedin ) else { return }
             UIApplication.shared.open(url)
        }
    }
    
    //MARK:-functions
    
    private func getFollowersCount(otherUser : OtherUser , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("fallowers")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard  let snap = querySnap else {
                    completion("0")
                    return
                }
                    completion(snap.documents.count.description)
                
                }
            }
        }
    private func getFollowingCount(otherUser : OtherUser , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("following")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard  let snap = querySnap else {
                    completion("0")
                    return
                }
                    completion(snap.documents.count.description)
                
                }
            }
        }
    
    private func configure(){
        guard let user = user else { return }
        getFollowersCount(otherUser: user, completion: {[weak self] (val) in
            guard let sself = self else {
                return
                
            }
            sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))

            sself.fallowerLabel.attributedText = sself.followers
            
        })
        getFollowingCount(otherUser: user, completion: {[weak self] (val) in
            guard let sself = self else {
                return
            }
            sself.following = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.following.append(NSAttributedString(string: "  Takip Edilen  ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
            sself.fallowingLabel.attributedText = sself.following
        })
        
        name.text = user.name
        number.text = user.number
        major.text = user.bolum
        school.text = user.schoolName
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        profileImage.sd_setImage(with: URL(string: user.thumb_image))
        
        if user.linkedin == "" {
            linkedin.isHidden = true
        }
        if user.instagram == ""{
            instagram.isHidden = true
        }
        if user.twitter == ""{
            twitter.isHidden = true
        }
        if user.github == ""{
            github.isHidden = true
        }
        
     
    }
    private func getUsername(username : String) ->String{
        
        return username.replacingOccurrences(of: "@", with: "", options:NSString.CompareOptions.literal, range:nil)
    }

    
}

extension Profile_Header : UserProfileMenuBarDelegate {
    func didSelectOptions(option: ProfileFilterOptions) {
        switch option {
        
        case .major():
            profileHeaderDelegate?.getMajorPost()
        case .shortSchool():
            profileHeaderDelegate?.getSchoolPost()
        case .vayeApp():
            profileHeaderDelegate?.getVayeAppPost()
        case .fav():
            profileHeaderDelegate?.getFavPost()
        }
    }
    
    
}
extension Profile_Header : GADInterstitialDelegate {
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        
        guard let otherUser = user else { return }
        
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("fail")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        guard let otherUser = user else { return }
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
        
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("reveived")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        guard let otherUser = user else { return }
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
        
    }
}
