//
//  UploadImages.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 1.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
class UploadDataToDatabase : NSObject {
    
    static func uploadDataBase(postDate : String ,currentUser : CurrentUser ,lessonName : String, type : [String] , data : [Data]){
        
  
        save_datas(date: postDate, currentUser: currentUser, lessonName: lessonName, type: type, datas: data) { (listOfUrl) in
            print("url \(listOfUrl)")
        }
        
        
    }
    
    static func save_datas ( date : String ,currentUser : CurrentUser , lessonName : String , type : [String] , datas : [Data] ,completionHandler: @escaping ([String]) -> () ){
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = datas.count
        print(imagesCount)
        for data  in 0..<(datas.count) {
            let dataName = Date().millisecondsSince1970.description
            
            let metaDataForImage = StorageMetadata()
            if type[data] == "jpeg" {
                
                metaDataForImage.contentType = "image/jpeg"
            }
            Utilities.waitProgress(msg: "\(1). / \(imagesCount) Dosya Yükleniyor ")
            let storageRef = Storage.storage().reference().child(currentUser.short_school)
                .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + ".jpg")
            let uploadTask = storageRef.putData(datas[data], metadata: nil) { (result, err) in
                if err != nil {
                    print(err as Any)
                    return
                }
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + ".jpg").downloadURL {(downloadUrl, err) in
                        guard let imageUrl = downloadUrl?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        uploadedImageUrlsArray.append(imageUrl)
                        uploadCount += 1
                        print("Number of images successfully uploaded: \(uploadCount)")
                        Utilities.waitProgress(msg: "\(uploadCount). Dosya Yüklendi")
                         
                        if uploadCount == imagesCount{
                             SVProgressHUD.showSuccess(withStatus: "Bütün Dosyalar Yüklendi")
                            NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                            completionHandler(uploadedImageUrlsArray)
                        }
                }
                
                
                
            }
            observeUploadTaskFailureCases(uploadTask : uploadTask)
            uploadFiles(uploadTask: uploadTask , count : uploadCount)
        }
        
    }
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
func uploadFiles(uploadTask : StorageUploadTask , count : Int)
{
    uploadTask.observe(.progress) {  snapshot in
//        print(snapshot.progress as Any) //
//        print("dosya \(count) yükleniyor")
//        let percentComplete = 100.0 * Float(snapshot.progress!.completedUnitCount)
//            / Float(snapshot.progress!.totalUnitCount)
//
//        SVProgressHUD.showProgress(percentComplete, status: "Resim Yükleniyor \n \(Float(snapshot.progress!.totalUnitCount / 1_24) / 1000) MB % \(Int(percentComplete))")
//           Utilities.waitProgress(msg: "Dosylar Yükleniyor")
    }
//    uploadTask.observe(.success) { (snap) in
//
//        switch (snap.status) {
//
//        case .unknown:
//            break
//        case .resume:
//            break
//        case .progress:
//
//            break
//        case .pause:
//            break
//        case .success:
//            break:
////            SVProgressHUD.showSuccess(withStatus: "Yüklendi")
//        case .failure:
//            break
//        @unknown default:
//            break
//        }
//
//    }
    
}
