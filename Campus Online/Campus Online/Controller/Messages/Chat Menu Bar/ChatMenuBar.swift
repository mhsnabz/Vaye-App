//
//  ChatMenuBar.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
class ChatMenuBar : UIView , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UICollectionViewDelegate{
    weak var delegate : HomeMenuBarSelectedIndex?
    weak var homeController : MessagesVC?
    var horizontalBarLeftConstarint : NSLayoutConstraint?
    let indexPath = IndexPath(row: 0, section: 0)
    let indexPathRequest = IndexPath(row: 2, section: 0)
    var requestBadgeCount : Int?{
        didSet{
            let cell = collecitonView.cellForItem(at: indexPathRequest) as! HomeMenu_Cell

            guard let badge = requestBadgeCount else {
                cell.badgeCount.isHidden = true
                return
            }
            
            cell.badgeCount.isHidden = false
            cell.badgeCount.text = badge.description
        }
    }
    var msgBadgeCount : Int?{
        didSet{
            let cell = collecitonView.cellForItem(at: indexPath) as! HomeMenu_Cell

            guard let badge = msgBadgeCount else {
                cell.badgeCount.isHidden = true
                return
            }
            
            cell.badgeCount.isHidden = false
            cell.badgeCount.text = badge.description
        }
    }
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collecitonView)
        collecitonView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collecitonView.register(HomeMenu_Cell.self, forCellWithReuseIdentifier: "cell")
        let selecteIndex = IndexPath(item: 0, section: 0)
        collecitonView.selectItem(at: selecteIndex, animated: false, scrollPosition: .left)
        setUpHorizantalBar()
        delegate?.getIndex(indexItem: 0)
    }
    //MARK:--funcitons
    func setUpHorizantalBar(){
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = .black
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
       
        horizontalBarLeftConstarint =  horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftConstarint?.isActive = true
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeMenu_Cell
        if indexPath.item == 0 {
            cell.lbl.text = "Sohbetler"
            if let count = msgBadgeCount {
                if count > 0 {
                    cell.badgeCount.isHidden = false
                    cell.badgeCount.text = count.description
                }else{
                    cell.badgeCount.isHidden = true
                    
                }
            }
        }else if indexPath.item == 1 {
            cell.lbl.text = "Arkadaşlar"
            cell.badgeCount.isHidden = true
        }else if indexPath.item == 2{
            cell.lbl.text = "Sohbet İstekleri"
            if let count = requestBadgeCount {
                if count > 0 {
                    cell.badgeCount.isHidden = false
                    cell.badgeCount.text = count.description
                }else{
                    cell.badgeCount.isHidden = true
                    
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.getIndex(indexItem: indexPath.item)
       homeController?.scrollToIndex(menuIndex: indexPath.item)
    }
}
class HomeMenu_Cell : UICollectionViewCell {
    
    let lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.textColor = .lightGray

        return lbl
    }()
    lazy var badgeCount : UILabel = {
        let lbl = UILabel()
        lbl.clipsToBounds = true
        lbl.backgroundColor = .red
        lbl.textColor = .white
        lbl.font = UIFont(name: Utilities.fontBold, size: 10)
        lbl.layer.cornerRadius = 15 / 2

        lbl.textAlignment = .center
        return lbl
    }()
    override var isSelected: Bool{
        didSet{
            if isSelected {
                lbl.font = UIFont(name: Utilities.fontBold, size: 13)
                lbl.textColor = .black
            }else{
                lbl.font = UIFont(name: Utilities.font, size: 11)
                lbl.textColor = .lightGray
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lbl)
        badgeCount.isHidden = true
        addSubview(badgeCount)
        badgeCount.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 6, marginBottom: 0, marginRigth: 0, width: 15, heigth: 15)
        badgeCount.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        lbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
