//
//  HomePostCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

protocol didScroolDelegate : class {
    func scrollingTo(point : CGFloat)
}
class HomePostCell: UICollectionViewCell {
    var collectionview: UICollectionView!
    weak var delegate : didScroolDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
    
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
        collectionview.contentInset = UIEdgeInsets(top: 285, left: 0, bottom: 0, right: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        delegate?.scrollingTo(point: scrollView.contentOffset.y)
    }
}
extension HomePostCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
