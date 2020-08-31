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
}
