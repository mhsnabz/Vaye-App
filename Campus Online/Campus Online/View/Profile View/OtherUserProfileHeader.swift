//
//  OtherUserProfileHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SnapKit
import GoogleMobileAds
class OtherUserProfileHeader: UICollectionViewCell, ProfileFilterDelegateOtherUser {
    func ShowFilterUnderLine(_ view: OtherUserProfileFilterView, didSelect indexPath: IndexPath) {
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
    
    var adUnitID = "ca-app-pub-3940256099942544/4411468910"
    weak var delegate : OtherUserProfileHeaderDelegate?
    var interstitalGithub : GADInterstitial!
    var interstitalInsta : GADInterstitial!
    var interstitalLinked : GADInterstitial!
    var interstitalTwitter : GADInterstitial!
  
    var target : String = ""
    var controller : OtherUserProfile?

    var helps : helps?{
        didSet{
          
            guard let user = helps?.otherUser else { return }
            
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
            filterView.helps = helps
        }
    }
    var otherUser : OtherUser?{
        didSet{
           
       
        }
    }
    
    private let filterView = OtherUserProfileFilterView()
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
    
    let fallowerLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "Takipçi"
        lbl.textColor = .darkGray
        return lbl
    }()
    let fallowerNumber : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "25"
        lbl.textColor = .black
        return lbl
    }()
    let fallowingLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "Takip Edilen"
        lbl.textColor = .darkGray
        return lbl
    }()
    let fallowingNumber : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.text = "38"
        lbl.textColor = .black
        return lbl
    }()
    private let underLine : UIView = {
       let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goGithub), for: .touchUpInside)
        return btn
    }()
    lazy var linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goLinkedIn), for: .touchUpInside)
        return btn
    }()
    
    lazy var twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goTwitter), for: .touchUpInside)
        return btn
    }()
    lazy var instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(goInstagram), for: .touchUpInside)
        return btn
    }()
    //MARK:-lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterView.delegate = self

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
        
        
        let stackFallow = UIStackView(arrangedSubviews: [fallowingNumber,fallowingLabel,fallowerNumber,fallowerLabel])
        stackFallow.axis = .horizontal
        stackFallow.spacing = 6
        stackFallow.alignment = .leading
        let stackFallowSize = stackFallow.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        addSubview(stackFallow)
        stackFallow.anchor(top: profileImage.bottomAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 20, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: stackFallowSize.width, heigth: stackFallowSize.height)
        print(stackFallowSize.height + 20 )
        
        let stackSocial = UIStackView(arrangedSubviews: [github,linkedin,twitter,instagram])
        stackSocial.axis = .horizontal
        stackSocial.distribution = .fillEqually
        stackSocial.spacing = 20
        addSubview(stackSocial)
        stackSocial.anchor(top: stackFallow.bottomAnchor, left: stackFallow.leftAnchor, bottom: nil, rigth: nil, marginTop: 6, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 40)
        
        addSubview(filterView)
        filterView.anchor(top: stackSocial.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 2, marginRigth: 0, width: frame.width, heigth: 30)
        interstitalTwitter = createAd()
        interstitalGithub = createAd()
        interstitalLinked = createAd()
        interstitalInsta = createAd()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    
    //MARK:-selectors
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
             guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser!.github) ) else { return }
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
             guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser!.instagram) ) else { return }
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
             guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser!.twitter) ) else { return }
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
            guard let url = URL(string: otherUser!.linkedin ) else { return }
             UIApplication.shared.open(url)
        }
    }
   
    private func createAd() ->GADInterstitial {
        let ad = GADInterstitial(adUnitID: adUnitID)
        ad.delegate = self
        ad.load(GADRequest())
        return ad
    }
    private func getUsername(username : String) ->String{
        
        return username.replacingOccurrences(of: "@", with: "", options:NSString.CompareOptions.literal, range:nil)
    }
}
//extension OtherUserProfileHeader : OtherUserProfileFilterViewDelegate {
//
//
//
//}
extension OtherUserProfileHeader : GADInterstitialDelegate {
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser!.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser!.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser!.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser!.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("fail")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser!.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser!.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser!.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser!.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
        
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("reveived")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("fail")
        if target == "github"{
           
            guard let url = URL(string: socialMeadialink.github.descprition + getUsername(username: otherUser!.github) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "twitter"{
            guard let url = URL(string: socialMeadialink.twitter.descprition + getUsername(username: otherUser!.twitter) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "instagram"{
            guard let url = URL(string: socialMeadialink.instagram.descprition + getUsername(username: otherUser!.instagram) ) else { return }
            UIApplication.shared.open(url)
        }else if target == "linkedin"{
            guard let url = URL(string:  otherUser!.linkedin ) else { return }
            UIApplication.shared.open(url)
        }
        
    }
}
extension OtherUserProfileHeader : OtherUserProfileHeaderDelegate {
    func getMajorPost() {
        delegate?.getMajorPost()
    }
    
    func getSchoolPost() {
        delegate?.getSchoolPost()
    }
    
    func getCoPost() {
        delegate?.getCoPost()
    }
    
    
}
