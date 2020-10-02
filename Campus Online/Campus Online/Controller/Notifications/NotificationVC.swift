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
    weak var notificaitonListener : ListenerRegistration?
    //MARK: -properties
    var tableView : UITableView = {
       let tableView = UITableView()
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
        configureTableViewController()
   
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
        notificaitonListener?.remove()
     
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        notificaitonListener?.remove()
      
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model = [NotificationModel]()
        get_notification(currentUser: currentUser)
        getNotificationCount()
        
    }
    
    
    //MARK: - functions
  
    private func getNotificationCount(){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601502870421
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("notification").whereField("isRead", isEqualTo: false)
        notificaitonListener = db.addSnapshotListener({[weak self] (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else { return }
                guard let sself = self else {
                    self?.tabBarController?.tabBar.items?[2].badgeValue = nil
                    return
                }
                if snap.isEmpty {
                   sself.tabBarController?.tabBar.items?[2].badgeValue = nil
                }else{
                    sself.tabBarController?.tabBar.items?[2].badgeValue = snap.documents.count.description
                }
            }
        })
    }
    
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
        ///user/2YZzIIAdcUfMFHnreosXZOTLZat1/notification/1601492948.048019
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("notification")
       
        
        listener = db.addSnapshotListener {[weak self] (querySnap, err) in
            if err == nil {
                guard let snap = querySnap?.documentChanges else {
                    return
                }
                guard let sself = self else { return }
                
                
                snap.forEach({ (diff) in
                        print(diff.document.data())
                        if (diff.type == .added) {
                            sself.model.append(NotificationModel.init(not_id: diff.document.get("not_id") as! String, dic: diff.document.data()))
                            sself.model.sort { (model1, model2) -> Bool in
                                return model1.not_id > model2.not_id
                            }
                            sself.tableView.reloadData()
                        }
                        else if (diff.type == .modified)
                        {

                        }
                        else if (diff.type == .removed)
                        {
                            sself.model.removeAll(where: {$0.not_id == diff.document.documentID})
                            sself.tableView.reloadData()
                        }
                   })
                

            }
        }
        
    }
    
    

}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificaitionCell
        cell.model = model[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let h = model[indexPath.row].type.height(withConstrainedWidth: view.frame.width - 78, font: UIFont(name: Utilities.font, size: 13)!)
        if h < 25 {
            return 62
        }else{
            return 25 + h + 5
        }
    }
    
    
    
}
