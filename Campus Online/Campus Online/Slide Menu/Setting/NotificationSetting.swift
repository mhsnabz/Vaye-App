//
//  NotificationSetting.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class NotificationSetting: UITableViewController {

    var currentUser : CurrentUser
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setNavigationBar()
        navigationItem.title = "Anlık Bildirim Ayarları"
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(dismis))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow")!, style: .plain, target: self, action: #selector(dismis))
        }
        configureTB()
    }
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }

    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  //MARK:-funcitons
    func configureTB(){
        tableView.register(VayeAppNotificationCell.self, forCellReuseIdentifier: "id")
        tableView.separatorStyle = .none
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! VayeAppNotificationCell
        cell.selectionStyle = .none
        if indexPath.item == 0 {
            cell.titleLabel.text = "Bölüm Duyuruları"
             
            cell.textLbl.text = "Takip ettiğiniz derslerle alakalı yeni bir duyuru yapıldığında yada yeni bir not paylaşıldığında anlık bildirim alırsınız"
            cell.isOpen = currentUser.lessonNotices
        }
        else if indexPath.item == 1 {
            cell.titleLabel.text = "Yorumlar"
             
            cell.textLbl.text = "Biri gönderinize yorum yaptığında  yada yorumunuza cevap verdiğinde  anlık bildirim alırsınız"
            cell.isOpen = currentUser.comment
        }
       else if indexPath.item == 2 {
            cell.titleLabel.text = "Beğeni"
             
            cell.textLbl.text = "Biri gönderinizi yada  yorumunuzu beğendiğinde anlık bildirim alırsınız"
        cell.isOpen = currentUser.like
        }
       else if indexPath.item == 3 {
            cell.titleLabel.text = "Takip"
             
            cell.textLbl.text = "Biri sizi takip etmeye başladığında anlık bildirim alırsınız"
        cell.isOpen = currentUser.follow
        }
       
        else if indexPath.item == 4 {
            cell.titleLabel.text = "Etiket"
            cell.textLbl.text = "Biri sizden bir gönderide yada yorumda bahsettiğinde anlık bildirim alırsınız"
            cell.isOpen = currentUser.mention
        }
       
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! VayeAppNotificationCell
 
        if indexPath.item == 0 {
            
            if cell.switchButton.isOn {
                setNotification(isEnable: true, topic: "lessonNotices") { [weak self](_val) in
                    guard let sself = self else { return }
                    cell.switchButton.isOn = _val
                    sself.currentUser.lessonNotices = _val
                    
                    tableView.reloadData()
                    
                }
            }else{
                setNotification(isEnable: false, topic: "lessonNotices") { [weak self](_val) in
                    guard let sself = self else { return }
                    cell.switchButton.isOn = _val
                    sself.currentUser.lessonNotices = _val
                    tableView.reloadData()
                    
                }
            }
            
        }else if indexPath.item == 1{
            if cell.switchButton.isOn {
                setNotification(isEnable: true, topic: "comment") { [weak self](_val) in
                    guard let sself = self else { return }
                    sself.currentUser.comment = _val
                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }else{
                setNotification(isEnable: false, topic: "comment") { [weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.comment = _val
                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }
        }else if indexPath.item == 2{
            if cell.switchButton.isOn {
                setNotification(isEnable: true, topic: "like") { [weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.like = _val
                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }else{
                setNotification(isEnable: false, topic: "like") { [weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.like = _val

                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }
        }else if indexPath.item == 3{
            if cell.switchButton.isOn {
                setNotification(isEnable: true, topic: "follow") { [weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.follow = _val

                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }else{
                setNotification(isEnable: false, topic: "follow") { [weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.follow = _val

                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }
        }else if indexPath.item == 4{
            if cell.switchButton.isOn {
                setNotification(isEnable: true, topic: "mention") {[weak self] (_val) in
                    guard let sself = self else { return }
                    sself.currentUser.mention = _val

                    cell.switchButton.isOn = _val
                    tableView.reloadData()
                    
                }
            }else{
                setNotification(isEnable: false, topic: "mention") {[weak self] (_val) in
                    guard let sself = self else { return }
                    cell.switchButton.isOn = _val
                    sself.currentUser.mention = _val

                    tableView.reloadData()
                    
                }
            }
        }
    }
    
    func setNotification(isEnable : Bool ,topic : String, completion : @escaping(Bool) -> Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
        
        if isEnable{
            db.setData([topic:false], merge: true){ (err) in
                completion(false)
                Utilities.dismissProgress()
            }
            
        }else{
            db.setData([topic:true], merge: true){ (err) in
                completion(true)
                Utilities.dismissProgress()
            }
        }
    }
    
}
