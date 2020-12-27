//
//  FriendListCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
private let cellId = "cell"
class FriendListCell: UICollectionViewCell
{
    
    var currentUser : CurrentUser?{
        didSet{
            guard let user = currentUser else { return }
            friendListModel = [FriendListModel]()
            MessagesService.shared.getFriendList(currentUser: user) {[weak self] (list) in
                guard let sself = self else { return }
                for item in list{
                    sself.friendListModel.append(item)
                    sself.collectionview.reloadData()
                }
             
       
            }
        }
    }
    lazy var friendListModel = [FriendListModel]()
    var collectionview: UICollectionView!
    weak var rootController : MessagesVC?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private func configureUI(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom:bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(FiriendListItem.self, forCellWithReuseIdentifier: cellId)
    }
    
    
}
extension FriendListCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(friendListModel.count)
        return friendListModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FiriendListItem
        cell.user = friendListModel[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 70)
    }
    
    
}
