//
//  NotificationSetting.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class NotificationSetting: UIViewController {

    var barTitle : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.title = barTitle ?? ""
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(dismis))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")!, style: .plain, target: self, action: #selector(dismis))
        }
        
    }
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
