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
}
