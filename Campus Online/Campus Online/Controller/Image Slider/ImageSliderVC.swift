//
//  ImageSliderVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let img_cell = "img_cell"
class ImageSliderVC: UIViewController {
    //MARK:- variables
    var DataUrl : [String]?{
        didSet{
            if DataUrl != nil  {
                if collectionview != nil  {
                    collectionview.reloadData()
                }

            }
        }
    }
    var collectionview: UICollectionView!
    lazy var cancelButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
     
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(hole(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeLeft)

    }
    @objc  func hole(_ recognizer: UISwipeGestureRecognizer) {
        if (recognizer.direction == UISwipeGestureRecognizer.Direction.left)
        {
          
        
        }else if recognizer.direction == .right {
           
            
        }else if recognizer.direction == .down  {
            self.dismiss(animated: true, completion: nil)
        }
    }
  
 
    //MARK:- functions
    fileprivate func configureCollectionView() {
  
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .black
        collectionview.isPagingEnabled = true
        view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collectionview.register(DataViewImage.self, forCellWithReuseIdentifier: img_cell)
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        cancelButton.addTarget(self, action: #selector(dismisVC), for: .touchUpInside)
        
        
    }
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }

}
extension ImageSliderVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataUrl?.count ?? 0
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImage
        cell.url = DataUrl?[indexPath.row]
            return cell
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
