//
//  NoticesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class NoticesVC: UIViewController {
    var delegate : HomeControllerDelegate?
    var isMenuOpen : Bool = false
    var barTitle: String?

    var currentUser : CurrentUser
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
       
        setNavigationBar()
        navigationItem.title = currentUser.short_school + "Kulüp"
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     @objc func menuClick(){
        print("deneme")
//        dismiss(animated: true, completion: nil)
            self.delegate?.handleMenuToggle(forMenuOption: nil)
            if !isMenuOpen {
                self.isMenuOpen = false
            }
            else{
             self.isMenuOpen = true

         }
        }

}


