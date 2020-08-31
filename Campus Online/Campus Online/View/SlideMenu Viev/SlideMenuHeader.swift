//
//  SlideMenuHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FirebaseFirestore
class SlideMenuHeader: UITableViewHeaderFooterView {
    
    weak var delegate : MenuHeaderDelegate!
    var currentUser : CurrentUser?{
        willSet {
            guard let user = currentUser else {
                profileBtn.isHidden = true
                return }
            profileBtn.isHidden = false
            userName.text = user.username
            profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
            profileImage.sd_setImage(with: URL(string: user.thumb_image))
        }
        didSet{
            guard let user = currentUser else {
                profileBtn.isHidden = true
                return }
         
            profileBtn.isHidden = false
            userName.text = user.username
            name.text = user.name
            profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
            profileImage.sd_setImage(with: URL(string: user.thumb_image))
            
        }
    }
    
    
    
    let backBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        btn.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let editBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        btn.setImage(UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    public var profileImage : UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.backgroundColor = .darkGray
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .gray
        return image
    }()
    let addImage : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "add")
        return img
    }()
    let name : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 18)
        lbl.textColor = .black
        return lbl
    }()
    let userName : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .darkGray
        return lbl
    }()
    
    let homeBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        return btn
    }()
    
    let homeTitle : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Bilgisayar Mühendisliği", for: .normal)
        btn.tintColor = .black
        btn.titleLabel?.textColor = .black
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        return btn
    }()
    
    let profileBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("profili Görüntütle", for: .normal)
        return btn
    }()
    
    let showProfile : UIButton = {
        let btn = UIButton(type: .custom)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.layer.borderWidth = 1
        btn.setBackgroundColor(color: .white, forState: .normal)
        btn.setTitle(" Profilini Görüntüle ", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setTitleColor(.black, for: .normal)
        
        return btn
    }()
    
    let line : UIView = {
        let v = UIView()
        v.backgroundColor = .darkGray
        return v
    }()
    
    
    lazy var header : UIView = {
        let v = UIView()
        v.addSubview(profileImage)
        profileImage.anchor(top: v.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 100, heigth: 100)
        profileImage.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        profileImage.layer.cornerRadius = 100 / 2
        v.addSubview(addImage)
        addImage.anchor(top: nil, left: nil, bottom: profileImage.bottomAnchor, rigth: profileImage.rightAnchor, marginTop: -25, marginLeft: -25, marginBottom: 0, marginRigth:0, width: 25, heigth: 25)
        
        addImage.isUserInteractionEnabled = true
        profileImage.isUserInteractionEnabled = true
        addImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped)))
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped)))
        v.addSubview(name)
        name.anchor(top: profileImage.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 8, marginBottom: 0, marginRigth: 8, width: 0, heigth: 0)
        name.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        v.addSubview(userName)
        userName.anchor(top: name.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 8, marginBottom: 0, marginRigth: 8, width: 0, heigth: 0)
        userName.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        
        return v
    }()
    
    
    static let reuseIdentifier: String = String(describing: self)
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        addSubview(backBtn)
        backBtn.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 25, heigth: 25)
        addSubview(editBtn)
        editBtn.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 88, width: 25, heigth: 25)
        
        addSubview(header)
        header.anchor(top: backBtn.bottomAnchor, left: backBtn.rightAnchor, bottom: nil, rigth: editBtn.leftAnchor, marginTop: 4, marginLeft: 4, marginBottom: 0, marginRigth: 4, width: 0, heigth: 170)
        
        backBtn.addTarget(self, action: #selector(dismisMenu), for: .touchUpInside)
        editBtn.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        
        addSubview(showProfile)
        showProfile.anchor(top: header.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 8, marginBottom: 16, marginRigth: 8, width: frame.width, heigth: 25)
        showProfile.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        
        addSubview(line)
        line.anchor(top: showProfile.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 6, marginLeft: 32, marginBottom: 6, marginRigth: 112, width: 0, heigth: 0.5)
        
        
        showProfile.addTarget(self, action: #selector(showProfileFunc), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismisMenu(){
        delegate!.dismisMenu()
    }
    @objc func editProfile(){
        delegate!.editProfile()
    }
    @objc func showProfileFunc(){
        print("show profile")
        delegate!.showProfile()
    }
    @objc func imgTapped(){
        delegate!.editImage(for : self)
    }
}
