//
//  ProfileFilterCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    
    
    var option : String!{
        didSet {
            titleLlb.text = option
        }
    }
    private let underLine : UIView = {
       let view = UIView()
        view.backgroundColor = .black
        return view
    }()
   
  
    let titleLlb : UILabel = {
    let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.font = UIFont(name: Utilities.font, size: 14)
        
        return lbl
    }()
   
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                titleLlb.font = UIFont(name: Utilities.fontBold, size: 14)
                titleLlb.textColor = .black
            }else{
                titleLlb.font = UIFont(name: Utilities.font, size: 12)
                titleLlb.textColor = .lightGray
            }       
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(titleLlb)
        titleLlb.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLlb.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLlb.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
