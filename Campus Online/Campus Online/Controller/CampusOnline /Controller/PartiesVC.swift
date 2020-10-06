//
//  PartiesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class PartiesVC: UIViewController {
    weak var delegate : CoControllerDelegate?
    var isMenuOpen : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Etkinlikler"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    


}
