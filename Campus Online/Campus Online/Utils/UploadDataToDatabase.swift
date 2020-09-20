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
    
    static func uploadDataBase(postDate : String ,currentUser : CurrentUser ,lessonName : String, type : [String] , data : [Data] , completion : @escaping([String]) -> Void ){
        save_datas(date: postDate, currentUser: currentUser, lessonName: lessonName, type: type, datas: data) { (listOfUrl) in
            print("url \(listOfUrl)")
            completion(listOfUrl)
        }
    }
    
    static func save_datas ( date : String ,currentUser : CurrentUser , lessonName : String , type : [String] , datas : [Data] ,completionHandler: @escaping ([String]) -> () ){
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = datas.count
        let semaphore = DispatchSemaphore(value: 1)
        
        for data  in 0..<(datas.count) {
            
            Utilities.waitProgress(msg: "\(imagesCount) Dosya Yükleniyor\n Lütfen Bekleyiniz")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+5) {
                semaphore.wait()
                saveDataToDataBase(date: date, currentUser: currentUser, lessonName: lessonName, type[data], datas[data], uploadCount, imagesCount) { (url) in
                    uploadedImageUrlsArray.append(url)
                    uploadCount += 1
                    print("Number of images successfully uploaded: \(uploadCount)")
                   
                    Utilities.waitProgress(msg: "\(uploadCount). Dosya Yüklendi")
                    if uploadCount == imagesCount{
                        SVProgressHUD.showSuccess(withStatus: "Bütün Dosyalar Yüklendi")
                        semaphore.signal()
                        completionHandler(uploadedImageUrlsArray)
                        
                        
                    }else{
                        semaphore.signal()
                    }
                }
            }
            
            
        }
       
        
    }
    
  static func asynchronousOperation(index: Int,date: Date, currentUser: CurrentUser, lessonName: String, type : String, data : Data, uploadCount : Int, imagesCount : Int, completion: @escaping (String) -> ()) {
     
    }
   
    
}
var totalCompletedData : Float = 0
var uploadTask : StorageUploadTask?


private func SizeOfData(data : Data) -> Float {
    
    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useKB] // optional: restricts the units to MB only
    bcf.countStyle = .file
    
    return  Float(data.count)
    
}

func getThumbİmage( date : String ,currentUser : CurrentUser , lessonName : String ,_ type : String ,_ data : Data ,_ uploadCount : Int,_ imagesCount : Int, completion : @escaping(String) ->Void){
    let metaDataForData = StorageMetadata()
    let dataName = Date().millisecondsSince1970.description
    
    if type == DataTypes.image.description
    {
        metaDataForData.contentType = DataTypes.image.contentType
        
        
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(lessonName + "thumb").child(dataName + DataTypes.image.mimeType)
        //        let thumbData = data.jpegData(compressionQuality: 0.8) else { return }
        let image : UIImage = UIImage(data: data)!
        guard let uploadData = image.jpeg(.low) else { return }
        uploadTask = storageRef.putData(uploadData, metadata: metaDataForData) { (metaData, err) in
            if err != nil
            {  print("err \(err as Any)") }
            else {
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(lessonName + "thumb").child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
                        guard let dataUrl = url?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        completion(dataUrl)
                        
                }
            }
            
        }
        observeUploadTaskFailureCases(uploadTask : uploadTask!)
        //              uploadFiles(uploadTask: uploadTask , count : uploadCount)
        
        
    }
}

func saveDataToDataBase( date : String ,currentUser : CurrentUser , lessonName : String ,_ type : String ,_ data : Data ,_ uploadCount : Int,_ imagesCount : Int, completion : @escaping(String) ->Void){
    let metaDataForData = StorageMetadata()
    let dataName = Date().millisecondsSince1970.description
    
    if type == DataTypes.doc.description
    {
        metaDataForData.contentType = DataTypes.doc.contentType
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.doc.mimeType)
        uploadTask = storageRef.putData(data, metadata: metaDataForData) { (metaData, err) in
            if err != nil
            {  print("err \(err as Any)") }
            else {
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.doc.mimeType).downloadURL { (url, err) in
                        guard let dataUrl = url?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        completion(dataUrl)
                        
                }
            }
            
        }
        //        observeUploadTaskFailureCases(uploadTask : uploadTask!)
        //        uploadFiles(uploadTask: uploadTask! , count : uploadCount , percentTotal: 5 , data: data)
        
        
    }else if type == DataTypes.pdf.description
    {
        metaDataForData.contentType = DataTypes.pdf.contentType
        
        metaDataForData.contentType = DataTypes.pdf.contentType
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.pdf.mimeType)
        uploadTask = storageRef.putData(data, metadata: metaDataForData) { (metaData, err) in
            if err != nil
            {  print("err \(err as Any)") }
            else {
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.pdf.mimeType).downloadURL { (url, err) in
                        guard let dataUrl = url?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        
                        completion(dataUrl)
                        
                }
            }
            
        }
        //        observeUploadTaskFailureCases(uploadTask : uploadTask!)
        //        uploadFiles(uploadTask: uploadTask! , count : uploadCount , percentTotal: 5 , data: data)
        //
    }else if type == DataTypes.pptx.description
    {
        metaDataForData.contentType = DataTypes.pptx.contentType
        
    }else if type == DataTypes.image.description
    {
        metaDataForData.contentType = DataTypes.image.contentType
        
        
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType)
        
        uploadTask = storageRef.putData(data, metadata: metaDataForData) { (metaData, err) in
            if err != nil
            {  print("err \(err as Any)") }
            else {
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
                        guard let dataUrl = url?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        completion(dataUrl)
                }
            }
            
        }
        
    }
    //    observeUploadTaskFailureCases(uploadTask : uploadTask!)
                 uploadFiles(uploadTask: uploadTask! , count : uploadCount , percentTotal: 5 , data: data)
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
func uploadFiles(uploadTask : StorageUploadTask , count : Int , percentTotal : Float , data : Data)
{
    //    uploadTask.observe(.progress) {  snapshot in
    //        print(snapshot.progress as Any) //
    //        print("dosya \(count) yükleniyor")
    //        let percentComplete = (100.0 * Float(snapshot.progress!.completedUnitCount)
    //            / (percentTotal * 1024 * 1024)) + totalCompletedData
    //        print("upload : \(percentComplete)")
    //        SVProgressHUD.showProgress(percentComplete, status: "\(percentTotal) MB % \(Int(percentComplete))")
    //    }
    uploadTask.observe(.progress) {  snapshot in
        print(snapshot.progress as Any) //
        
        let percentComplete = 100.0 * Float(snapshot.progress!.completedUnitCount)
            / Float(snapshot.progress!.totalUnitCount)
        print("upload : \(percentComplete )")
        SVProgressHUD.showProgress(percentComplete / 100, status: "\(Float(snapshot.progress!.totalUnitCount / 1_24) / (1000 * 1000)) MB % \(Int(percentComplete))")
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
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

struct DatasUrl {
    let url : String!
    let type : String!
    
}
extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}
struct Queue<T> {
  private var elements: [T] = []

  mutating func enqueue(_ value: T) {
    elements.append(value)
  }

  mutating func dequeue() -> T? {
    guard !elements.isEmpty else {
      return nil
    }
    return elements.removeFirst()
  }

  var head: T? {
    return elements.first
  }

  var tail: T? {
    return elements.last
  }
}
