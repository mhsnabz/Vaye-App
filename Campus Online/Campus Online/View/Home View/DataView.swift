//
//  DataView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import MobileCoreServices
private let pdf = "pdf_cell"
private let doc = "doc_cell"
private let img = "img_cell"



enum DataViewEnum{
    case homePost
    case mainPost
   
    var description : String {
        switch self {
    
        case .homePost:
            return "homePost"
        case .mainPost:
            return "mainPost"
        }}
   
}

class DataView : UIView {
    
    var datasUrl : [String]?
    var arrayOfUrl : [String]?{
        didSet{
                
        }
    }
    deinit {
        print("deninit horizantal collectionview")
    }
    lazy var collectionView : UICollectionView = {
    let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           backgroundColor = .white

           collectionView.register(DataViewImageCell.self, forCellWithReuseIdentifier: img)
            collectionView.register(DataViewPdfCell.self, forCellWithReuseIdentifier: pdf)
            collectionView.register(DataViewDocCell.self, forCellWithReuseIdentifier: doc)
           addSubview(collectionView)
           collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width, heigth: frame.height)

       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}
extension DataView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let size = arrayOfUrl else { return 0}
        return size.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if URL(string: (arrayOfUrl?[indexPath.row])!)!.mimeType() == "image/jpeg"{
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img, for: indexPath) as! DataViewImageCell
            cell.url = arrayOfUrl![indexPath.row]
            cell.delegate = self
            return cell
        
        }else if URL(string: (arrayOfUrl?[indexPath.row])!)!.mimeType() == DataTypes.pdf.contentType{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdf, for: indexPath) as! DataViewPdfCell
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: doc, for: indexPath) as! DataViewDocCell
            return cell
        }
        
      }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.width / 3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        cell.removeFromSuperview()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = datasUrl else { return }
        let vc = DataVC(dataUrl: url)
        
        let currentController = self.getCurrentViewController()
        vc.modalPresentationStyle = .fullScreen
        
        currentController?.present(vc, animated: true, completion: nil)
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil

    }
}

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsPdf: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypePDF)
    }
    var constainVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, "[com.microsoft.word.doc]" as CFString)
    }

}

extension DataView : DataViewClick {
    func pdfClick(for cell: DataViewPdfCell) {
        print("click 2")
    }
    
    func imageClik(for cell: DataViewImageCell) {
        print("image click")
    }
    
    
}
