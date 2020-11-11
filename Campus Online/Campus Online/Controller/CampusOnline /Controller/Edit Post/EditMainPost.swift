//
//  EditMainPost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 10.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
private let image_cell = "img"
import FirebaseStorage
import FirebaseFirestore
import MobileCoreServices
import SVProgressHUD
class EditMainPost: UIViewController {
    // MARK:-properties
    var collectionview: UICollectionView!
    var totolDataInMB : Float = 0.0
    var currentUser : CurrentUser
    var post : MainPostModel
    
    var h : CGFloat
    var link : String?
    var heigth : CGFloat = 0.0
    var data = [SelectedData]()
    var uploadTask : StorageUploadTask?
    
    
    //MARK:-lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        view.backgroundColor = .white
        navigationItem.title = "Gönderiyi Düzenle"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
    }
    
    init(currentUser : CurrentUser , post : MainPostModel , heigth : CGFloat ) {
        self.currentUser = currentUser
        self.post = post
        self.h = heigth
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -set navigation title
    //MARK:- selectors
    @objc func dismissVC(){
        dismiss(animated: true, completion: nil)
    }
    
}
