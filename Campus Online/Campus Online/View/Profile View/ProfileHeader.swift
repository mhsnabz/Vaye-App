//
//  ProfileHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FirebaseFirestore
class ProfileHeader : UICollectionReusableView {
    var controller : OtherUserProfile?
    weak var delegate : ProfileHeaderDelegate?
    var currentUser : CurrentUser!{
        didSet{
            guard let user = currentUser else { return }
            filterView.currentUser = user
          
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
            getFollowersCount(currentUser: user, completion: {[weak self] (val) in
                guard let sself = self else {
                    return
                    
                }
                sself.followers = NSMutableAttributedString(string: "\(val)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
                sself.followers.append(NSAttributedString(string: "  Takipçi", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
                print(sself.followers)
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
    private let filterView = ProfileFilterView()
  
    
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.6
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .darkGray
        
        
        return image
    }()
    
    let name : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 16)
        lbl.textColor = .black
        lbl.text = "..."
        return lbl
    }()
    let number : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "..."
        lbl.textColor = .darkGray
        return lbl
    }()
    let major : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "..."
        lbl.textColor = .darkGray
        return lbl
    }()
    let school : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "..."
        lbl.textColor = .darkGray
        return lbl
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
  
     let underLine : UIView = {
       let view = UIView()
        view.backgroundColor = .black
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterView.delegate = self
        filterView.filterDelagate = self
        backgroundColor = .white
        addSubview(profileImage)
        profileImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 100, heigth: 100)
        profileImage.layer.cornerRadius = 50
        
        let stack = UIStackView(arrangedSubviews: [name,number,school,major,number])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        let stackSize = stack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        addSubview(stack)
        stack.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: frame.width, heigth: stackSize.height)
        stack.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        
        let stackFallow = UIStackView(arrangedSubviews: [fallowingLabel,fallowerLabel])
        stackFallow.axis = .horizontal
        stackFallow.spacing = 4
        stackFallow.alignment = .leading
//        let stackFallowSize = stackFallow.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        addSubview(stackFallow)
        stackFallow.anchor(top: profileImage.bottomAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 20)
        
     
        addSubview(stackView)
        stackView.anchor(top: stackFallow.bottomAnchor, left: stackFallow.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 40)
        
        addSubview(filterView)
        filterView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 2, marginRigth: 0, width: frame.width, heigth: 30)

        addSubview(underLine)
        
        underLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width / 4, heigth: 2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    //MARK:-selectors
    @objc func goGithub(){
        
        guard let currentUser = currentUser else {
            return
        }
        
        guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: currentUser.github) ) else { return }
        UIApplication.shared.open(url)
    }
    @objc func goInstagram(){
        guard let currentUser = currentUser else {
            return
        }
        guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: currentUser.instagram) ) else { return }
        UIApplication.shared.open(url)
    }
    @objc func goTwitter(){
        guard let currentUser = currentUser else {
            return
        }
        guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: currentUser.twitter) ) else { return }
        UIApplication.shared.open(url)
    }
    @objc func goLinkedIn(){
        guard let currentUser = currentUser else {
            return
        }
        guard let url = URL(string: currentUser.linkedin ) else { return }
         UIApplication.shared.open(url)
    }
    
   

    private func getUsername(username : String) ->String{
        
        return username.replacingOccurrences(of: "@", with: "", options:NSString.CompareOptions.literal, range:nil)
    }
    private func getShortMajor(major : String) ->String {
        var shortName  : String = ""
        let bolumName = major.components(separatedBy: " ")
        for item in bolumName {
            shortName += item[0].string
        }
        return shortName
    }

}
extension ProfileHeader : UserProfileFilterDelegate {
    func didSelectOption(option: ProfileFilterViewOptions) {
//        switch option {
//       
//        case .bolum():
//            delegate?.getMajorPost()
//        case .shortSchool():
//            delegate?.getSchoolPost()
//        case .onlineCampus():
//            delegate?.getCoPost()
//        case .fav():
//            delegate?.getFav()
//        }
    }
    
    
}

extension ProfileHeader : ProfileFilterDelegate {
    func ShowFilterUnderLine(_ view: ProfileFilterView, didSelect indexPath: IndexPath) {
        guard let cell = view.collectionView.cellForItem(at: indexPath) as?
            ProfileFilterCell else{
                return
        }
        let xPosition = cell.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.underLine.frame.origin.x = xPosition
        }
    }
    
    
}

