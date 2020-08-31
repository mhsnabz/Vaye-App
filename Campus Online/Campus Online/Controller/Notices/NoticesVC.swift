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
    var currentUser : CurrentUser?{
        didSet{
            navigationItem.title = (currentUser?.short_school)! + " Duyuru"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
            self.navigationController?.navigationBar.isHidden = false
                 self.view.backgroundColor = .white
        

        navigationItem.title = barTitle ?? ""
        self.navigationController?.navigationBar.topItem?.title = " "
        setNavigationBar()

        UserService.shared.fetchUser { [weak self](currentUser) in
            self?.currentUser = currentUser
        }
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


