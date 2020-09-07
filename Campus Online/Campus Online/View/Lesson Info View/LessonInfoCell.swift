//
//  LessonInfoCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class LessonInfoCell: UICollectionViewCell
{
    var user : LessonFallowerUser? {
        didSet {
            configureCell()
        }
    }
    
    let img : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.backgroundColor = .white
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.borderWidth = 0.4
        return img
    }()
    let name : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let username : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .lightGray
        return lbl
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(img)
        img.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 40, heigth: 40)
        img.layer.cornerRadius = 40 / 2
        img.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let stack = UIStackView(arrangedSubviews: [name,username])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        addSubview(stack)
        stack.anchor(top: nil, left: img.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        stack.centerYAnchor.constraint(equalTo: img.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(){
        guard let user = user else {
            return
        }
        img.sd_imageIndicator = SDWebImageActivityIndicator.gray
        img.sd_setImage(with: URL(string: user.thumb_image!))
        print(user.thumb_image!)
        name.text = user.name
        username.text =  user.username
    }
}
