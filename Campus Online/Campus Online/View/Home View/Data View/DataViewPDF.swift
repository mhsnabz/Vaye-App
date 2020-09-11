//
//  DataViewPDF.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 12.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import PDFKit
class DataViewPDF: UICollectionViewCell {
    var url : String?{
        didSet{
            if let url = URL(string: url!), let document = PDFDocument(url: url) {
                pdfView.document = document
            }
        }
    }
    let pdfView : PDFView = {
        let pdf = PDFView()
        pdf.displayMode = .singlePageContinuous
        pdf.autoScales = true
        pdf.displayDirection = .vertical
        
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
