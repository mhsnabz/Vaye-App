//
//  SchoolPostNotificationSetting.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import  FirebaseFirestore
class SchoolPostNotificationSetting: UITableViewController {

    
    var currentUser : CurrentUser
    var names = [ClupNames]()
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setNavigationBar()
        navigationItem.title = "Bildirimleri Açın"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissVC))
        
        tableView.register(SchollNotificationSettingCell.self, forCellReuseIdentifier: "id")
        
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("clup").collection("name")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap  = querySnap else { return }
                for item in snap.documents {
                    self.names.append(ClupNames.init(id : item.documentID , dic : item.data()))
                    self.tableView.reloadData()
                }
            }
        }
        

    }
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! SchollNotificationSettingCell
        cell.selectionStyle = .none
        cell.item = names[indexPath.row]
        if let isExist = names[indexPath.row].followers?.contains(currentUser.uid) {
            if isExist {
                cell.switchButton.isOn = true
            }else{
                cell.switchButton.isOn = false
            }
        }else{
            cell.switchButton.isOn = false
        }
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SchollNotificationSettingCell
        if cell.switchButton.isOn {
            Utilities.waitProgress(msg: nil)
            cell.switchButton.isOn = false
            NoticesService.shared.unFollowTopic(id: names[indexPath.item].id, currentUser: currentUser) { (_) in
                Utilities.dismissProgress()
                
            
            }
        }else{
            Utilities.waitProgress(msg: nil)
            cell.switchButton.isOn = true
            NoticesService.shared.followTopic(id: names[indexPath.item].id, currentUser: currentUser) { (_) in
                
                Utilities.dismissProgress()
                
            }
            
        }
    }

}

class SchollNotificationSettingCell : UITableViewCell {
    
    var item : ClupNames?{
        didSet{
            guard let item = item else { return }
            titleLbl.text = item.id
            if let count = item.followers?.count{
                lbl.text = "\(count) Takipçi"
            } else {
                lbl.text = "0 Takipçi"
            }
             
        }
    }
    
    let titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .black
        return lbl
    }()
    let lbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 11)
        lbl.textColor = .darkGray
        return lbl
    }()
    lazy var switchButton : UISwitch = {
       let s = UISwitch()
        return s
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        let stack = UIStackView(arrangedSubviews: [titleLbl,lbl])
        stack.axis = .vertical
        stack.alignment = .leading
        
        addSubview(stack)
        stack.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 59 + 15  , width: 0, heigth: 0)
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(switchButton)
        switchButton.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12 , width: 50, heigth: 35)
        switchButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
