//
//  HomeMenuCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class HomeMenuCell: UITableViewCell {

    var delegate : SlideMenuDelegate?
    
   let homeBtn : UIButton = {
          let btn = UIButton(type: .system)
          return btn
      }()
      
      let homeTitle : UIButton = {
          let btn = UIButton(type: .system)
          btn.tintColor = .black
          btn.titleLabel?.textColor = .black
          btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
          return btn
      }()
     let line : UIView = {
          let v = UIView()
           v.backgroundColor = .darkGray
           return v
       }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        
        
        addSubview(homeBtn)
        homeBtn.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 35, heigth: 35)
        homeBtn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(homeTitle)
        homeTitle.anchor(top: nil, left: homeBtn.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        homeTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 32, marginBottom: 1, marginRigth: 112, width: 0, heigth: 0.5)
        line.isHidden = true
        
        homeBtn.addTarget(self, action: #selector(homeBtnClick), for: .touchUpInside)
        homeTitle.addTarget(self, action: #selector(homeBtnClick), for: .touchUpInside)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func homeBtnClick()
    {
        delegate!.handleSlideMenuItems(for : self)
    }
  

}
