//
//  CaptionText.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class CaptionText : UITextView {
    let pleaceHolder : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .lightGray
        lbl.text = "Bişeyler Yazın..."
        return lbl
    }()
    
//    MARK:- lifeCycle
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addSubview(pleaceHolder)
        pleaceHolder.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handeTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func handeTextDidChange(){
        pleaceHolder.isHidden = !text.isEmpty
    }
}
