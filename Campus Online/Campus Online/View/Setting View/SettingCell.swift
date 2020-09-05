//
//  SettingCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    let img : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    let lbl : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 15)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(img)
        img.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 40, heigth: 40)
        img.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(lbl)
        lbl.anchor(top: nil, left: img.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        lbl.centerYAnchor.constraint(equalTo: img.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
