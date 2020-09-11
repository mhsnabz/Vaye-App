//
//  DataViewCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class DataViewImageCell: UICollectionViewCell
{
    var url : String?{
        didSet{
            guard let url = url else { return }
            img.sd_imageIndicator = SDWebImageActivityIndicator.white
            img.sd_setImage(with: URL(string: url))
        }
    }
    let img : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = UIColor(white: 0.90, alpha: 0.7)
        img.clipsToBounds = true
        img.layer.cornerRadius = 10
        
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(img)
        img.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)  
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
