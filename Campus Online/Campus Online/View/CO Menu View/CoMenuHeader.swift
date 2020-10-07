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
        btn.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let logo : UIImageView = {
        let image = UIImageView()
   
        image.image = #imageLiteral(resourceName: "logo").withRenderingMode(.alwaysOriginal)
        
        return image
    }()
    
    lazy var header : UIView = {
       let v = UIView()

        v.addSubview(logo)
        logo.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0 , marginBottom: 0, marginRigth: 0, width: 75, heigth: 75)
        logo.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        return v
    }()
    
    static let reuseIdentifier: String = String(describing: self)
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        addSubview(backBtn)
        backBtn.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 88, width: 25, heigth: 25)
        backBtn.addTarget(self, action: #selector(dismisMenu), for: .touchUpInside)
        
        addSubview(header)
        header.anchor(top: backBtn.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 9, marginLeft: 0, marginBottom: 0, marginRigth: 80, width: 0, heigth: 0)
  
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismisMenu(){
        delegate!.dismisMenu()
    }
}
