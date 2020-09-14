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
  
    
}
