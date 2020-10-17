//
//  MainPostUploadService.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 17.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
class MainPostUploadService{
    static var shareed = MainPostUploadService()
    var totalCompletedData : Float = 0
    var uploadTask : StorageUploadTask?
    func uploadDataBase(postDate : String ,currentUser : CurrentUser ,postType : String, type : [String] , data : [Data] , completion : @escaping([String]) -> Void ) {
        save_datas(date: postDate, currentUser: currentUser, postType: postType, type: type, datas: data) { (listOfUrl) in
            print("url \(listOfUrl)")
            completion(listOfUrl)
        }
    }
    func save_datas ( date : String ,currentUser : CurrentUser , postType : String , type : [String] , datas : [Data] ,completionHandler: @escaping ([String]) -> () ){
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = datas.count
        let semaphore = DispatchSemaphore(value: 1)
        for data  in 0..<(datas.count) {
            Utilities.waitProgress(msg: "\(imagesCount) Resim Yükleniyor\n Lütfen Bekleyiniz")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+5) {
                semaphore.wait()
                self.saveDataToDataBase(date: date, currentUser: currentUser, postType: postType, type[data], datas[data], uploadCount, imagesCount) {[weak self] (url) in
                    uploadedImageUrlsArray.append(url)
                    uploadCount += 1
                    print("Number of images successfully uploaded: \(uploadCount)")
                    guard let sself = self else { return }
                    Utilities.waitProgress(msg: "\(uploadCount). Resim Yüklendi")
                    if uploadCount == imagesCount{
                        sself.getThumbİmage(date: date, currentUser: currentUser, postType: postType, type[data], datas[data]) { (_) in
                            completionHandler(uploadedImageUrlsArray)
                            SVProgressHUD.showSuccess(withStatus: "Bütün Resimler Yüklendi")
                            semaphore.signal()
                            
                        }
                    }else{
                        sself.getThumbİmage(date: date, currentUser: currentUser, postType: postType, type[data], datas[data]) { (_) in
                            semaphore.signal()
                        }
                    }
                }
                
                
            }
        }
    }
    func saveDataToDataBase( date : String ,currentUser : CurrentUser , postType : String ,_ type : String ,_ data : Data ,_ uploadCount : Int,_ imagesCount : Int, completion : @escaping(String) ->Void){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        if type == DataTypes.image.description
        {
            metaDataForData.contentType = DataTypes.image.contentType
            
            
            let storageRef = Storage.storage().reference().child(currentUser.short_school)
                .child(currentUser.bolum).child(postType).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType)
            
            uploadTask = storageRef.putData(data, metadata: metaDataForData) { (metaData, err) in
                if err != nil
                {  print("err \(err as Any)") }
                else {
                    Storage.storage().reference().child(currentUser.short_school)
                        .child(currentUser.bolum).child(postType).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
                            guard let dataUrl = url?.absoluteString else {
                                print("DEBUG :  Image url is null")
                                return
                            }
                            completion(dataUrl)
                        }
                }
                
            }
            
        }
        uploadFiles(uploadTask: uploadTask! , count : uploadCount , percentTotal: 5 , data: data)
    }
    func getThumbİmage( date : String ,currentUser : CurrentUser , postType : String ,_ type : String ,_ data : Data , completion : @escaping(Bool) ->Void){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        
        if type == DataTypes.image.description
        {
            metaDataForData.contentType = DataTypes.image.contentType
            
            
            let storageRef = Storage.storage().reference().child(currentUser.short_school + " thumb")
                .child(currentUser.bolum).child(postType).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType)
            //        let thumbData = data.jpegData(compressionQuality: 0.8) else { return }
            let image : UIImage = UIImage(data: data)!
            guard let uploadData = resizeImage(image: image, targetSize: CGSize(width: 128, height: 128)).jpegData(compressionQuality: 1) else { return }
            uploadTask = storageRef.putData(uploadData, metadata: metaDataForData) { (metaData, err) in
                if err != nil
                {  print("err \(err as Any)") }
                else {
                    Storage.storage().reference().child(currentUser.short_school  + " thumb")
                        .child(currentUser.bolum).child(postType).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
                            guard let dataUrl = url?.absoluteString else {
                                print("DEBUG :  Image url is null")
                                return
                            }
                            setDataToSavedTask(currentUser: currentUser, url: dataUrl) { (_) in
                                completion(true)
                            }
                            
                        }
                }
                
            }
        }
        observeUploadTaskFailureCases(uploadTask : uploadTask!)
    }
    func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    NSLog("File doesn't exist")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to access file")
                    break
                case .cancelled:
                    NSLog("User canceled the upload")
                    break
                case .unknown:
                    NSLog("Unknown error occurred, inspect the server response")
                    break
                default:
                    NSLog("A separate error occurred, This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    func uploadFiles(uploadTask : StorageUploadTask , count : Int , percentTotal : Float , data : Data) {
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
                
                break
                
            case .failure:
                break
            @unknown default:
                break
            }
            
        }
        
    }
    
    
    func setThumbDatas(currentUser : CurrentUser , postId : String ,completion : @escaping(Bool)->Void){
        ///user/2YZzIIAdcUfMFHnreosXZOTLZat1/saved-task/task
        let db = Firestore.firestore().collection("user").document(currentUser.uid).collection("saved-task")
            .document("task")
        db.getDocument { [weak self] (docSnap, err) in
            if err == nil {
                guard let snap = docSnap else {
                    completion(true)
                    return }
                if snap.exists {
                    let data = snap.get("data") as! [String]
                    self?.moveThumbDatas(currentUser: currentUser, array: data, postId: postId) { (_) in
                        db.setData(["data":[]], merge: true) { (err) in
                            if err == nil {
                                completion(true)
                            }
                        }
                    }
                }else{
                    completion(true)
                }
                
            }
        }
        
    }
    func moveThumbDatas(currentUser : CurrentUser ,array : [String], postId : String , completion : @escaping(Bool) ->Void){
        
        let db = Firestore.firestore().collection(currentUser.short_school).document("main-post")
            .collection("post").document(postId)
        db.setData(["thumbData":array] as [String : Any], merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    
}

