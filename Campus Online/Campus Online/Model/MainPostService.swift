//
//  MainPostService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 18.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class MainPostService {
    static var shared = MainPostService()
    func setLikePost(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                //main-post/sell-buy/post/1603357054085
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            completion(true)
                            NotificaitonService.shared.send_mainpost_like_notification(post: post, currentUser: currentUser, text: Notification_description.like_sell_buy.desprition, type: NotificationType.like_sell_buy.desprition)
                        }
                }
            }
        }
    }
        else{
            post.likes.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {(err) in
                    completion(true)
                    NotificaitonService.shared.mainpost_remove_like_notification(post: post, currentUser: currentUser)
                }
            }
        }
    }
    
    func setDislike(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void)
    {
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                        
                        completion(true)
                        }
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
            }}}}
    
    func setHeaderLikePost(target : String ,tableView : UITableView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                //main-post/sell-buy/post/1603357054085
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            completion(true)
                            NotificaitonService.shared.send_mainpost_like_notification(post: post, currentUser: currentUser, text: Notification_description.like_sell_buy.desprition, type: NotificationType.like_sell_buy.desprition)
                        }
                }
            }
        }
    }
        else{
            post.likes.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {(err) in
                    completion(true)
                    NotificaitonService.shared.mainpost_remove_like_notification(post: post, currentUser: currentUser)
                }
            }
        }
    }
    
    func setHeaderDislike(target : String ,tableView : UITableView!,currentUser : CurrentUser, post : MainPostModel! , completion : @escaping(Bool) ->Void)
    {
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                        
                        completion(true)
                        }
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
            }}}}
    
    func deleteToStorage(data : [String], postId : String , completion : @escaping(Bool) -> Void){
        if data.count == 0{
            completion(true)
            return
        }
        for item in data{
            let ref = Storage.storage().reference(forURL: item)
            ref.delete { (err) in
                completion(true)
            }
        }
    }
    
    
    func checkFollowTopic(currentUser : CurrentUser,topic : String ,completion :  @escaping(Bool) ->Void ){
        let db = Firestore.firestore().collection("main-post")
            .document(topic).collection("followers")
            .document(currentUser.uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return
                }
                if snap.exists{
                    completion(true)
                }
                else{
                    completion(false)
                }
            }else{
                completion(false)
            }
        }
        
    }
    func checkHasPost(target : String,completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document("post").collection("post")
        db.getDocuments { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return}
                if snap.isEmpty{
                    completion(false)
                }else{
                    completion(true)
                }
            }
        }
     
    }
    
    func getMainPost(postId : String , completion : @escaping(MainPostModel?) ->Void){
        let db = Firestore.firestore().collection("main-post")
            .document("post")
            .collection("post")
            .document(postId)
        db.getDocument { (docsnap, err) in
            if err == nil{
                guard let post = docsnap else {
                    completion(nil)
                    return
                }
                completion(MainPostModel.init(postId: postId, dic: post.data()))
            }else{
                completion(nil)
            }
        }
    }
    
    func deleteData(index : IndexPath,post : MainPostModel , currentUser : CurrentUser , collectionview : UICollectionView , url : String ){
        Utilities.waitProgress(msg: "Siliniyor")
        
        let storage = Storage.storage()
        let r = storage.reference(forURL: url)
        r.delete { (err) in
            if err == nil {
                //db.updateData(["silent":FieldValue.arrayRemove([currentUser.uid as Any])])
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["data":FieldValue.arrayRemove([url as Any])]) {[weak self] (err) in
                    if err == nil {
                        guard  let sself = self else {
                            return
                        }
                        if let index = post.data.firstIndex(of: url) {
                            
                           post.data.remove(at: index)
                            collectionview.reloadData()

                        }
                        sself.removeThumbData(currentUser: currentUser, post: post, index : index) { (_) in
                            collectionview.reloadData()
                        }
                            
                        
                    }
                }
            }else{
                
                print("err \(err?.localizedDescription as Any)")
                Utilities.errorProgress(msg: "Hata Oluştu")
                return
            }
        }
    }
    func removeThumbData(currentUser  : CurrentUser , post : MainPostModel ,  index : IndexPath , completion : @escaping(Bool) ->Void){
        let url = post.thumbData[index.row]
        let storage = Storage.storage()
        let r = storage.reference(forURL: url)
        r.delete { (err) in
            if err == nil {
                
                let db = Firestore.firestore().collection("main-post")
                    .document("post")
                    .collection("post")
                    .document(post.postId)
             
                db.updateData(["thumbData":FieldValue.arrayRemove([url as Any])]) { (err) in
                    if err == nil {
                        if let index = post.thumbData.firstIndex(of: url) {
                            Utilities.succesProgress(msg: "Dosya Silindi")
                           post.thumbData.remove(at: index)
                           completion(true)

                        }
                    }else{
                        print("err \(err?.localizedDescription as Any)")
                    }
                }

            }else{
                print("err \(err?.localizedDescription as Any)")
            }
        }
    }
    
}
enum MainPostLikeTarget {
    case buy_sell
    case food_me
    case camping
    case parties
    var description : String{
        switch self{
        
        case .buy_sell:
            return "sell-buy"
        case .food_me:
            return "food-me"
        case .camping:
            return "camping"
        case .parties:
            return "parties"
        }
    }
}
