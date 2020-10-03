//
//  ActionSheetCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class ActionSheetCell: UITableViewCell {

    var options : ActionSheetOptions?{
        didSet{
            configure()
        }
    }
    var notificationOption : NotificationOptions?{
        didSet{
            configureNotificaiton()
        }
    }
    
    private let logo : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    private let titleLabel : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(logo)
        logo.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 25, heigth: 25)
         logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: logo.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(){
        titleLabel.text = options?.description
        logo.image = options?.image
    }
    func configureNotificaiton(){
        titleLabel.text = notificationOption?.descriptions
        logo.image = notificationOption?.image
    }
  

}
