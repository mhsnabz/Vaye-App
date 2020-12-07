//
//  HastagModel.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD
class NoticesService {
    
    static let shared  = NoticesService()
    
    let hastag_iste =  [
        "Atatürkçü Düşünce Öğrenci Topluluğu","Bağımlılıkla Mücadele Öğrenci Topluluğu","Bilim Kadınları Öğrenci Topluluğu",
        "Bilim Ve Çocuk Öğrenci Topluluğu","Bilimsel Araştırmalar Öğrenci Topluluğu","Bireysel Sporlar Öğrenci Topluluğu"
        ,"Bisiklet Öğrenci Topluluğu","Çevre Öğrenci Topluluğu","Doğa Sporları Öğrenci Topluluğu","Edebiyat Öğrenci Topluluğu","Ekonomi Öğrenci Topluluğu","Fotoğrafçılık Öğrenci Topluluğu","Gezi Öğrenci Topluluğu","Gönüllü Genç Sağlık Liderleri Öğrenci Topluluğu","Güzel Sanatlar Öğrenci Topluluğu","Halk Dansları Öğrenci Topluluğu",
        "Havacılık Öğrenci Topluluğu","Hayvanları Koruma Öğrenci Topluluğu","Hidrojen Teknolojileri Öğrenci Topluluğu","İSTE-IEEE Öğrenci Topluluğu","İSTE Endüstri Öğrenci Topluluğu","İSTE E-Spor Öğrenci Topluluğu",
        "İSTE Genç Tema Öğrenci Topluluğu","İSTE İzcilik Öğrenci Topluluğu","İSTE-Spe Öğrenci Topluluğu","İSTE-Engelsiz Öğrenci Topluluğu","Karikatür Ve Mizah Öğrenci Topluluğu","Kültür Ve Sanat Öğrenci Topluluğu","Matematik Öğrenci Topluluğu","Mekatronik Öğrenci Topluluğu","Metalurji Öğrenci Topluluğu","Müzik Öğrenci Topluluğu","Ombudsmanlık Öğrenci Topluluğu","Radyo Ve Televizyon Öğrenci Topluluğu","Resim Öğrenci Topluluğu", "Robotik Öğrenci Topluluğu","Satranç Öğrenci Topluluğu","Savunma SanayiTeknolojileri Öğrenci Topluluğu","Sinema Öğrenci Topluluğu","Sosyal Sorumluluk Öğrenci Topluluğu","Sualtı Öğrenci Topluluğ","Takım Sporları Öğrenci Topluluğu"," Tasarım Öğrenci Topluluğu" ,"Teknoloji Öğrenci Topluluğu","Tiyatro Öğrenci Topluluğu","Turizm Öğrenci Topluluğu","Türk Tarihi Araştırma Öğrenci Topluluğu","Uluslararası İlişkiler Öğrenci Topluluğu","Uluslararası İlişkiler Öğrenci Topluluğu","Üniversite-Sanayi İşbirliği Öğrenci Topluluğu","Üniversite-Sanayi İşbirliği Öğrenci Topluluğu","Yelken Öğrenci Topluluğu","Yenilikçilik Ve Girişimcilik Öğrenci Topluluğu" ] as [String]
    
    
    func getHastag(currentUser : CurrentUser) -> [String]{
        if currentUser.short_school == "İSTE" {
            return hastag_iste
        }else{
            return []
        }
    }
    
    
    func setNewNotice(currentUser : CurrentUser,postType: String,clupName : String, postId : String , msgText : String , datas :[String] , short_school : String , completion : @escaping(Bool)->Void){
        let dic = [
            "postTime":FieldValue.serverTimestamp(),
            "senderName":currentUser.name as Any,
            "text":msgText,
            "likes":[],
            "comment":0,
            "clupName":clupName,
            "senderUid":currentUser.uid as Any,
            "dislike":[],
            "postId":postId,
            "postID":Int64(postId) as Any,
            "data":datas,
            
            "thumbData":[],
            "username": currentUser.username as Any,
            "thumb_image": currentUser.thumb_image as Any,
            "silent":[],
            "postType":postType,
        ] as [String : Any]
        setNewNotices(dic: dic, currentUser: currentUser, postId: postId) { (_) in
            completion(true)
        }
        setPostForCurrentUser(postId: postId, currentUser: currentUser)
    }
    
    //İSTE/notices/post
    func setPostForCurrentUser(postId : String , currentUser : CurrentUser){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection(currentUser.short_school)
            .document(postId)
        db.setData(["postId":postId], merge: true, completion: nil)
        
    }
    
    func setNewNotices( dic : [String : Any] ,currentUser : CurrentUser, postId : String , completion : @escaping(Bool)->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(postId)
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                completion(true)
            }
        }
    }
    var totalCompletedData : Float = 0
    var uploadTask : StorageUploadTask?
    
    func uploadToDataBase(postDate : String,clupName : String ,currentUser : CurrentUser ,postType : String, type : [String] , data : [Data] , completion : @escaping([String]) -> Void ){
        save_datas(date: postDate, clupName: clupName, currentUser: currentUser, postType: postType, type: type, datas: data) { (listOfUrl) in
            print("url \(listOfUrl)")
            completion(listOfUrl)
        }
    }
    func save_datas ( date : String ,clupName : String,currentUser : CurrentUser , postType : String , type : [String] , datas : [Data] ,completionHandler: @escaping ([String]) -> () ){
        var uploadedImageUrlsArray = [String]()
        var uploadCount = 0
        let imagesCount = datas.count
        let semaphore = DispatchSemaphore(value: 1)
        for data  in 0..<(datas.count) {
            Utilities.waitProgress(msg: "\(imagesCount) Resim Yükleniyor\n Lütfen Bekleyiniz")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+5) {
                semaphore.wait()
                self.saveDataToDataBase(date: date, clupName:clupName , currentUser: currentUser, postType: clupName, type[data], datas[data], uploadCount, imagesCount) {[weak self] (url) in
                    uploadedImageUrlsArray.append(url)
                    uploadCount += 1
                    print("Number of images successfully uploaded: \(uploadCount)")
                    guard let sself = self else { return }
                    Utilities.waitProgress(msg: "\(uploadCount). Resim Yüklendi")
                    if uploadCount == imagesCount{
                        sself.getThumbİmage(date: date, clupName: clupName, currentUser: currentUser, postType: postType, type[data], datas[data]) { (_) in
                            completionHandler(uploadedImageUrlsArray)
                            SVProgressHUD.showSuccess(withStatus: "Bütün Resimler Yüklendi")
                            semaphore.signal()
                            
                        }
                    }else{
                        sself.getThumbİmage(date: date, clupName: clupName, currentUser: currentUser, postType: postType, type[data], datas[data]) { (_) in
                            semaphore.signal()
                        }
                    }
                }
            }
        }
    }
    
    func saveDataToDataBase( date : String ,clupName : String,currentUser : CurrentUser , postType : String ,_ type : String ,_ data : Data ,_ uploadCount : Int,_ imagesCount : Int, completion : @escaping(String) ->Void){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        if type == DataTypes.image.description
        {
            metaDataForData.contentType = DataTypes.image.contentType
            //İSTE/clup/clupname
            let storageRef  = Storage.storage().reference().child(currentUser.short_school)
                .child("clup").child(clupName)
                .child(currentUser.username)
                .child(date)
                .child(dataName + DataTypes.image.mimeType)
            
            
            
            uploadTask = storageRef.putData(data, metadata: metaDataForData) { (metaData, err) in
                if err != nil
                {  print("err \(err as Any)") }
                else {
                    Storage.storage().reference().child(currentUser.short_school)
                        .child("clup").child(clupName)
                        .child(currentUser.username)
                        .child(date)
                        .child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
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
    func getThumbİmage( date : String ,clupName : String,currentUser : CurrentUser , postType : String ,_ type : String ,_ data : Data , completion : @escaping(Bool) ->Void){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        
        if type == DataTypes.image.description
        {
            metaDataForData.contentType = DataTypes.image.contentType
            
            
            let storageRef = Storage.storage().reference().child("\(currentUser.short_school!) + thumb").child(clupName).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType)
            //        let thumbData = data.jpegData(compressionQuality: 0.8) else { return }
            let image : UIImage = UIImage(data: data)!
            guard let uploadData = resizeImage(image: image, targetSize: CGSize(width: 128, height: 128)).jpegData(compressionQuality: 1) else { return }
            uploadTask = storageRef.putData(uploadData, metadata: metaDataForData) { (metaData, err) in
                if err != nil
                {  print("err \(err as Any)") }
                else {
                    Storage.storage().reference().child("\(currentUser.short_school!) + thumb").child(clupName).child(currentUser.username).child(date).child(dataName + DataTypes.image.mimeType).downloadURL { (url, err) in
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
    func setThumbDatas(currentUser : CurrentUser, postId : String ,completion : @escaping(Bool)->Void){
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
                    self?.moveThumbDatas(currentUser: currentUser, array: data,  postId: postId) { (_) in
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
        ///main-post/sell-buy/post/1603357054085
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(postId)
        
        
        for item in array{
            db.updateData(["thumbData":FieldValue.arrayUnion([item as String])]) { (err) in
                if err == nil {
                    
                }
            }
        }
        completion(true)
    }
    
    //İSTE/notices/post/1607178880372
    
    func like(target : String ,tableView : UITableView!,currentUser : CurrentUser, post : NoticesMainModel! , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                //main-post/sell-buy/post/1603357054085
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            completion(true)
                            //                            NotificaitonService.shared.send_mainpost_like_notification(post: post, currentUser: currentUser, text: Notification_description.like_sell_buy.desprition, type: NotificationType.like_sell_buy.desprition)
                        }
                    }
                }
            }
        }
        else{
            post.likes.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {(err) in
                    completion(true)
                    //                    NotificaitonService.shared.mainpost_remove_like_notification(post: post, currentUser: currentUser)
                }
            }
        }
    }
    func dislike(target : String ,tableView : UITableView!,currentUser : CurrentUser, post : NoticesMainModel! , completion : @escaping(Bool) ->Void){
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            
                            completion(true)
                        }
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            tableView.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
                }}}
    }
    
    func setPostLike(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : NoticesMainModel! , completion : @escaping(Bool) ->Void){
        if !post.likes.contains(currentUser.uid){
            post.likes.append(currentUser.uid)
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                //main-post/sell-buy/post/1603357054085
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            completion(true)
                            //                            NotificaitonService.shared.send_mainpost_like_notification(post: post, currentUser: currentUser, text: Notification_description.like_sell_buy.desprition, type: NotificationType.like_sell_buy.desprition)
                        }
                    }
                }
            }
        }
        else{
            post.likes.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) {(err) in
                    completion(true)
                    //                    NotificaitonService.shared.mainpost_remove_like_notification(post: post, currentUser: currentUser)
                }
            }
        }
    }
    
    func setDislike(target : String ,collectionview : UICollectionView!,currentUser : CurrentUser, post : NoticesMainModel! , completion : @escaping(Bool) ->Void){
        if !post.dislike.contains(currentUser.uid){
            post.likes.remove(element: currentUser.uid)
            post.dislike.append(currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayUnion([currentUser.uid as String])]) { (err) in
                    if err == nil {
                        db.updateData(["likes":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                            
                            completion(true)
                        }
                    }
                }
            }
        }else{
            post.dislike.remove(element: currentUser.uid)
            collectionview.reloadData()
            UserService.shared.fetchOtherUser(uid: post.senderUid) {(user) in
                let db = Firestore.firestore().collection(user.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["dislike":FieldValue.arrayRemove([currentUser.uid as String])]) { (err) in
                    completion(true)
                }}}
    }
    
    func deleteToStorage(data : [String], postId : String , completion : @escaping(Bool) -> Void){
        if data.count == 0{
            completion(true)
            return
        }
        for item in data{
            let ref = Storage.storage().reference(forURL: item)
            ref.delete { (err) in
                completion(true)
            }
        }
    }
    
    func deleteData(index : IndexPath,post : NoticesMainModel , currentUser : CurrentUser , collectionview : UICollectionView , url : String){
        Utilities.waitProgress(msg: "Siliniyor")
        let storage = Storage.storage()
        let r = storage.reference(forURL: url)
        r.delete { (err) in
            if err == nil {
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["data":FieldValue.arrayRemove([url as Any])]) {[weak self] (err) in
                    if err == nil {
                        guard let sself = self else { return }
                        if let index = post.data.firstIndex(of: url){
                            post.data.remove(at: index)
                            collectionview.reloadData()
                        }
                        sself.removeThumbData(currentUser: currentUser, post: post, index: index) { (_) in
                            collectionview.reloadData()
                        }
                    }
                    
                }
            }else{
                print("err \(err?.localizedDescription as Any)")
                Utilities.errorProgress(msg: "Hata Oluştu")
                return
            }
        }
    }
    func removeThumbData(currentUser  : CurrentUser , post : NoticesMainModel ,  index : IndexPath , completion : @escaping(Bool) ->Void){
        let url = post.thumbData[index.row]
        let storage = Storage.storage()
        let r = storage.reference(forURL: url)
        r.delete { (err) in
            if err == nil {
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("notices")
                    .collection("post")
                    .document(post.postId)
                db.updateData(["thumbData":FieldValue.arrayRemove([url as Any])]) { (err) in
                    if err == nil {
                        if let index = post.thumbData.firstIndex(of: url) {
                            Utilities.succesProgress(msg: "Dosya Silindi")
                           post.thumbData.remove(at: index)
                           completion(true)

                        }
                    }else{
                        print("err \(err?.localizedDescription as Any)")
                    }
                }
            }else{
                print("err \(err?.localizedDescription as Any)")
            }
        }
    }
    
    func updatePost(post : NoticesMainModel ,text : String  ,currentUser : CurrentUser, completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("notices")
            .collection("post")
            .document(post.postId)
        let dic = ["text" : text] as [String : Any]
        db.setData(dic, merge: true) { (err) in
            if err == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
}
