//
//  FiriendListItem.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class FiriendListItem: UICollectionViewCell {
    
    
    weak var user : FriendListModel?{
        didSet{
            configureUser()
        }
    }
    
    lazy var profileImage : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.3
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()
    
    lazy var userName : UILabel = {
       let lbl = UILabel()
        return lbl
    }()
   lazy var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    lazy var school : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    lazy var userSchoolName : UILabel = {
        let lbl = UILabel()
         return lbl
    }()
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImage)
        profileImage.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 50, heigth: 50)
        profileImage.layer.cornerRadius = 25
        
        let stack = UIStackView(arrangedSubviews: [userName,userSchoolName])
        stack.axis = .horizontal
        stack.spacing = 8
        addSubview(stack)
        stack.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 50)
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 8, marginBottom: 1, marginRigth: 8, width: 0, heigth: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUser(){
        guard let user = user else { return }
        name = NSMutableAttributedString(string: "\(user.name!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(user.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        userName.attributedText = name
        school = NSMutableAttributedString(string: "\(user.short_school!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 11)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        school.append(NSAttributedString(string: "  \(user.bolum!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 11)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        userSchoolName.attributedText = school
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: user.thumb_image))
    }
    
}
