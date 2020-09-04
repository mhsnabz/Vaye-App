//
//  AddUserCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 4.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class AddUserCell: UITableViewCell {

    let img : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.borderWidth = 0.4
        return img
    }()
    let name : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.text = "Mahsun Abuzeyitoğlu"
        return lbl
    }()
    let userName : UILabel = {
           let lbl = UILabel()
           lbl.textColor = .lightGray
           lbl.font = UIFont(name: Utilities.font, size: 12)
           lbl.text = "@mhsnabz"
           return lbl
       }()
    override func awakeFromNib()
    {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(img)
        img.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
        img.layer.cornerRadius = 45 / 2
        img.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let stac = UIStackView(arrangedSubviews: [name,userName])
        stac.axis = .vertical
        stac.spacing = 4
        stac.distribution = .fillEqually
        stac.alignment = .leading
        
        addSubview(stac)
        stac.anchor(top: nil, left: img.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        stac.centerYAnchor.constraint(equalTo: img.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
