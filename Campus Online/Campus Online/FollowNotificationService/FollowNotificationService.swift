//
//  FollowNotificationService.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 8.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class FollowNotificationService {
    static let shared =  FollowNotificationService()
    func followingNotification(postType : String ,currentUser : CurrentUser , otherUser : OtherUser , text : String , type : String ){
        let notificaitonId = Int64(Date().timeIntervalSince1970 * 1000).description
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid).collection("notification").document(notificaitonId)
        db.setData(Utilities.shared.getDictionary(postType: postType, type: type, text: text, currentUser: currentUser, not_id: notificaitonId, targetCommentId: "", postId: "", lessonName: "", clupName: "", vayeAppPostName: ""), merge: true)
    }
    
}
