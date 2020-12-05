//
//  ChooseHastagCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class ChooseHastagCell: UITableViewCell {

    
    var name : String?{
        didSet{
            configure()
        }
    }
    
    let clupName : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 13)
        lbl.textColor = .black
        return lbl
    }()
    let rigthArrow : UIImageView = {
       let img = UIImageView()
        img.image = UIImage(named: "rigth-arrow")?.withRenderingMode(.alwaysOriginal)
        img.contentMode = .scaleAspectFit
        return img
    }()
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(clupName)
        clupName.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        clupName.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(rigthArrow)
        rigthArrow.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 15, heigth: 15)
        rigthArrow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func configure(){
        guard let name = name else { return }
        clupName.text = name
    }

}
