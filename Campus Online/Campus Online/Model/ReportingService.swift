//
//  ReportingService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
class ReportingService {
    static var shared = ReportingService()
    func setReport(reportType : String , reportTarget : String? , postId : String? , currentUser : CurrentUser ,text : String, otherUser : String , completion : @escaping(Bool)->Void){
        let dic = ["text":text,
            "reportType" : reportType,
            "reportTarget":reportTarget ?? "",
            "postId":postId ?? "","time":FieldValue.serverTimestamp(),
            "reportedTo" : otherUser,"reportedBy":currentUser.uid as Any
        ] as [String : Any]
        let db = Firestore.firestore().collection("report")
            .document(reportType)
            .collection("reportTo")
            .document(otherUser)
            .collection("report")
        db.addDocument(data: dic) { (err) in
            if err == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
            
    }
    func setMessagesReport(reportType : String , reportTarget : String?  , currentUser : CurrentUser ,text : String, otherUser : String , completion : @escaping(Bool)->Void ){
        
    }
    func setAppReport(reportType : String , reportTarget : String? , currentUser : CurrentUser ,text : String, completion : @escaping(Bool)->Void){
        let dic = ["text":text,
            "reportType" : reportType,
            "reportTarget":reportTarget ?? "",
            "time":FieldValue.serverTimestamp(),
            "reportedBy":currentUser.uid as Any
        ] as [String : Any]
        
        let db = Firestore.firestore().collection("report")
            .document(reportType)
            .collection("reportTo")
            .document(currentUser.uid)
            .collection("report")
        db.addDocument(data: dic) { (err) in
            if err == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
}
