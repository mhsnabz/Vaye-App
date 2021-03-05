//
//  CurrentUserProfileHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FirebaseFirestore

class CurrentUserProfileHeader: UICollectionReusableView {
 
    weak var profileHeaderDelegate : ProfileHeaderMenuBarDelegate?
   
    var currentUser : CurrentUser?{
        didSet{
            configure()
        }
    }
    
    var profileModel : ProfileModel?{
        didSet{
            menuBar.profileModel = profileModel
        }
    }
    
    //MARK:-propeties
    
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
        followBtn.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
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
//        menuBar.setupHorizantalVar(size : 1)
        menuBar.filterDelagate = self
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-selectors
    @objc func editProfile(){
       
    }
    
    @objc func goGithub(){
    
    }
    @objc func goInstagram(){
     
    }
    @objc func goTwitter(){
    
    }
    @objc func goLinkedIn(){
 
    }
    //MARK:-functions
    func configure() {
        guard let user = currentUser else { return }
        getFollowersCount(currentUser: user, completion: {[weak self] (val) in
            guard let sself = self else {
                return
                
            }
            sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
            sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
            sself.fallowerLabel.attributedText = sself.followers
            
        })
        getFollowingCount(currentUser: user, completion: {[weak self] (val) in
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
    
    private func getFollowersCount(currentUser : CurrentUser , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("fallowers")
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
    private func getFollowingCount(currentUser : CurrentUser , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("following")
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

}
//MARK:-UserProfileMenuBarDelegate
extension CurrentUserProfileHeader : UserProfileMenuBarDelegate {
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
