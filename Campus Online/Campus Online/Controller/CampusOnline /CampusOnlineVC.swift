//
//  CampusOnlineVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class CampusOnlineVC: UIViewController{

    var currentUser : CurrentUser
    weak var delegate : CoControllerDelegate?
    var isMenuOpen : Bool = false
    
    
      init(currentUser : CurrentUser){
          self.currentUser = currentUser
          super.init(nibName: nil, bundle: nil)
      
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        view.backgroundColor = .collectionColor()
        navigationItem.title = "Online Kampüs"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
     
    }
    
    
    
    //MARK:-selectors
    @objc func menuClick(){
        print("work click")
        self.delegate?.handleMenuToggle(forMenuOption: nil)
        if !isMenuOpen {
            self.isMenuOpen = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        }
        else{
            self.isMenuOpen = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(menuClick))
        }
    }
}

