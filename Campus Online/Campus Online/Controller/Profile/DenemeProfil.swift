//
//  DenemeProfil.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
private let header = "header"
class DenemeProfil: UIViewController {

    var currentUser : CurrentUser?
    var tableView : UITableView = {
       let tableView = UITableView(frame: .zero, style: .plain)
       tableView.separatorStyle = .none
       tableView.backgroundColor = .white
       
       return tableView
   }()
    
    var menuBar : MenuBar = {
       let v = MenuBar()
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
    }
    

    private func configureTableView(){
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DenemeCell.self, forCellReuseIdentifier: "id")
        tableView.register(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: header)
        self.tableView.sectionHeaderHeight = 285
        let dbc = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
        dbc.getDocument { (docSnap, err) in
            if err == nil {
                self.currentUser = CurrentUser.init(dic: (docSnap?.data())!)
                self.tableView.reloadData()
            }
        }
        
    }

}
extension DenemeProfil  : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! DenemeCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! DenemeCell
        return cell
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let _header = tableView.dequeueReusableHeaderFooterView(withIdentifier: header) as! TableViewHeader
            _header.currentUser = currentUser
            return _header
        }else if section == 1{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.addSubview(menuBar)
            menuBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
            return headerView

        }else {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.addSubview(menuBar)
            menuBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
            menuBar.profileModel =  ProfileModel(shortSchool: "ISTE", currentUser: currentUser!, major: "Bilgisayar Mühendisliği", uid: Auth.auth().currentUser!.uid)
            return headerView
        }
        
    }
}
