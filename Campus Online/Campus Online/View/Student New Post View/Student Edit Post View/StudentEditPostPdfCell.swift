//
//  StudentEditPostPdfCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import PDFKit
class StudentEditPostPdfCell: UICollectionViewCell {
  weak var delegate: EditStudentPostDelegate?
    var url : String?
    let deleteBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
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
            addSubview(deleteBtn)
                   deleteBtn.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
            deleteBtn.addTarget(self, action: #selector(deletePdf), for: .touchUpInside)
         }
         
         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    @objc func deletePdf(){
        delegate?.deletePdf(for: self)
    }
}
