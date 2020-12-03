//
//  SchoolPostCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class SchoolPostCell: UICollectionViewCell {
    var collectionview: UICollectionView!
    weak var delegate : didScroolDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        configureCollecitionView()
        
    }
    
    
    
    //MARK:-func
    func configureCollecitionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.backgroundColor = .white
        collectionview.register(FoodMeCell.self, forCellWithReuseIdentifier: "id")

        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .red
        addSubview(collectionview)
        collectionview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        delegate?.scrollingTo(point: scrollView.contentOffset.y)
    }
}
extension SchoolPostCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! FoodMeCell
        cell.backgroundColor = .gray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 100)
    }
    
    
}
