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
class ProfileHeader : UICollectionReusableView {
    
    var currentUser : CurrentUser?{
        didSet{
            guard let user = currentUser else { return }
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
    
    let github : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "github")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let linkedin : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedin")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let twitter : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "twitter")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let instagram : UIButton = {
        let btn  = UIButton(type: .system)
        btn.setImage(UIImage(named: "ig")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
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
        filterView.anchor(top: stackSocial.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width, heigth: 40)
        addSubview(underLine)
        underLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width / 3, heigth: 2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
