//
//  DataVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let pdf_cell = "pdfCell"
private let img_cell = "imgCell"
private let doc_cell = "docCell"
class DataVC: UIViewController {
    //MARK:- properites

    let titleLbl : UILabel = {
         let lbl = UILabel()
          lbl.text = "..."
          lbl.font = UIFont(name: Utilities.font, size: 15)
          lbl.textColor = .black
          return lbl
      }()
      let dissmisButton : UIButton = {
          let btn = UIButton()
         btn.setImage(#imageLiteral(resourceName: "x").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.tintColor = .white
          return btn
      }()
      lazy var headerBar : UIView = {
         let v = UIView()
        v.backgroundColor =  .black
          v.addSubview(dissmisButton)
          dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
          dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
          v.addSubview(titleLbl)
          titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
          titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
            titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
          
          return v
      }()
    //MARK:- variables
      var DataUrl = [String]()
      var collectionview: UICollectionView!
    //MARK:- lifeCycle
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureCollectionView()
        dissmisButton.addTarget(self, action: #selector(dismisVC), for: .touchUpInside)
        
    }
      override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
      }
        
    init(dataUrl : [String]){
        self.DataUrl = dataUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- selectors
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- functions
    fileprivate func configureCollectionView() {
        
 
        
           let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
           layout.scrollDirection = .horizontal
           collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
           collectionview.dataSource = self
           collectionview.delegate = self
           collectionview.backgroundColor = .white
           collectionview.isPagingEnabled = true
           view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
            collectionview.register(DataViewImage.self, forCellWithReuseIdentifier: img_cell)
            collectionview.register(DataViewPDF.self, forCellWithReuseIdentifier: pdf_cell)
        
        
        view.addSubview(dissmisButton)
         dissmisButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 15, marginLeft: 15, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
       }
    

}
extension DataVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return DataUrl.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      //  \(URL(string: item)?.mimeType())
        if URL(string: DataUrl[indexPath.row])!.mimeType() == "image/jpeg" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImage
            cell.url = DataUrl[indexPath.row]
            return cell
        }else if  URL(string: DataUrl[indexPath.row])!.mimeType() == "application/pdf" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdf_cell, for: indexPath) as! DataViewPDF
            cell.url = DataUrl[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImage
            cell.url = DataUrl[indexPath.row]
            return cell
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
