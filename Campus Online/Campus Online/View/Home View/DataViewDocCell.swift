//
//  DataViewDocCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class DataViewDocCell: UICollectionViewCell {
   
     let img : UIImageView = {
         let img = UIImageView()
          img.contentMode = .scaleToFill
          img.backgroundColor = .white
          img.image = UIImage(named: "doc-holder")
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
