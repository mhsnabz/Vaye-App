//
//  DataViewDocuement.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 3.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class DataViewDocument: UICollectionViewCell {
    
    var url : String?
    lazy var btn : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.setBackgroundColor(color: .white, forState: .normal)
        btn.setTitle("Dosyayı Görüntüle", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        
        return btn
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(btn)
        btn.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 200, heigth: 40)
        btn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        btn.addTarget(self, action: #selector(showDocument), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func showDocument(){
        guard let urlString = url else { return }
        guard let url = URL(string: urlString) else {
            return }
        UIApplication.shared.open(url)
    }
}
