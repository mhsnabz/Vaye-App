//
//  VayeAppNotification.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 19.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class VayeAppNotification: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Anlık Bildirim Ayarları"
        setNavigationBar()
        tableView.register(VayeAppNotificationCell.self, forCellReuseIdentifier: "id")
        tableView.separatorStyle = .none
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(dismissVC))
        
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
        cell.switchButton.tintColor = .mainColor()
        if indexPath.item == 0 {
            cell.titleLabel.text = "Al-Sat"
            cell.textLbl.text = "Yeni Bir İlan Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
        }
        else if indexPath.item == 1 {
            cell.titleLabel.text = "Yemek"
            cell.textLbl.text = "Yeni Bir Yemek İlanı Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
        }
        else if indexPath.item == 2 {
            cell.titleLabel.text = "Kamp"
            cell.textLbl.text = "Yeni Bir Kamp İlanı Paylaşıldığında Telefonunuza Anlık Bildirimler Alırsınız"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
    }


}

class VayeAppNotificationCell : UITableViewCell {
    
     var switchButton : UISwitch = {
       let s = UISwitch()
        s.isUserInteractionEnabled = false
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
     
        switchButton.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        switchButton.tintColor = .mainColor()
    
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func selected(_ sender:UISwitch){
        if sender.isOn {
            print("closes")
        }else{
            print("opened")
        }
    }
}
