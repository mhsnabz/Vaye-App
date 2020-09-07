//
//  LessonInfoHeaderTwo.swift
//  
//
//  Created by mahsun abuzeyitoğlu on 7.09.2020.
//

import UIKit

class LessonInfoHeaderTwo: UICollectionViewCell {
       lazy var headerTwo : UIView = {
            let view = UIView()
            view.addSubview(label_header_two)
            label_header_two.anchor(top: view.topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
           
            label_header_two.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            view.addSubview(fallowerLbl)
            fallowerLbl.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12,marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
    //        view.addSubview(line)
    //        line.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.3)
            return view
                
        }()
        let fallowerLbl : UILabel = {
               let lbl = UILabel()
               lbl.font = UIFont(name: Utilities.font, size: 12)
               lbl.textColor = .lightGray
               lbl.textAlignment = .left
               lbl.text = "Dersi Takip Edenler"
               return lbl
           }()
    let label_header_two : UILabel = {
          let lbl = UILabel()
          lbl.font = UIFont(name: Utilities.fontBold, size: 15)
          lbl.text = "Bu Ders Kayıtlı Eğitmen Yok"
          return lbl
      }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerTwo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
