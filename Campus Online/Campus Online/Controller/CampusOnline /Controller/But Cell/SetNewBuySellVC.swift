//
//  SetNewBuySellVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 9.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class SetNewBuySellVC: UIViewController {

    
    var currentUser : CurrentUser
    var followers = [String]()
    
    //MARK:- lifeCycle
    init(currentUser : CurrentUser , followers : [String]){
        self.currentUser = currentUser
        self.followers = followers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()
        navigationItem.title = "Yeni Bir İlan Ver"
        
    }
}
