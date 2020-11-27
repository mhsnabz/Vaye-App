//
//  MenuBar.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

protocol didSelectMenuBarItem : class {
    func didSelec(_ index : IndexPath)
}
class MenuBar : UIView , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UICollectionViewDelegate {
    
    

    var barLeftAnchor: NSLayoutConstraint?{
        didSet {
            guard let constant = barLeftAnchor?.constant else { return }
            scrollMenuItem( point: constant)
        }
    }
    
    
     weak var delegate : didSelectMenuBarItem?
    
    //MARK:-properites
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: "id")
        let index = IndexPath(item: 0, section: 0)

        collectionView.selectItem(at: index, animated: false, scrollPosition: .left)
        setupHorizantalVar()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHorizantalVar(){
        let horizantalBarView = UIView()
        horizantalBarView.backgroundColor = .black
        horizantalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizantalBarView)
        barLeftAnchor =  horizantalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        barLeftAnchor?.isActive = true
        horizantalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizantalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
        horizantalBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ProfileFilterCell
        cell.option = "Deneme"

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelec(indexPath)
        let x = CGFloat(indexPath.item ) * frame.width / 3
        barLeftAnchor?.constant = x
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)

        guard let constant = barLeftAnchor?.constant else { return }
        scrollMenuItem( point: constant)
    }
    func scrollMenuItem(point : CGFloat){
//        let x = CGFloat(indexPath.item ) * frame.width / 3
        barLeftAnchor?.constant = point
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
