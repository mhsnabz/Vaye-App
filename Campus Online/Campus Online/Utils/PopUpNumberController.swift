//
//  PopUpNumberController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 16.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import TweeTextField
class PopUpNumberController : UIView {
    // MARK: - Properties
  
    var showSuccessMessage: Bool?
    var values : String?
    weak var delegate : PopUpNumberDelegate?
    let value : TweeAttributedTextField = {
         let txt = TweeAttributedTextField()
         txt.placeholder = "Fiyat Giriniz"
         txt.font = UIFont(name: Utilities.font, size: 14)!
         txt.activeLineColor =   UIColor.mainColor()
         txt.lineColor = .lightGray
         txt.textAlignment = .left
         txt.activeLineWidth = 1.5
         txt.animationDuration = 0.7
         txt.infoFontSize = UIFont.smallSystemFontSize
         txt.infoTextColor = .red
         txt.infoAnimationDuration = 0.4
         txt.textContentType = .telephoneNumber
         txt.autocorrectionType = .no
         txt.autocapitalizationType = .none
         txt.returnKeyType = .continue
         txt.textAlignment = .center
         
         return txt
     }()
  
  
   
    let   btnAdd : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ekle", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.setBackgroundColor(color: .lightRed, forState: .normal)
        btn.setTitleColor(.white, for: .normal)
     
        return btn
    }()
    let btnCancel : UIButton = {
         let btn = UIButton(type: .system)
         btn.setTitle("Vazgeç", for: .normal)
         btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
         btn.clipsToBounds = true
         btn.layer.cornerRadius = 5
         btn.setBackgroundColor(color: .mainColor(), forState: .normal)
         btn.setTitleColor(.white, for: .normal)
      
         return btn
     }()
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        configure()
   
        
    }
  
    private func configure(){
        
    
        addSubview(value)
        
        value.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 40, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 50)
        
      
        let stack = UIStackView(arrangedSubviews: [btnCancel,btnAdd])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.anchor(top: value.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 20, marginBottom: 0, marginRigth: 20, width: 0, heigth: 35)
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        btnCancel.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        btnAdd.addTarget(self, action: #selector(addValues), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal()
    {
        delegate?.handleDismissal()
        
    }
    @objc func addValues(){
        guard let value = values else { return }
        delegate?.addValue(value)
    }
}

