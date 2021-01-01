//
//  RequestCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore

import SDWebImage
class RequestCell: UICollectionViewCell {
    var rootController : MessagesVC?
    var times : Int = 0
    var list = [ChatListModel]()
    var collectionview: UICollectionView!
    weak var snapShotListener : ListenerRegistration?
    weak var currentUser : CurrentUser?{
        didSet{
            if  times == 0 {
                getMessagesList()
                times += 1

            }
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getMessagesList(){
        guard let currentUser = currentUser else { return }
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("msg-request").order(by: "time",descending: true)
        snapShotListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            guard let sself = self else { return }
            if err == nil {
                guard let snap = querySnap else { return }
                for item in snap.documentChanges{
                    if item.type == .added {
                        sself.list.append(ChatListModel.init(uid : item.document.documentID,dic: item.document.data()))
                        sself.collectionview.reloadData()
                    }else if item.type == .modified{
                        for user in sself.list{
                            if user.uid == item.document.documentID {
                                let index = sself.list.firstIndex{ $0.uid == item.document.documentID}
                                if let index = index {
                                    sself.list[index] =  ChatListModel.init(uid: item.document.documentID, dic: item.document.data())
                                }
                                
                            }
                           
                        }
                        sself.list.sort { (list1, list2) -> Bool in
                            return list1.time?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970 > list2.time?.dateValue().millisecondsSince1970 ?? Date().millisecondsSince1970
                        }
                        sself.collectionview.reloadData()
                    }else if item.type == .removed {
                        let index = sself.list.firstIndex{ $0.uid == item.document.documentID}
                        if let index = index {
                            sself.list.remove(at: index)
                        }
                        sself.collectionview.reloadData()
                    }
                }
            }
        })
    }
    func configureCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        addSubview(collectionview)
        collectionview.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionview.register(ChatListItem.self, forCellWithReuseIdentifier: "id")
    }
}
extension RequestCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ChatListItem
        cell.user = list[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        UserService.shared.getOtherUser(userId: list[indexPath.row].uid) {[weak self] (user) in
            guard let sself = self else { return }
            let vc = RequestConservationVC(currentUser: currentUser, otherUser: user)
            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
            
        }
       
    }
}
