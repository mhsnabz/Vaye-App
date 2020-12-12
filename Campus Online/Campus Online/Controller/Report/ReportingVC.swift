//
//  ReportingVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

enum ReportTarget {
    case foodMePost
    case buySellPost
    case homePost
    case campingPost
    case noticesPost
    var description : String {
        switch self{
        
        case .foodMePost:
            return "foodMe"
        case .buySellPost:
            return "buySellPost"
        case .homePost:
            return "homePost"
        case .campingPost:
            return "campingPost"
        case .noticesPost:
            return "noticesPost"
        }
    }
}

class ReportingVC: UIViewController {

    
    var target : String
    var currentUser : CurrentUser
    var postId : String
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.title = "Şikayetiniz Nedir?"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel-dark").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: #selector(dismisVC))
    
    }
    init(target : String , currentUser : CurrentUser , postId : String) {
        self.currentUser = currentUser
        self.target = target
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
