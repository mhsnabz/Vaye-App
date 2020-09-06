//
//  LicenceCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class LicenceCell: UITableViewCell {

       
    let name : UILabel = {
    let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.textColor = .black
        return lbl
    }()
    let arrow : UIImageView = {
    let img = UIImageView()
        img.image = #imageLiteral(resourceName: "rigth-arrow")
        return img
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
        
        addSubview(name)
        name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        name.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        addSubview(arrow)
        arrow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrow.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 8, width: 12, heigth: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
