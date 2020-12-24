//
//  ContainerController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
class ContainerController: UIViewController {
    var menuController : MenuController!
    var centrelController : UIViewController!
    var currentUser : CurrentUser
    public var isExanded = false
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)   
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureHomeContainerController()
        UserService.shared.fetchUser {[weak self] (currentUser) in
            self?.currentUser = currentUser
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    func configureHomeContainerController(){
        let homeController = HomeController(currentUser: currentUser)
       
        homeController.delegate = self

        centrelController = UINavigationController(rootViewController: homeController)
        view.addSubview(centrelController.view)
        addChild(centrelController)
        centrelController.didMove(toParent: self)
    }
    func configureMenuController()  {
        if menuController == nil {
            self.menuController = MenuController(currentUser : currentUser)
            menuController.delegate = self
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
            print("added menu controller")
        }
    }
    func showMenuController(shouldExpand : Bool ,  menuOption  : MenuOption?){
        if shouldExpand {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centrelController.view.frame.origin.x = self.centrelController.view.frame.width - 80
                self.centrelController.view.layer.shadowColor = UIColor.darkGray.cgColor
                self.centrelController.view.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.centrelController.view.layer.shadowRadius = 2
                self.centrelController.view.layer.shadowOpacity = 0.8
                self.centrelController.view.layer.masksToBounds = false
//                self.centrelController.view.layer.shadowOpacity = 0.8
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centrelController.view.frame.origin.x = 0
                      self.centrelController.view.layer.shadowOpacity = 0.0
            }) { (_) in
                guard let menuOption = menuOption else{return}
                self.didSelectMenuOption(menuOPtion: menuOption)
            }
            
        }
        
    }
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

       if #available(iOS 13, *), self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {

        self.centrelController.view.layer.shadowColor =
                  UIColor.label.resolvedColor(with: self.traitCollection).cgColor
       }
    }
    func didSelectMenuOption (menuOPtion : MenuOption){
        switch menuOPtion {
        case .major:
            
            break
//        case .school_notices:
//
//
//            break
        case .not:
            let vc = NotificationSetting(currentUser : currentUser)

            vc.modalPresentationStyle = .fullScreen
            self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            break
        case .set:
            let vc = Setting(currentUser : currentUser)
            vc.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                     vc.isModalInPresentation = true
                 } else {
                     // Fallback on earlier versions
                 }
                 
            self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            break
        case .rate:
            break
        case .logout:
            do {
                Utilities.waitProgress(msg: "Çıkış Yapılıyor")
                try  Auth.auth().signOut()
                let vc = SplashScreen()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true) {
                    Utilities.dismissProgress()
                }
            }
            catch {
                print("err : \(error.localizedDescription.description)")
            }
        
            break
        }
        
    }
}
extension ContainerController : HomeControllerDelegate {
    func handleMenuToggle(forMenuOption menuOption: MenuOption?) {
        
        if !isExanded{
            configureMenuController()
        }
        isExanded = !isExanded
        showMenuController(shouldExpand: isExanded, menuOption: menuOption)
    }
      
}
