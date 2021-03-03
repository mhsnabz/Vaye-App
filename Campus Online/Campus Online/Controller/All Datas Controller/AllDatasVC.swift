//
//  AllDatasVC.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 3.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let img_cell = "img_cell"
private let doc_cell = "doc_cell"
class AllDatasVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayListUrl.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        if arrayListUrl[indexPath.row].contains("pdf") || arrayListUrl[indexPath.row].contains("doc") || arrayListUrl[indexPath.row].contains("docx") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: doc_cell, for: indexPath) as! DataViewDocument
            cell.url = arrayListUrl[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImage
        cell.url = arrayListUrl[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    var arrayListUrl : [String]
    var currentUser : CurrentUser
    var collectionview: UICollectionView!
    var dismissButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
      
        configureCollectionView()
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        dismissButton.addTarget(self, action: #selector(dissmisVC), for: .touchUpInside)

    }
    init(arrayListUrl : [String] , currentUser : CurrentUser) {
        self.arrayListUrl = arrayListUrl
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    @objc func dissmisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        collectionview.register(DataViewDocument.self, forCellWithReuseIdentifier: doc_cell)
      
    }
  

}
