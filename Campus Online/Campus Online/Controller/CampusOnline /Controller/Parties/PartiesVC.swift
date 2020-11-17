//
//  PartiesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
import FirebaseFirestore
class PartiesVC: UIViewController {
    
    var currentUser : CurrentUser
    var followers = [String]()
    let label : UILabel = {
       let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    lazy var msg_text : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
    
   
        return name
    }()
    
    //MARK: - lifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "

        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Etkinlikler"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        UserService.shared.getFollowers(uid: currentUser.uid) {[weak self] (user) in
            if let sself = self{
                sself.followers = user
            }
          
        }
        view.backgroundColor = .collectionColor()
    }
    
    //MARK:-functions
    

}
