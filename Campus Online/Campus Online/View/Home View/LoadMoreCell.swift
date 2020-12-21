//
//  LoadMoreCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 18.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
class LoadMoreCell: UICollectionViewCell
{
    let activityView = UIActivityIndicatorView(style: .gray)
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityView)
        activityView.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
