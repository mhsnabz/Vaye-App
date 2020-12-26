//
//  StudentListTB.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class StudentListTB: UITableViewController {

    var currentUser : CurrentUser
    var stundetList : [String]
    lazy var list = [OtherUser]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        navigationItem.title = "Öğrenci Listesi"
        tableView.register(SingleStudentCell.self, forCellReuseIdentifier: "id")
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        for item in stundetList{
            UserService.shared.getOtherUser(userId: item) {[weak self] (user) in
                guard let sself = self else { return }
                sself.list.append(user)
                sself.tableView.reloadData()
                
            }
        }
        
      
    }

    init(currentUser : CurrentUser , studentList : [String]) {
        self.currentUser = currentUser
        self.stundetList = studentList
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source

   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! SingleStudentCell
        cell.user = list[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Utilities.waitProgress(msg: nil)
        UserService.shared.getProfileModel(otherUser: list[indexPath.row], currentUser: currentUser) {[weak self] (model) in
            guard let sself = self else { return }
            UserService.shared.checkOtherUserSocialMedia(otherUser: sself.list[indexPath.row]) { (val) in
                if val {
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: sself.list[indexPath.row], profileModel: model, width: 285)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()
                }else{
                    let vc = OtherUserProfile(currentUser: sself.currentUser, otherUser: sself.list[indexPath.row], profileModel: model, width: 235)
                    sself.navigationController?.pushViewController(vc, animated: true)
                    Utilities.dismissProgress()

                }
            }
            
        }
        
    }
    

}
