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
    var times : Int = 0
    var friendListModel = [FriendListModel]()
    var currentUser : CurrentUser?{
        didSet{
            if  times == 0 {
                checkFirendList()
                times += 1
            }
        }
    }
    weak var snapShotListener : ListenerRegistration?
   
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
        collectionview.backgroundColor = .white
        addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom:bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(FiriendListItem.self, forCellWithReuseIdentifier: cellId)

    
    }
 
    
      func checkFirendList(){
        guard let currentUser = currentUser else { return }
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("friend-list").order(by: "tarih",descending: true)
        snapShotListener = db.addSnapshotListener( { [weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard  let snap = querySnap  else {
                    return
                }
                for item in snap.documentChanges {
                    if item.type == .added {
                        sself.friendListModel.append(FriendListModel.init(dic: item.document.data()))
                        sself.friendListModel.sort { (list1, list2) -> Bool in
                            return list1.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970 > list2.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970
                        }
                        sself.collectionview.reloadData()
                    }else if item.type == .modified{
                        for user in sself.friendListModel {
                            if user.uid == item.document.documentID {
                                let index = sself.friendListModel.firstIndex{ $0.uid == item.document.documentID}
                                if let index = index {
                                    sself.friendListModel[index] = FriendListModel.init(dic: item.document.data())
                                }
                            }
                        }
                        sself.friendListModel.sort { (list1, list2) -> Bool in
                            return list1.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970 > list2.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970
                        }
                        sself.collectionview.reloadData()
                    }else if item.type == .removed {
                        let index = sself.friendListModel.firstIndex{ $0.uid == item.document.documentID}
                        if let index = index {
                            sself.friendListModel.remove(at: index)
                            sself.collectionview.reloadData()
                        }
                        sself.friendListModel.sort { (list1, list2) -> Bool in
                            return list1.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970 > list2.tarih?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970
                        }
                        sself.collectionview.reloadData()
                        
                    }
                }
            }
        })
      }
   
    
    
}
extension FriendListCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return friendListModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FiriendListItem

            cell.user = friendListModel[indexPath.row]
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        Utilities.waitProgress(msg: nil)
        UserService.shared.getOtherUser(userId: friendListModel[indexPath.row].uid) { (user) in
          
            UserService.shared.getCurrentUser(uid: currentUser.uid) { (current) in
                let vc = ConservationVC(currentUser: current, otherUser: user)
                self.rootController?.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
            }
            
        }
       
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 70)
    }
    
    
}
