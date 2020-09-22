//
//  NewPostCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import PDFKit
import FirebaseFirestore
import FirebaseStorage
class NewPostImageCell: UICollectionViewCell {
    var uploadTask : StorageUploadTask?

    weak var delegate: DeleteImage?
    
    var data : DatasModel?
    
    let deleteBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "cancel")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let img : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = UIColor(white: 0.90, alpha: 0.7)
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(img)
        img.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        addSubview(deleteBtn)
        deleteBtn.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        deleteBtn.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func deleteImage(){
        delegate?.deleteImage(for: self)
    }
    
    //MARK:- upload to firebase
    private func upload(data : Data! , completion : @escaping(Bool) ->Void){
        
    }
    func saveDataToDataBase( date : String ,currentUser : CurrentUser , lessonName : String ,_ type : String ,_ data : Data , completion : @escaping(String) ->Void){
        let metaDataForData = StorageMetadata()
        let dataName = Date().millisecondsSince1970.description
        metaDataForData.contentType = DataTypes.image.contentType
        let storageRef = Storage.storage().reference().child(currentUser.short_school)
            .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + type)
        let image : UIImage = UIImage(data: data)!
        guard let uploadData = image.jpeg(.low) else { return }
        uploadTask = storageRef.putData(uploadData, metadata: metaDataForData, completion: { (result, err) in
            if err != nil
            {  print("err \(err as Any)") }
            else {
                Storage.storage().reference().child(currentUser.short_school)
                    .child(currentUser.bolum).child(lessonName).child(currentUser.username).child(date).child(dataName + type).downloadURL { (url, err) in
                        guard let dataUrl = url?.absoluteString else {
                            print("DEBUG :  Image url is null")
                            return
                        }
                        completion(dataUrl)
                }
            }
        })
    }

    private func setToCurrentUserTask(url : String,data : DatasModel!){
        let db = Firestore.firestore().collection("user")
            .document(data.currentUser.uid).collection("saved-task").document("task")
        db.updateData(["data":FieldValue.arrayUnion([url as Any])]) { (err) in
            if err == nil {
                print("complete")
            }else{
                print("err\(err?.localizedDescription as Any)")
            }
        }
        
    }
    
}
