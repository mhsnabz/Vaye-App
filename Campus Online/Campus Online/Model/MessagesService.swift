//
//  MessagesService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
import MessageKit
class MessagesService {
    var totalCompletedData : Float = 0
    var uploadTask : StorageUploadTask?
    static public var shared = MessagesService()
    func getFriendList(currentUser : CurrentUser , completion:@escaping([OtherUser]) ->Void){
        var list = [OtherUser]()
        if currentUser.friendList.isEmpty {
            completion(list)
        }else{
            for item in currentUser.friendList {
                UserService.shared.getOtherUser(userId: item) { (user) in
                    list.append(user)
                }
            }
            completion(list)
        }
        
    }
    
    
    func getFriends(uid : String , completion:@escaping(OtherUser)->Void){
        let db = Firestore.firestore().collection("user")
            .document(uid)
        db.getDocument { (docSnap, err) in
            if err == nil{
                guard let snap = docSnap else { return }
                completion(OtherUser.init(dic: snap.data()!))
            }
        }
    }
    
    
    func sendMessage(newMessage : Message , currentUser : CurrentUser , otherUser : OtherUser , time : Int64 ){
        var msg = ""
        var loc : GeoPoint?
        var width : CGFloat = 0.0
        var heigth : CGFloat = 0.0
        var duration : Float = 0
        switch newMessage.kind{
            
        case .text(let messageText):
            msg = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString{
                msg = targetUrlString
                heigth = mediaItem.size.height
                width = mediaItem.size.width
                
            }
            break
        case .video(_):
            break
        case .location(let item):
            let item = item.location
            loc = GeoPoint(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)
            width = 200
            heigth = 200
            break
        case .emoji(_):
            break
        case .audio(let item):
            msg = item.url.absoluteString
            duration = item.duration
            width = item.size.width
            heigth = item.size.height
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }


        var dic = Dictionary<String,Any>()
        if  let locaiton = loc{
             dic = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": locaiton,
                "date": FieldValue.serverTimestamp(),
                "time":time,
                "senderUid" : currentUser.uid as Any,
                "is_read": false,
                "width" :width ,
                "heigth" : heigth,
                "name": currentUser.name as Any
            ] as [String : Any]
        }else{
            dic = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": msg,
                "date": FieldValue.serverTimestamp(),
                "time":time,
                "senderUid" : currentUser.uid as Any,
                "is_read": false,
                "width" :width ,
                "duration" : duration ,
                "heigth" : heigth,
                "name": currentUser.name as Any
            ] as [String : Any]
        }
       
        
        let dbSender = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(otherUser.uid)
            .document(newMessage.messageId)
        dbSender.setData(dic, merge: true, completion: nil)
        
        
        let dbGetter = Firestore.firestore().collection("messages")
            .document(otherUser.uid)
            .collection(currentUser.uid)
            .document(newMessage.messageId)
        dbGetter.setData(dic, merge: true, completion: nil)
    }

    
    func uploadImages(datas :[Data] , currentUser : String, type : [String]  , otherUser : String , completion:@escaping([String]) -> Void){
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = datas.count
        let semaphore = DispatchSemaphore(value: 1)
        for data  in 0..<(datas.count) {
            Utilities.waitProgress(msg: "\(imagesCount) Dosya Yükleniyor\n Lütfen Bekleyiniz")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+5) {
                semaphore.wait()
                self.saveToDataBase(currentUser: currentUser, otherUser: otherUser, data: datas[data], uploadCount, imagesCount, type[data]) { (url) in
                    uploadedImageUrlsArray.append(url)
                    uploadCount += 1
                    Utilities.waitProgress(msg: "\(uploadCount). Dosya Yüklendi")
                    if uploadCount == imagesCount{
                        SVProgressHUD.showSuccess(withStatus: "Bütün Dosyalar Yüklendi")
                        semaphore.signal()
                    }
                }
            }
        }
    }
    
    
    
    func saveToDataBase(currentUser : String, otherUser : String , data : Data ,_ uploadCount : Int,_ imagesCount : Int , _ type : String ,completion : @escaping(String) ->Void  ){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        if type == DataTypes.doc.description{
            metaDataForData.contentType = DataTypes.doc.contentType
            let storageRef = Storage.storage().reference()
                .child("messages")
                .child(currentUser)
                .child(otherUser)
                .child(dataName + DataTypes.doc.mimeType)
            uploadTask = storageRef.putData(data, metadata: metaDataForData, completion: { (metaData, err) in
                if err != nil {
                    print("err \(err as Any)")
                }else{
                    Storage.storage().reference()
                        .child("messages")
                        .child(currentUser)
                        .child(otherUser)
                        .child(dataName + DataTypes.doc.mimeType).downloadURL { (url, err) in
                            guard let dataUrl = url?.absoluteString else {
                                
                                return
                            }
                            completion(dataUrl)
                        }
                }
            })
        }else if type == DataTypes.pdf.description{
            metaDataForData.contentType = DataTypes.pdf.contentType
            let storageRef = Storage.storage().reference()
                .child("messages")
                .child(currentUser)
                .child(otherUser)
                .child(dataName + DataTypes.pdf.mimeType)
            uploadTask = storageRef.putData(data, metadata: metaDataForData, completion: { (metaData, err) in
                if err != nil {
                    print("err \(err as Any)")
                }else{
                    Storage.storage().reference()
                        .child("messages")
                        .child(currentUser)
                        .child(otherUser)
                        .child(dataName + DataTypes.pdf.mimeType).downloadURL { (url, err) in
                            guard let dataUrl = url?.absoluteString else {
                                
                                return
                            }
                            completion(dataUrl)
                        }
                }
            })
        }else if type == DataTypes.image.description{
            metaDataForData.contentType = DataTypes.image.contentType
            let storageRef = Storage.storage().reference()
                .child("messages")
                .child(currentUser)
                .child(otherUser)
                .child(dataName + DataTypes.image.mimeType)
            uploadTask = storageRef.putData(data, metadata: metaDataForData, completion: { (metaData, err) in
                if err != nil {
                    print("err \(err as Any)")
                }else{
                    Storage.storage().reference()
                        .child("messages")
                        .child(currentUser)
                        .child(otherUser)
                        .child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
                            guard let dataUrl = url?.absoluteString else {
                                
                                return
                            }
                            completion(dataUrl)
                        }
                }
            })
        }
        
        uploadFiles(uploadTask: uploadTask! , count : uploadCount , percentTotal: 5 , data: data)
    }
    func uploadFiles(uploadTask : StorageUploadTask , count : Int , percentTotal : Float , data : Data)
    {
       
        uploadTask.observe(.progress) {  snapshot in
            print(snapshot.progress as Any) //
            
            let percentComplete = 100.0 * Float(snapshot.progress!.completedUnitCount)
                / Float(snapshot.progress!.totalUnitCount)
            print("upload : \(percentComplete )")
            SVProgressHUD.showProgress(percentComplete / 100, status: "\(count + 1). Dosya %\(Int(percentComplete))")
        }
        uploadTask.observe(.success) { (snap) in
            
            switch (snap.status) {
                
            case .unknown:
                break
            case .resume:
                break
            case .progress:
                
                break
            case .pause:
                break
            case .success:
                //            totalCompletedData += SizeOfData(data: data)
                break
                
            case .failure:
                break
            @unknown default:
                break
            }
            
        }
        
    }
}
