//
//  LessonCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class LessonCell: UITableViewCell {

    
 
   
    weak var delegate : ActionSheetLauncherDelegate?
    //MARK:-init
    
    let lessonName : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        lbl.text = "lesson name"
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    let fallowerLabel : UILabel = {
           let lbl = UILabel()
           lbl.font = UIFont(name: Utilities.font, size: 11)
           lbl.text = "Takipçi"
           lbl.textColor = .darkGray
        lbl.isUserInteractionEnabled = true

           return lbl
       }()
       let fallowerNumber : UILabel = {
           let lbl = UILabel()
           lbl.font = UIFont(name: Utilities.font, size: 11)
           lbl.text = "..."
           lbl.textColor = .black
        lbl.isUserInteractionEnabled = true

           return lbl
       }()
    
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    let mark : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.backgroundColor = .lightText
        img.isUserInteractionEnabled = true

        return img
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
   
        
        let stackFallow = UIStackView(arrangedSubviews: [fallowerNumber,fallowerLabel])
            stackFallow.axis = .horizontal
            stackFallow.spacing = 6
            stackFallow.alignment = .leading
   
        addSubview(lessonName)
        lessonName.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 12, marginBottom: 4, marginRigth: 0, width: 0, heigth: 17)
        addSubview(stackFallow)
        stackFallow.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 4, marginRigth: 0, width: 0, heigth: 14)
        
           addSubview(mark)
           mark.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 25, heigth: 25)
           mark.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mark.layer.cornerRadius = 25 / 2
//        lessonName.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(selectRow)))
        
        
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
