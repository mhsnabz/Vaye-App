//
//  StudentNewPost.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class StudentNewPost: UIViewController {

    var currentUser : CurrentUser
    var selectedLesson : String? {
        didSet {
            navigationItem.title = selectedLesson
        }
    }
    
    //MARK:- lifeCycle
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       setNavigationBar()
        view.backgroundColor = .white
        
    }
    


}
