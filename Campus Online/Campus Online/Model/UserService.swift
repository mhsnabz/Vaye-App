//
//  UserService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 29.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
struct UserService {
    static let shared = UserService()
    func fetchUser (completion : @escaping(CurrentUser) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore().collection("user")
        .document(uid)
        db.getDocument { (docSnap, err) in
            guard let dic = docSnap?.data() else { return }
            let currentUser = CurrentUser.init(dic: dic)
            completion(currentUser)
        }
    }
    func getCurrentUser(uid : String , completion : @escaping(CurrentUser) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let user = docSnap else { return }
                completion(CurrentUser.init(dic: user.data()!))
            }
        }
    }
    func fetchOtherUser ( uid : String , completion : @escaping(OtherUser) -> Void){

        let db = Firestore.firestore().collection("user")
        .document(uid)
        db.getDocument { (docSnap, err) in
            guard let dic = docSnap?.data() else {
                Utilities.dismissProgress()
                return }
            let currentUser = OtherUser.init(dic: dic)
            completion(currentUser)
        }
    }
    ///İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama/fallowers
    func fetchFallowers(_ sorthSchoolName: String! , _ major : String!  , _ lessonName : String!,completion : @escaping(LessonFallowerUser) -> Void)
        {
        let db = Firestore.firestore().collection(sorthSchoolName)
            .document("lesson").collection(major).document(lessonName).collection("fallowers")
        db.getDocuments { (querySnap, err) in
            if err == nil {
            if let snapShot = querySnap {
                    for doc in snapShot.documents {
                        completion(LessonFallowerUser.init(username: doc.documentID, dic: doc.data()))
                    }
                }
            }else {
                print("err : \(err?.localizedDescription as Any)")
            }
            
        }
    }
    func fetchFallower(_ sorthSchoolName: String! , _ major : String!  , _ lessonName : String!,completion : @escaping([LessonFallowerUser]) -> Void)
           {
            var list = [LessonFallowerUser]()
           let db = Firestore.firestore().collection(sorthSchoolName)
               .document("lesson").collection(major).document(lessonName).collection("fallowers")
           db.getDocuments { (querySnap, err) in
               if err == nil {
               if let snapShot = querySnap {
                       for doc in snapShot.documents {
                        let item = LessonFallowerUser.init(username: doc.documentID, dic: doc.data())
                        list.append(item)
                       }
                  completion(list)
                   }
                
               }else {
                   print("err : \(err?.localizedDescription as Any)")
               }
               
           }
       }
    func getUserNamesByUserName(username : [String]? , completion : @escaping([MentionUser]) -> Void){
        var mentionUser = [MentionUser]()
        guard !username!.isEmpty else {
            completion(mentionUser)
            return }
       
        for item in username! {
            let db = Firestore.firestore().collection("username").document(item)
            db.getDocument { (docSnap, err) in
                if err == nil {
                    guard let docSnap = docSnap else {
                        completion(mentionUser)
                        return
                    }
                    let user = MentionUser.init(userID: docSnap.get("uid") as? String, username: item)
                    mentionUser.append(user)
                    completion(mentionUser)
                }
                
            }
        }
          
    }
    
     func getUidByMention(username : String , completion : @escaping(String) ->Void){
        Utilities.waitProgress(msg: nil)
        print("username \(username)")
        //username/@deneme
        let db = Firestore.firestore().collection("username").document("@\(username)")
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion("")
                    return
                }
                if snap.exists {
                    Utilities.dismissProgress()
                    completion(docSnap?.get("uid") as! String)
                }else{
                    completion("")
                    Utilities.errorProgress(msg: "Böyle Bir Kullanıcı Bulunmuyor")
                }
            }
        }
        
    }
    func getUidBy_Mention(username : String , completion : @escaping(String) ->Void){
       Utilities.waitProgress(msg: nil)
       print("username:\(username)")
       //username/@deneme
       let db = Firestore.firestore().collection("username").document(username)
       db.getDocument { (docSnap, err) in
           if err == nil {
               guard let snap = docSnap else {
                   completion("")
                   return
               }
               if snap.exists {
                   Utilities.dismissProgress()
                   completion(snap.get("uid") as! String)
               }else{
                   completion("")
                   Utilities.errorProgress(msg: "Böyle Bir Kullanıcı Bulunmuyor")
               }
           }
       }
       
   }
    
    func getUserBy_Mention(username : String , completion : @escaping(OtherUser)->Void){
        getUidBy_Mention(username: username) { (uid) in
            if uid != ""{
                fetchOtherUser(uid: uid) { (user) in
                    completion(user)
                }
            }else{
                Utilities.errorProgress(msg: "Böyle Bir Kullanıcı Bulunmuyor")
            }
            
        }
    }
    func getUserByMention(username : String , completion : @escaping(OtherUser)->Void){
        getUidByMention(username: username) { (uid) in
            if uid != ""{
                fetchOtherUser(uid: uid) { (user) in
                    completion(user)
                }
            }else{
                Utilities.errorProgress(msg: "Böyle Bir Kullanıcı Bulunmuyor")
            }
            
        }
    }
     func checkFollowers(currentUser : CurrentUser , otherUser : String, completion : @escaping(Bool) -> Void ){
        let db = Firestore.firestore().collection("user")
            .document(otherUser).collection("fallowers").document(currentUser.uid)
        db.getDocument { (docSnap, err) in
          
            if err == nil {
                guard let snap = docSnap else { return }
                if snap.exists{
                    completion(true)
                }else{
                   completion(false)
                }
            }
        }
    }
    func fallowUser(currentUser : CurrentUser , otherUser : OtherUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("fallowers").document(currentUser.uid)
        db.setData(["user":currentUser.uid as Any] as [String:Any], merge: true) { (err) in
            if err == nil {
                completion(true)
               
            }
        }
    }
    
    
    
    func unFollowUser(currentUser : CurrentUser , otherUser : OtherUser , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("fallowers").document(currentUser.uid)
        db.delete { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    
    func getFollowers(uid : String , completion : @escaping([String])->Void){
        var user = [String]()
        let db = Firestore.firestore().collection("user")
            .document(uid).collection("fallowers")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if !snap.isEmpty{
                    for item in snap.documents{
                        user.append(item.documentID)
                        
                    }
                }else{
                    completion([])
                }
                completion(user)
            }
        }
    }
    
     func getOtherUser(userId : String , completion : @escaping(OtherUser)->Void){
        let db = Firestore.firestore().collection("user")
            .document(userId)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    Utilities.dismissProgress()
                    return }
                if snap.exists {
                    completion(OtherUser.init(dic: docSnap!.data()!))
                }
            }
        }
    }
    
    func getProfileModel(otherUser : OtherUser,currentUser : CurrentUser , completion : @escaping(ProfileModel) ->Void){
        completion(ProfileModel(shortSchool: otherUser.short_school, currentUser: currentUser, major: otherUser.bolum, uid: otherUser.uid))
        
    }
    
     func getFollowersCount(uid : String , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(uid).collection("fallowers")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard  let snap = querySnap else {
                    completion("0")
                    return
                }
                    completion(snap.documents.count.description)
                
                }
            }
        }
     func getFollowingCount(uid : String , completion :@escaping(String) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(uid).collection("following")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard  let snap = querySnap else {
                    completion("0")
                    return
                }
                    completion(snap.documents.count.description)
                
                }
            }
        }
    
    func checkCurrentUserSocialMedia(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        if currentUser.instagram == "" && currentUser.twitter == "" && currentUser.linkedin == "" && currentUser.github == "" {
            completion(false)

        }else{
            completion(true)

        }
    }
    func checkOtherUserSocialMedia(otherUser : OtherUser , completion : @escaping(Bool) ->Void){
        if otherUser.instagram == "" && otherUser.twitter == "" && otherUser.linkedin == "" && otherUser.github == "" {
            completion(false)

        }else{
            completion(true)

        }
    }
    
    
}
