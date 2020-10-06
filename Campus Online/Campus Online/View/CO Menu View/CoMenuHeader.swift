//
//  CoMenuHeader.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class CoMenuHeader: UITableViewHeaderFooterView {

    weak var delegate : CoSlideHeaderDelegate?
    let backBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        btn.setImage(#imageLiteral(resourceName: "cancel-dark").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    static let reuseIdentifier: String = String(describing: self)
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        addSubview(backBtn)
        backBtn.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 88, width: 25, heigth: 25)
        backBtn.addTarget(self, action: #selector(dismisMenu), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismisMenu(){
        delegate!.dismisMenu()
    }
}
