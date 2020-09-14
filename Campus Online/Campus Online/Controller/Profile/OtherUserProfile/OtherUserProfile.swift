//
//  OtherUserProfile.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class OtherUserProfile: UIViewController {

    var currentUser : CurrentUser
    var otherUser : OtherUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        navigationItem.title = otherUser.username
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
    }
    
    init(currentUser : CurrentUser, otherUser : OtherUser) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- selector
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
