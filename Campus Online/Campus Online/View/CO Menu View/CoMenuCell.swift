//
//  CoMenuCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class CoMenuCell: UITableViewCell {
    static let reuseIdentifier: String = String(describing: self)
    weak var delegate : CoSlideMenuDelegate?
    let homeBtn : UIButton = {
           let btn = UIButton(type: .system)
        btn.imageView?.contentMode = .scaleAspectFit
           return btn
       }()
       
       let homeTitle : UIButton = {
           let btn = UIButton(type: .system)
           btn.tintColor = .black
           btn.titleLabel?.textColor = .black
           btn.titleLabel?.font = UIFont(name: Utilities.font, size: 17)
           return btn
       }()
      let line : UIView = {
           let v = UIView()
            v.backgroundColor = .collectionColor()
            return v
        }()
     
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: CoMenuCell.reuseIdentifier)
        
        addSubview(homeBtn)
        homeBtn.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 10, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 80, heigth: 80)
        homeBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        
        addSubview(homeTitle)
        homeTitle.anchor(top: homeBtn.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 5, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 20)
//
        homeTitle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 10, marginBottom: 1, marginRigth: 10, width: 0, heigth: 1)
        
        homeBtn.addTarget(self, action: #selector(homeBtnClick), for: .touchUpInside)
//        homeTitle.addTarget(self, action: #selector(homeBtnClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func homeBtnClick()
    {
        delegate!.handleSlideMenuItems(for : self)
    }
}
