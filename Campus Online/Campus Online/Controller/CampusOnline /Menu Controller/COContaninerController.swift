//
//  COContaninerController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
class COContainerController : UIViewController{
    
    var menuController : COMenuController!
    var centrelController : UIViewController!
    var currentUser : CurrentUser
    public var isExanded = false
    
    
    //MARK: -lideCycle
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeContainerController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

    }
    
    //MARK:-functions
    
    func configureHomeContainerController(){
        let homeController = CampusOnlineVC(currentUser: currentUser)
        homeController.delegate = self
        centrelController = UINavigationController(rootViewController: homeController)
        view.addSubview(centrelController.view)
        addChild(centrelController)
        centrelController.didMove(toParent: self)
    }
    
    func configureMenuController()  {
        if menuController == nil {
            self.menuController = COMenuController(currentUser : currentUser)
            menuController.delegate = self
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
            print("added menu controller")
        }
    }
    func showMenuController(shouldExpand : Bool ,  menuOption  : COMenuOption?){
        if shouldExpand {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centrelController.view.frame.origin.x = self.centrelController.view.frame.width - 80
                self.centrelController.view.layer.shadowColor = UIColor.darkGray.cgColor
                self.centrelController.view.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.centrelController.view.layer.shadowRadius = 2
                self.centrelController.view.layer.shadowOpacity = 0.8
                self.centrelController.view.layer.masksToBounds = false

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
    func didSelectMenuOption (menuOPtion : COMenuOption){
        switch menuOPtion {
        
        case .fallowing:
          break
        case .party:
            let vc = PartiesVC(currentUser : currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .foodme:
            let vc = FoodMe(currentUser : currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        case .al_sat:
            let vc = BuyAndCellVC(currentUser : currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        case .camp :
            let vc = CampVC(currentUser : currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
extension COContainerController : CoControllerDelegate {
    func handleMenuToggle(forMenuOption menuOption: COMenuOption?) {
        if !isExanded{
            configureMenuController()
        }
        isExanded = !isExanded
        showMenuController(shouldExpand: isExanded, menuOption: menuOption)
    }
}
