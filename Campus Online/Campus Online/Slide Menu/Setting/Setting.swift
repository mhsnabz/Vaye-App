//
//  Setting.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class Setting: UIViewController {

    var barTitle : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = barTitle ?? ""
        self.navigationController?.navigationBar.topItem?.title = " "

     }
}
