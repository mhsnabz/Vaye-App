//
//  COMenuController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 6.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
class COMenuController : UIViewController{
    var currentUser : CurrentUser
    var delegate : CoControllerDelegate?
    var tableView = UITableView(frame: .zero, style: .plain)
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    //MARK:- functions
    private func configureTableView(){
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 10, width: view.frame.width, height: view.frame.height)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.register(CoMenuCell.self, forCellReuseIdentifier: CoMenuCell.reuseIdentifier)
        tableView.register(CoMenuHeader.self, forHeaderFooterViewReuseIdentifier: CoMenuHeader.reuseIdentifier )
    }
    
}
extension COMenuController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoMenuCell.reuseIdentifier, for: indexPath) as! CoMenuCell
        cell.backgroundColor = .white
        let menuOption = COMenuOption(rawValue: indexPath.row)
        cell.homeBtn.setImage(menuOption?.image, for: .normal)
        cell.homeTitle.setTitle(menuOption?.description, for: .normal)
        cell.delegate = self
        cell.selectionStyle = .none
        cell.line.isHidden = true

        return cell
    }
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CoMenuHeader.reuseIdentifier) as! CoMenuHeader
        header.delegate = self
        return header
    }
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 125
    }
    
     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .white // Works!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = COMenuOption(rawValue: indexPath.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
    
}
extension COMenuController :  CoSlideMenuDelegate , CoSlideHeaderDelegate {
   
    
    func dismisMenu() {
        print("dismis")
    }
   
    func handleSlideMenuItems(for cell: CoMenuCell) {
        let menuOption = COMenuOption(rawValue: self.tableView.indexPath(for: cell)!.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
    
    
}

