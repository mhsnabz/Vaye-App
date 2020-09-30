//
//  NotificationVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellId = "NotificaitionCell"
class NotificationVC: UIViewController {
    var currentUser : CurrentUser
    var model = [NotificationModel]()
    
   weak var listener : ListenerRegistration?
    
    //MARK: -properties
    var tableView : UITableView = {
       let tableView = UITableView()
       tableView.separatorStyle = .none
       tableView.backgroundColor = .white
        
       return tableView
   }()
    
    //MARK: - lifeCycle
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationBar()
        navigationItem.title = "Bildirimler"
        get_notification(currentUser: currentUser)
   
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    //MARK: - functions
  
    private func configureTableViewController(){
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(NotificaitionCell.self, forCellReuseIdentifier: cellId)
    }
    func get_notification(currentUser : CurrentUser )
    {
        
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification")
        
        listener = db.addSnapshotListener {[weak self] (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    return
                }
                guard let sself = self else { return }
                for item in snap.documentChanges {
                    if item.type == .added {
                        sself.model.append(NotificationModel.init(not_id: item.document.get("not_id") as! String, dic: item.document.data()))
                        sself.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    

}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificaitionCell
        cell.model = model[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
