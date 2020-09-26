//
//  OtherUserProfileFilterView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class OtherUserProfileFilterView : UIView{
    weak var delegate : ProfileFilterDelegate?
    weak var filterDelagate : UserProfileFilterDelegate?
   weak var option : OtherUserFilterVM!
    weak var otherUser : OtherUser!
    weak var currentUser : CurrentUser!
     var helps : helps? {
        didSet{
      
                guard let option = helps else {return}
            self.option = option.option
            self.currentUser = option.currentUser
            self.otherUser = option.otherUser
                self.collectionView.reloadData()
            
        }
    }
   
   
    
    lazy var collectionView : UICollectionView = {
    let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    override init(frame: CGRect ) {
        super.init(frame: frame )
      
        backgroundColor = .white
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: "id")
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func getShortMajor(major : String) ->String {
        var shortName  : String = ""
        let bolumName = major.components(separatedBy: " ")
        for item in bolumName {
            shortName += item[0].string
        }
        return shortName
    }
}
extension OtherUserProfileFilterView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return option?.options.count ?? 0
     
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ProfileFilterCell

        if let option = option {
        
            if option.options[indexPath.row].descprition == "bolum"{
                cell.option = getShortMajor(major: currentUser.bolum)
            }else if option.options[indexPath.row].descprition == "school"{
                cell.option = otherUser!.short_school
            }else if option.options[indexPath.row].descprition == "online_campus"{
                cell.option = "Co"
            }else if option.options[indexPath.row].descprition == "fav"{
                cell.option = "Favoriler"
            }
          
            return cell
        }else{
            return cell
        }
       
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        delegate?.ShowFilterUnderLine(self, didSelect: indexPath)
        filterDelagate?.didSelectOption(option: option!.options[indexPath.row])
    }
    
    
  
}
