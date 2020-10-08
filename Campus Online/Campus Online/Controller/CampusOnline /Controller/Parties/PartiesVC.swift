//
//  PartiesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class PartiesVC: UIViewController {
    
    var currentUser : CurrentUser
    
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
    }
    


}
