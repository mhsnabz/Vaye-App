//
//  MapKitPermissonVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 9.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
class MapKitPermissonVC: UIViewController {
    var waitAnimation = AnimationView()
    let lbl : UILabel = {
       let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    lazy var text : NSMutableAttributedString = {
       let text = NSMutableAttributedString()
        return text
    }()
    let accept : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        btn.setTitle("İzin Ver", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 16)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
        
    }()
    let denied : UIButton = {
        let btn = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        btn.setTitle("Vazgeç", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 16)
        btn.setBackgroundColor(color: .mainColorTransparent(), forState: .normal)
        return btn
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        waitAnimation = .init(name : "location-pin")
        waitAnimation.animationSpeed = 1
        waitAnimation.contentMode = .scaleAspectFill
        waitAnimation.loopMode = .loop
        
        view.addSubview(waitAnimation)
        waitAnimation.anchor(top: view.topAnchor , left: nil, bottom: nil, rigth: nil, marginTop: 100, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 200, heigth: 200)
        waitAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waitAnimation.play()
        text =  NSMutableAttributedString(string: "Konum Servislerini Aç\n\n", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.font, size: 15)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        text.append(NSAttributedString(string: " Eklemek İstediğiniz Konuma Erişebilmemiz İçin İzin Vermeniz Gerekiyor ", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 13)!, NSAttributedString.Key.foregroundColor : UIColor.lightGray ]))
        lbl.attributedText = text
        view.addSubview(lbl)
        lbl.anchor(top: waitAnimation.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 0)
        
        view.addSubview(accept)
        accept.anchor(top: lbl.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 40, marginBottom: 0, marginRigth: 40, width: 0, heigth: 50)
        view.addSubview(denied)
        denied.anchor(top: accept.bottomAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 20, marginLeft: 60, marginBottom: 0, marginRigth: 60, width: 0, heigth: 40)

    }
    
}
