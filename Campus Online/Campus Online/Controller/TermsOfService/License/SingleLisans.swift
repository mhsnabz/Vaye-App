//
//  SingleLisans.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class SingleLisans: UIViewController {

  var htmlString : String?
    
    let webView : UITextView = {
          let w = UITextView()
           w.isEditable = false
        w.font = UIFont(name: Utilities.font, size: 14)
        w.isScrollEnabled = true
           return w
       }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
     
        
        view.addSubview(webView)
        webView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 4, marginLeft: 4, marginBottom: 4, marginRigth: 4, width:0, heigth: 0)
               
        webView.attributedText = htmlString?.htmlToAttributedString
        // Do any additional setup after loading the view.
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
