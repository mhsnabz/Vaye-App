//
//  DataViewDoc.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 12.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import WebKit
class DataViewDoc: UICollectionViewCell {
    var url : String?{
           didSet{
            guard let url = url else { return }
            let urls = URL(string: url)
            let request = URLRequest(url: urls!)
            pdfView.load(request)
           }
       }
       lazy var pdfView : WKWebView = {
           let pdf = WKWebView()
           return pdf
       }()
       override init(frame: CGRect) {
           super.init(frame: frame)
           addSubview(pdfView)
           pdfView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
       
           
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}
