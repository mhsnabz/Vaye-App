//
//  ChatListCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageKit
import SDWebImage
class ChatListCell: UICollectionViewCell {
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
            .collection("msg-list").order(by: "time",descending: true)
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

extension ChatListCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
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
        Utilities.waitProgress(msg: nil)
        UserService.shared.getOtherUser(userId: list[indexPath.row].uid) {[weak self] (user) in
            guard let sself = self else { return }
            let vc = ConservationVC(currentUser: currentUser, otherUser: user)
   
            sself.rootController?.navigationController?.pushViewController(vc, animated: true)
            Utilities.dismissProgress()
        }
    }
    
    
}

class ChatListItem : UICollectionViewCell {
    weak var user : ChatListModel?{
        didSet{
            configure()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(profileImage)
        profileImage.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 50, heigth: 50)
        profileImage.layer.cornerRadius = 25
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(tarih)
        tarih.anchor(top: topAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 16, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 50, heigth: 10)
        addSubview(userName)
        userName.anchor(top: topAnchor, left: profileImage.rightAnchor, bottom: nil, rigth: tarih.leftAnchor, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 1, width: 0, heigth: 20)
        addSubview(badgeCount)
        badgeCount.anchor(top: tarih.bottomAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 12, marginLeft: 0, marginBottom: 0, marginRigth: 16, width: 15, heigth: 15)
        
   
        addSubview(lastMsgView)
        lastMsg.anchor(top: userName.bottomAnchor, left: profileImage.rightAnchor, bottom: bottomAnchor, rigth: badgeCount.leftAnchor, marginTop: 0, marginLeft: 12, marginBottom: 12, marginRigth: 12, width: 0, heigth: 0)
        addSubview(lastMsgViewWithImage)
        lastMsgViewWithImage.anchor(top: userName.bottomAnchor, left: profileImage.rightAnchor, bottom: bottomAnchor, rigth: badgeCount.leftAnchor, marginTop: 0, marginLeft: 12, marginBottom: 12, marginRigth: 12, width: 0, heigth: 0)
       
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 8, marginBottom: 1, marginRigth: 8, width: 0, heigth: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var profileImage : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.3
        img.layer.borderColor = UIColor.lightGray.cgColor
        return img
    }()
    lazy var userName : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        lbl.textColor = .black
        
        return lbl
    }()
    lazy var name : NSMutableAttributedString = {
         let name = NSMutableAttributedString()
         return name
     }()
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    lazy var msgKidImage : UIImageView = {
       let img = UIImageView()

       return img
    }()
    lazy var lastMsg : UILabel = {
        let lbl = UILabel()
        
        return lbl
    }()
    lazy var tarih : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 10)
        lbl.textColor = .darkGray
        lbl.textAlignment = .right
        return lbl
    }()
    lazy var badgeCount : UILabel = {
        let lbl = UILabel()
        lbl.clipsToBounds = true
        lbl.backgroundColor = .red
        lbl.textColor = .white
        lbl.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.layer.cornerRadius = 15 / 2
        return lbl
    }()
    
    lazy var lastMsgViewWithImage : UIView = {
        let v = UIView()
        v.addSubview(msgKidImage)
  
        msgKidImage.anchor(top: nil, left: v.leftAnchor, bottom: nil
                           , rigth: nil
                           , marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 15, heigth: 15)
        msgKidImage.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(lastMsg)
        lastMsg.anchor(top: nil
                       , left: msgKidImage.rightAnchor, bottom: nil, rigth: v.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        lastMsg.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        return v
    }()
    
    
    lazy var lastMsgView : UIView = {
        let v = UIView()

       
        v.addSubview(lastMsg)
        
        lastMsg.anchor(top: nil , left: v.leftAnchor, bottom: nil, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 20)
        lastMsg.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        return v
    }()
    
    private func configure(){
        guard let user = user else { return }
        if user.type == "text" {
            msgKidImage.image = #imageLiteral(resourceName: "font").withRenderingMode(.alwaysOriginal)
        }else if user.type == "photo"{
            msgKidImage.image = #imageLiteral(resourceName: "gallery").withRenderingMode(.alwaysOriginal)
      
        }else if user.type == "location"{
            msgKidImage.image = #imageLiteral(resourceName: "location-orange").withRenderingMode(.alwaysOriginal)
    
        }else if user.type == "audio"{
            msgKidImage.image = #imageLiteral(resourceName: "audio").withRenderingMode(.alwaysOriginal)
      
        }
        
        lastMsg.text = user.lastMsg
        name = NSMutableAttributedString(string: "\(user.name!)", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        name.append(NSAttributedString(string: " \(user.username!)", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.font, size: 10)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        userName.attributedText = name
        tarih.text = user.time?.dateValue().timeAgoDisplay()
        profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        profileImage.sd_setImage(with: URL(string : user.thumbImage ?? ""))
        
        guard let totalBadge = user.badgeCount else { return }
        
        if totalBadge == 0 {
            badgeCount.isHidden = true
            lastMsg.font = UIFont(name: Utilities.font, size: 12)
            lastMsg.textColor = .darkGray
            
        }else{
            if totalBadge > 9 {
                badgeCount.font = UIFont(name: Utilities.fontBold, size: 8)
                badgeCount.text = "+\(9)"
            }else{
                badgeCount.text = user.badgeCount?.description
                badgeCount.font = UIFont(name: Utilities.fontBold, size: 10)
            }
           
            badgeCount.textAlignment = .center
            badgeCount.isHidden = false
            
            lastMsg.font = UIFont(name: Utilities.fontBold, size: 12)
            lastMsg.textColor = .black
        }
        
    }
    
    
}
