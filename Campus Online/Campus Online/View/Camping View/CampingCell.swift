//
//  CampingCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class CampingCell: UICollectionViewCell {
    weak var delegate: DeleteImageCampingCell?
    
    var data : FoodMeModel?{
        didSet{
            guard let data = data else { return }
            img.image = UIImage(data: data.data)
        }
    }
    
    let deleteBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let img : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = UIColor(white: 0.90, alpha: 0.7)
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(img)
        img.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        addSubview(deleteBtn)
        deleteBtn.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        deleteBtn.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func deleteImage(){
    delegate?.deleteImage(for: self)
    }
}
