//
//  ImageDataView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
import MobileCoreServices


private let img = "img_cell"
struct Datas {

    var thumbImages : [String]!
    var images : [String]!
    
}
class ImageDataView : UIView , UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, DataViewClick{
    
  
    var datasUrl : [String]?
    var arrayOfUrl : [String]?{
        didSet{
                
        }
    }
    deinit {
        print("deninit horizantal collectionview")
    }
    
    func imageClik(for cell: DataViewImageCell) {
        
    }
    
    func pdfClick(for cell: DataViewPdfCell) {
        
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
           
           addSubview(collectionView)
           collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width, heigth: frame.height)

       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let size = arrayOfUrl else { return 0}
        return size.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img, for: indexPath) as! DataViewImageCell
        
        cell.url = arrayOfUrl![indexPath.row]

        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width / 3, height: frame.width / 3)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = datasUrl else { return }
        let vc = ImageSliderVC()
        vc.DataUrl = url
        
        let currentController = self.getCurrentViewController()
        vc.modalPresentationStyle = .fullScreen
        
        currentController?.present(vc, animated: true, completion: nil)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.4
    }
}

