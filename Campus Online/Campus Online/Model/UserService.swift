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
                    completion(user)
                }else{
                    completion([])
                }
                
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
    func getFirendList(uid : [String] , completion:@escaping([OtherUser]) ->Void){
        var users = [OtherUser]()
        for item in uid{
            getOtherUser(userId: item) { (user) in
                users.append(user)
            }
        }
        completion(users)
        
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
    
    
    func checkUserIsComplete(uid : String , completion : @escaping(Bool) -> Void){
        ///task-user/VH7uSHHUVYPI2GP5hZ0NH5wFBUA2
        let db = Firestore.firestore().collection("task-user")
            .document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else { return }
                if snap.exists
                {
                    completion(true)
                }else{
                    completion(false)
                }
                
            }else{
                print(err?.localizedDescription as Any)
            }
        }
    }
    
    
    func getTaskUser(uid : String , completion : @escaping(TaskUser) -> Void){
        let db = Firestore.firestore().collection("task-user")
            .document(uid)
        db.getDocument { (docsnap, err) in
            if err == nil {
                guard let snap = docsnap else {
                    return
                }
                completion(TaskUser.init(uid: uid, dic: snap.data()!))
            }
        }
    }
    
    func checkTeacherIsComplet(uid : String , completion : @escaping(Bool) -> Void){
        let db = Firestore.firestore().collection("task-teacher")
            .document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else { return }
                if snap.exists
                {
                    completion(true)
                }else{
                    completion(false)
                }
                
            }else{
                print(err?.localizedDescription as Any)
            }
        }
    }
    func getTaskTeacher(uid : String , completion : @escaping(TaskUser) -> Void){
        let db = Firestore.firestore().collection("task-teacher")
            .document(uid)
        db.getDocument { (docsnap, err) in
            if err == nil {
                guard let snap = docsnap else {
                    return
                }
                completion(TaskUser.init(uid: uid, dic: snap.data()!))
            }
        }
    }
    
    
    func teacherAddLesson(currentUser : CurrentUser , lessonName : String , completion : @escaping(Bool) ->Void)
    {
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
        let dic = ["teacherName":currentUser.name as Any,
                   "teacherId":currentUser.uid as Any,
                   "teacherEmail":currentUser.email as Any,
                   "lessonName":lessonName] as [String:Any]
        let db = Firestore.firestore().collection(currentUser.short_school).document("lesson")
            .collection(currentUser.bolum)
            .document(lessonName)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                let dbNoti = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson").collection(currentUser.bolum)
                    .document(lessonName).collection("notification_getter").document(currentUser.uid)
                dbNoti.setData(["uid":currentUser.uid as Any], merge: true) { (err) in
                    if err == nil {
                        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                        let db = Firestore.firestore().collection("user")
                            .document(currentUser.uid)
                            .collection("lesson")
                            .document(lessonName)
                        db.setData(dic, merge: true) { (err) in
                            if err == nil {
                                getLessonPost(currentUser: currentUser, lessonName: lessonName) { (_) in
                                    completion(true)
                                }
                            }else{
                                completion(false)
                            }
                        }
                    }else{
                        Utilities.errorProgress(msg: "Ders Eklenemedi")
                        completion(false)
                    }
                }
            }else{
                Utilities.errorProgress(msg: "Ders Eklenemedi")
                completion(false)
            }
        }
    }
    
    func getLessonPost(currentUser  : CurrentUser,lessonName : String , completion : @escaping(Bool) ->Void){
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama/lesson-post
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson")
            .collection(currentUser.bolum)
            .document(lessonName)
            .collection("lesson-post").limit(to: 10).order(by: "postId", descending: true)
        ////user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
        let dbLesson = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("lesson-post")
 
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion(true)
                    return
                }
                for item in snap.documents {
                    dbLesson.document(item.documentID).setData(["postId":item.documentID], merge: true)
                    
                }
                completion(true)
            }
        }
    
    }
    
    func teacherRemoveLessonPost(currentUser : CurrentUser , lessonName : String , completion:@escaping(Bool) -> Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson")
            .collection(currentUser.bolum)
            .document(lessonName)
            .collection("lesson-post")
        ////user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
        let dbLesson = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("lesson-post")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion(true)
                    return
                }
                for item in snap.documents {
                    dbLesson.document(item.documentID).delete()
                    
                }
                completion(true)
            }
        }
        
    }
    
    func teacherRemoveLesson(lessonName : String , currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
        let dic = ["teacherName":"empty",
                   "teacherId":"empty",
                   "teacherEmail":"empty",
                   "lessonName":lessonName] as [String:Any]
        let db = Firestore.firestore().collection(currentUser.short_school).document("lesson")
            .collection(currentUser.bolum)
            .document(lessonName)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                let dbNoti = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson").collection(currentUser.bolum)
                    .document(lessonName).collection("notification_getter").document(currentUser.uid)
                dbNoti.setData(["uid":currentUser.uid as Any], merge: true) { (err) in
                    if err == nil {
                        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson/Bilgisayar Programlama
                        let db = Firestore.firestore().collection("user")
                            .document(currentUser.uid)
                            .collection("lesson")
                            .document(lessonName)
                        db.setData(dic, merge: true) { (err) in
                            if err == nil {
                                teacherRemoveLessonPost(currentUser: currentUser, lessonName: lessonName) { (_) in
                                    let db = Firestore.firestore().collection("user")
                                        .document(currentUser.uid)
                                        .collection("lesson")
                                        .document(lessonName)
                                    db.delete { (err) in
                                        if err == nil {
                                            completion(true)
                                        }
                                }
                                
                            }
                            }
                                else{
                                completion(false)
                            }
                        }
                    }else{
                        Utilities.errorProgress(msg: "Ders Silinemedi")
                        completion(false)
                    }
                }
            }else{
                Utilities.errorProgress(msg: "Ders Silinemedi")
                completion(false)
            }
    }
}
    
    func getLessonFallowers(currentUser : CurrentUser , lessonName : String , completion : @escaping([String])->Void){
        var user : [String] = []
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson")
            .collection(currentUser.bolum)
            .document(lessonName)
            .collection("fallowers")
        
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                if snap.isEmpty {
                    completion(user)
                }else{
                    for item in snap.documents{
                        user.append(item.get("uid") as! String)
                       
                    }
                    Utilities.dismissProgress()
                    completion(user)
                }
            }
        }
    }
    
    
    func chekcIsMutual(currentUserUid : String , otherUserUid : OtherUser , completion : @escaping(Bool) ->Void){
        
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/fallowers
        let db = Firestore.firestore().collection("user")
            .document(otherUserUid.uid).collection("following").document(currentUserUid)
        let dbb = Firestore.firestore().collection("user")
            .document(currentUserUid).collection("following").document(otherUserUid.uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(false)
                    return }
                if snap.exists {
                    dbb.getDocument { (snapp, err) in
                        guard let snapp = snapp else{
                            completion(false)
                            return
                        }
                        if snapp.exists{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }else{
                    completion(false)
                }
            }
        }
    }
    
    func addAsMessagesFriend(currentUserUid : CurrentUser , otherUserUid : OtherUser )
    {
        
        chekcIsMutual(currentUserUid: currentUserUid.uid , otherUserUid: otherUserUid) { (val) in
            if val {
//                let db = Firestore.firestore().collection("user")
//                    .document(currentUserUid.uid).collection("friend-list")
//                    .document(otherUserUid.uid)
//                getOtherUser(userId: otherUserUid.uid) { (user) in
//                    let dic = ["userName":user.username as Any,"uid":user.uid as Any, "name":user.name as Any, "short_school" : user.short_school as Any, "bolum":user.bolum as Any, "thumb_image" : user.thumb_image as Any, "tarih" : FieldValue.serverTimestamp()] as [String : Any]
//                    db.setData(dic as [String : Any], merge: true){ (err) in
//
//                    }
               
                addOnFriendArray(currentUser: currentUserUid, otherUser: otherUserUid) { (_val) in
                    addOtherUserOnFriendList(currentUser: currentUserUid, otherUser: otherUserUid) { (_) in
                        print("succes")
                    }
                }
                
              
            }
        }
         
    }
    
    func addOnFriendArray(currentUser : CurrentUser , otherUser : OtherUser , completion:@escaping(Bool) ->Void){
        let dbc = Firestore.firestore().collection("user")
            .document(otherUser.uid)
        dbc.updateData(["friendList":FieldValue.arrayUnion([currentUser.uid!])]) { (err) in
            if err == nil {
                let dbb = Firestore.firestore().collection("user")
                    .document(currentUser.uid)
                dbb.updateData(["friendList":FieldValue.arrayUnion([otherUser.uid as Any])]) { (err) in
                    if err == nil {
                        completion(true)
                        
                    }
                }
            }
        }
    }
    
    func addOtherUserOnFriendList(currentUser : CurrentUser , otherUser : OtherUser , completion:@escaping(Bool)->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("friend-list")
            .document(otherUser.uid)
        let dic = ["userName":otherUser.username as Any ,
                   "uid":otherUser.uid as Any,
                   "name":otherUser.name as Any ,
                   "short_school" : otherUser.short_school as Any ,
                   "thumb_image":otherUser.thumb_image as Any
                   ,"tarih":FieldValue.serverTimestamp(),
                   "bolum":otherUser.bolum as Any]  as [String : Any]
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                addCurrenUserOnFriendList(currentUser: currentUser, otherUser: otherUser) { (_) in
                    completion(true)
                }
            }
        }
    }
    func addCurrenUserOnFriendList(currentUser : CurrentUser , otherUser : OtherUser , completion:@escaping(Bool)->Void){
        let db = Firestore.firestore().collection("user")
            .document(otherUser.uid)
            .collection("friend-list")
            .document(currentUser.uid)
        let dic = ["userName":currentUser.username as Any ,"uid":currentUser.uid as Any, "name":currentUser.name as Any , "short_school" : currentUser.short_school as Any ,"thumb_image":currentUser.thumb_image as Any,"tarih":FieldValue.serverTimestamp(), "bolum":currentUser.bolum as Any]  as [String : Any]
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                removeFromRequestList(currenUser: currentUser, otherUser: otherUser) { (_) in
                    completion(true)
                }
            }
        }
    }
    func removeRequestBadgeCount(currentUser : CurrentUser , otherUser : OtherUser , completion:@escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("msg-request")
            .document(otherUser.uid)
            .collection("badgeCount")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion(true)
                    return
                }
                if snap.isEmpty {
                    completion(true)
                }else{
                    for item in snap.documents{
                        db.document(item.documentID).delete { (err) in
                            if err == nil {
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    func removeFromRequestList(currenUser : CurrentUser , otherUser : OtherUser , completion:@escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currenUser.uid)
            .collection("msg-request")
            .document(otherUser.uid)
        db.getDocument { (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else { return }
                guard let data = snap.data() else { return }
                if snap.exists {
                    addOnFriendList(currenUser: currenUser, otherUser: otherUser, dic: data) { (_) in
       
                        db.delete { (err) in
                            completion(true)
                        }
                    }
                }else{
                    completion(true)
                }
            }
        }
    }
    func addOnFriendList(currenUser : CurrentUser  , otherUser : OtherUser ,dic : Dictionary<String , Any >, completion:@escaping(Bool) ->Void){
        let db  = Firestore.firestore().collection("user")
            .document(currenUser.uid)
            .collection("msg-list")
            .document(otherUser.uid)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    
//    func addOnFirendList(otherUser : OtherUser , currntUser : CurrentUser){
//        let db = Firestore.firestore().collection("user")
//            .document(otherUser).collection("friend-list")
//            .document(currntUser.uid)
//        let dic = ["userName":currntUser.username as Any ,"uid":currntUser.uid as Any, "name":currntUser.name as Any , "short_school" : currntUser.short_school as Any ,"thumb_image":currntUser.thumb_image as Any,"tarih":FieldValue.serverTimestamp(), "bolum":currntUser.bolum as Any]  as [String : Any]
//        db.setData(dic as [String : Any], merge: true)
//        currntUser.friendList.append(otherUser)
//
//    }
    func removeFromFriendList(currentUserUid : CurrentUser , otherUserUid : OtherUser){
        
        removeOtherUserPost(otherUserId: otherUserUid.uid, currentUser: currentUserUid)
        let db = Firestore.firestore().collection("user")
            .document(currentUserUid.uid)
        db.updateData(["friendList":FieldValue.arrayRemove([otherUserUid.uid as String])]) { (err) in
            if err == nil {
                let db = Firestore.firestore().collection("user")
                    .document(otherUserUid.uid)
                db.updateData(["friendList":FieldValue.arrayRemove([currentUserUid.uid as Any])]) { (err) in
                    if err == nil {
                        let db = Firestore.firestore().collection("user")
                            .document(currentUserUid.uid).collection("friend-list").document(otherUserUid.uid)
                        db.delete(){(err) in
                            let db = Firestore.firestore().collection("user")
                                .document(otherUserUid.uid).collection("friend-list").document(currentUserUid.uid)
                            db.delete(){(err) in
                                removeFromMsgList(currentUser: currentUserUid, otherUser: otherUserUid.uid)
                            }
                            
                        }

                    }
                }
            }
        }
    }

    func removeFromMsgList(currentUser : CurrentUser , otherUser : String){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("msg-list")
            .document(otherUser)
          db.delete()

    }

    func removeOtherUserPost(otherUserId : String , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("user").document(currentUser.uid)
            .collection("main-post").whereField("senderUid", isEqualTo:otherUserId)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                for id in snap.documents {
                    let dbDelete = Firestore.firestore().collection("user")
                        .document(currentUser.uid).collection("main-post").document(id.documentID)
                    dbDelete.delete()
                }
            }
        }
    }
    
}
