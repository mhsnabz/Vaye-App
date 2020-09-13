//
//  ActionSheetHomeLaunher.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 13.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
class ActionSheetHomeLauncher : NSObject {
    //MARK: -properties
        private let currentUser : CurrentUser
        private let target : String
        private let tableView = UITableView()
        private var window : UIWindow?
        private lazy var viewModel = ActionSheetHomeViewModel(currentUser: currentUser, target: target)
        weak var delegate : ActionSheetHomeLauncherDelegate?
        private var tableViewHeight : CGFloat?
        
        private lazy var cancelButton : UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Vazgeç", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.clipsToBounds = true
            button.backgroundColor = .cancelColor()
            button.titleLabel?.font = UIFont(name: Utilities.font, size: 18)
            
            button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
            return button
        }()
        private lazy var footerView : UIView = {
           let view = UIView()
            view.addSubview(cancelButton)
            cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            cancelButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 0)
            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            cancelButton.layer.cornerRadius = 20
            return view
        }()
        
        private lazy var blackView : UIView = {
           let view = UIView()
            view.alpha = 0
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
            view.addGestureRecognizer(tap)
            return view
        }()
        
        
        init(currentUser : CurrentUser , target : String) {
            self.currentUser = currentUser
            self.target = target
            super.init()
            configureTableView()
        }
        //MARK:- helper
        fileprivate  func showTableView(_ shouldShow : Bool)
        {
            guard let window = window else { return }
            guard let heigth = tableViewHeight else { return }
            let y = shouldShow ? window.frame.height - heigth : window.frame.height
            tableView.frame.origin.y = y
            
            if !shouldShow {
                self.blackView.removeFromSuperview()
            }
            
        }
        
        func show(){
            guard let window = UIApplication.shared.windows.first(where: { ($0.isKeyWindow)}) else { return }
            self.window = window
            window.addSubview(blackView)
            blackView.frame = window.frame
            
            window.addSubview(tableView)
            let heigth = CGFloat( viewModel.imageOptions.count * 50 ) + 60
            self.tableViewHeight = heigth
            tableView.frame = CGRect(x: 0, y: window.frame.height,
                                     width: window.frame.width, height: heigth)
            UIView.animate(withDuration: 0.5) {
                self.blackView.alpha = 1
                self.tableView.frame.origin.y -= heigth
                
            }
            
        }
        func configureTableView()
        {
            tableView.backgroundColor = .white
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 50
            tableView.separatorStyle = .none
            tableView.layer.cornerRadius = 5
            tableView.isScrollEnabled = false
            tableView.register(ActionSheetHomeCell.self, forCellReuseIdentifier: "id")
          
        }
        @objc  func handleDismiss(){
            UIView.animate(withDuration: 0.5) {
                let heigth = CGFloat( self.viewModel.imageOptions.count * 50 ) + 60
                self.blackView.alpha = 0
                self.tableView.frame.origin.y += heigth
              
            }
        }
    }

extension ActionSheetHomeLauncher : UITableViewDataSource,UITableViewDelegate {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewModel.imageOptions.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "id",for: indexPath) as! ActionSheetHomeCell
         cell.options = viewModel.imageOptions[indexPath.row]
         return cell
     }
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 60
     }
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         return footerView
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let option = viewModel.imageOptions[indexPath.row]
         delegate?.didSelect(option: option)
         UIView.animate(withDuration: 0.5, animations: {
                 self.blackView.alpha = 0
                 self.showTableView(false)
         }) { (_) in
              self.tableView.reloadData()
             self.delegate?.didSelect(option: option)
         }
     }
}
