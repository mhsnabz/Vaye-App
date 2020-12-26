//
//  SingleStudentCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class SingleStudentCell: UITableViewCell {

    weak var user : OtherUser?{
        didSet{
            configure()
        }
    }
    
    lazy var profileImage : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.5
        img.layer.borderColor = UIColor.darkGray.cgColor
        return img
    }()
    lazy  var name : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    let studentName : UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    let studentNumber : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(profileImage)
        profileImage.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 50, heigth: 50)
        profileImage.layer.cornerRadius = 50 / 2
        
        let stack = UIStackView(arrangedSubviews: [studentName , studentNumber])
        stack.axis = .vertical
        addSubview(stack)
        stack.anchor(top: nil, left: profileImage.rightAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 40)
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  configure(){
        guard let user = user else { return }
        name = NSMutableAttributedString(string: user.name, attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(user.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 14)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        studentName.attributedText = name
        studentNumber.text = user.number
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string: user.thumb_image))
    }

}
