//
//  MainTabBarController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class MainTabbar: UITabBarController,UITabBarControllerDelegate  {
    
    var currentUser : CurrentUser!{
        didSet{
            let vc = ContainerController(currentUser: currentUser)
            vc.currentUser = currentUser
            guard let currentUser = currentUser else { return }
            configureViewControler(user: currentUser)
            
           
        }
    }
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        self.delegate = delegate
        
    }
 
    
    
    
    func configureViewControler(user : CurrentUser){
        let homeVC = setNavigationController(title: "Ana Sayfa", unselectedImage: UIImage(named: "home")!, selectedImage: UIImage(named: "home-selected")!,rootViewController: ContainerController(currentUser: user))
        let vaye_app = setNavigationController(title: "VayeApp",unselectedImage: #imageLiteral(resourceName: "c-unselected").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "c-selected").withRenderingMode(.alwaysOriginal),rootViewController: VayeApp(currentUser: user))
        let notificationVC = setNavigationController(title: "Bildirimler",unselectedImage: UIImage(named: "not")!, selectedImage: UIImage(named: "not-selected")!,rootViewController: LocalNotificationController(currentUser: user))
        let chatVC = setNavigationController(title: "Sohbet",unselectedImage: UIImage(named: "chat")!, selectedImage: UIImage(named: "chat-selected")!,rootViewController: MessagesVC(currentUser: user))
        
        viewControllers = [homeVC,vaye_app,notificationVC,chatVC]
        
        tabBar.tintColor = UIColor.black
        tabBar.backgroundColor = .white
    }
    func setNavigationController (title : String ,unselectedImage : UIImage ,selectedImage : UIImage, rootViewController : UIViewController = UIViewController())
        -> UINavigationController{
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.tabBarItem.selectedImage = selectedImage
            navController.tabBarItem.image = unselectedImage
            //                   navController.tabBarItem.image = selectedImage
            navController.title = title
            
            navController.navigationBar.isHidden = true
            
            return navController
    }
}
