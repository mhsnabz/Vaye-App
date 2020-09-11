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
          btn.setImage(UIImage(named: "down-arrow"), for: .normal)
          
          return btn
      }()
      lazy var headerBar : UIView = {
         let v = UIView()
        v.backgroundColor = .white
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
        
        view.addSubview(headerBar)
        headerBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 56)
        
           let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
           layout.scrollDirection = .horizontal
           collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
           collectionview.dataSource = self
           collectionview.delegate = self
           collectionview.backgroundColor = .white
           view.addSubview(collectionview)
        collectionview.anchor(top: headerBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
            collectionview.register(DataViewImageCell.self, forCellWithReuseIdentifier: img_cell)
       }
    

}
extension DataVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DataUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImageCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
}
