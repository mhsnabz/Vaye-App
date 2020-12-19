//
//  VayeAppNotification.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class VayeAppNotification: UITableViewController {

    var currentUser : CurrentUser
    
    lazy var isFoodMe : Bool  = false
    lazy var isCamping : Bool = false
    lazy var isBuySell : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Anlık Bildirim Ayarları"
        setNavigationBar()
        tableView.register(VayeAppNotificationCell.self, forCellReuseIdentifier: "id")
        tableView.separatorStyle = .none
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(dismissVC))
        
             MainPostService.shared.checkFollowTopic(currentUser: currentUser, topic: "food-me") {[weak self] (val) in
                guard let sself = self else { return }
                sself.isFoodMe = val
                sself.tableView.reloadData()
                
             }
        MainPostService.shared.checkFollowTopic(currentUser: currentUser, topic: "camping") {[weak self] (val) in
           guard let sself = self else { return }
           sself.isCamping = val
           sself.tableView.reloadData()
           
        }
        MainPostService.shared.checkFollowTopic(currentUser: currentUser, topic: "sell-buy") {[weak self] (val) in
           guard let sself = self else { return }
           sself.isBuySell = val
           sself.tableView.reloadData()
           
        }
        
    }
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! VayeAppNotificationCell
        cell.selectionStyle = .none
        if indexPath.item == 0 {
            cell.titleLabel.text = "Al-Sat"
             
            cell.textLbl.text = "Yeni Bir İlan Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
            cell.isOpen = isBuySell
        }
        else if indexPath.item == 1 {
            cell.titleLabel.text = "Yemek"
            cell.textLbl.text = "Yeni Bir Yemek İlanı Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
            cell.isOpen = isFoodMe
        }
        else if indexPath.item == 2 {
            cell.titleLabel.text = "Kamp"
            cell.textLbl.text = "Yeni Bir Kamp İlanı Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
            cell.isOpen = isCamping
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! VayeAppNotificationCell
        if indexPath.item == 0 {
            if cell.switchButton.isOn {
                print(" buy sell closed")
                
                followTopic(currentUser: currentUser, topic: "sell-buy", isFollowing: true) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    cell.switchButton.isOn = _val
                    sself.isBuySell = _val
                }
            }else{
                print(" buy sell  opened")
                followTopic(currentUser: currentUser, topic: "sell-buy", isFollowing: false) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    cell.switchButton.isOn = _val
                    sself.isBuySell = _val
                }
            }
        }else if indexPath.item == 1 {
            if cell.switchButton.isOn {
                followTopic(currentUser: currentUser, topic: "food-me", isFollowing: true) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    cell.switchButton.isOn = _val
                    sself.isFoodMe = _val

                }
            }else{
                followTopic(currentUser: currentUser, topic: "food-me", isFollowing: false) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    sself.isFoodMe = _val
                    cell.switchButton.isOn = _val
                }
            }
        }else if indexPath.item == 2 {
            if cell.switchButton.isOn {
                followTopic(currentUser: currentUser, topic: "camping", isFollowing: true) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    sself.isCamping = _val
                    cell.switchButton.isOn = _val
                }
            }else{
                followTopic(currentUser: currentUser, topic: "camping", isFollowing: false) {[weak self] (_val) in
                    guard let sself = self else {
                        return
                    }
                    sself.isCamping = _val
                    cell.switchButton.isOn = _val
                }
            }
        }
        
    }


    private func followTopic(currentUser : CurrentUser, topic : String , isFollowing  : Bool , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
    
          
            if isFollowing{
                
                
                let db = Firestore.firestore().collection("main-post")
                    .document(topic)
                    .collection("followers")
                    .document(currentUser.uid)
                db.delete { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Kapandı")
                       completion(false)
                    }
                }
            }else{
                
                let db = Firestore.firestore().collection("main-post")
                    .document(topic)
                    .collection("followers").document(currentUser.uid)
                
                db.setData(["userId":currentUser.uid as Any , "school":currentUser.short_school as Any] as [String : Any], merge: true) { (err) in
                    if err == nil {
                        Utilities.succesProgress(msg: "Bildirimler Açıldı")
                        completion(true)
                    }
                }
            }
        
        
    }
   
  
    
}

class VayeAppNotificationCell : UITableViewCell {
    
     var isOpen : Bool? {
        didSet{
            guard let isOpen = isOpen else { return }
            switchButton.isOn = isOpen
        }
    }
    
    lazy var switchButton : UISwitch = {
       let s = UISwitch()
        
        
        return s
    }()
    
    let titleLabel : UILabel = {
        let lbl = UILabel()

        lbl.font = UIFont(name: Utilities.fontBold, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let textLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray
        lbl.numberOfLines = 0

        return lbl
    }()
    
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        
        addSubview(switchButton)
        switchButton.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12 , width: 50, heigth: 35)
        switchButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,textLbl])
        stack.alignment = .leading
        stack.axis = .vertical
        
        addSubview(stack)
        stack.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 59 + 15  , width: 0, heigth: 0)
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.3)
     
        switchButton.addTarget(self, action: #selector(selected(sender:)), for: .valueChanged)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func selected(sender:UISwitch){
        if sender.isOn {
            print("closes")
        }else{
            print("opened")
        }
    }
}
