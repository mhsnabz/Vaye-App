//
//  Setting.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let cellID = "cellId"
class Setting: UIViewController {
    //MARK: -properties
    var currentUser : CurrentUser
    var tableView = UITableView()
    let checkMark : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = #imageLiteral(resourceName: "verified")
        return img
    }()
    let logo : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "logo")?.withRenderingMode(.alwaysOriginal)
        return img
    }()
    let versionLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 12)
        lbl.textColor = .lightGray
        lbl.text = "Version : 1.0.1"
        return lbl
    }()
 
    lazy var footerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(logo)
        logo.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 75, heigth: 75)
        logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addSubview(versionLbl)
        versionLbl.anchor(top: logo.bottomAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 4, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 12)
        versionLbl.centerXAnchor.constraint(equalTo: logo.centerXAnchor).isActive = true
        return view
    }()
    //MARK:- lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        view.backgroundColor = .white
        navigationItem.title = "Ayarlar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dissmisVC))
        configureTableView()
        
    }
    
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK:- functions
    @objc func dissmisVC(){
        dismiss(animated: true, completion: nil)
    }
    private func configureTableView(){
        view.addSubview(tableView)
 
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(SettingCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 40
//              tableView = UITableView(frame: .zero, style: .grouped)
        
    }
}
extension Setting : UITableViewDelegate , UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return 3
        }else if section == 2{
            return 2
        }else {
            return 2
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SettingCell
        if indexPath == [0,0]{
            cell.img.image = UIImage(named: "mail")!
            cell.lbl.text = currentUser.email
            cell.addSubview(checkMark)
            checkMark.anchor(top: nil, left: cell.lbl.rightAnchor, bottom: nil
                , rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
            checkMark.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
        }else if indexPath == [0,1]{
            cell.img.image = UIImage(named: "password")!
            cell.lbl.text = "Şifre Ayarları"
        }
        
        else if indexPath == [1,0]{
            cell.img.image = UIImage(named: "license")!
            cell.lbl.text = "Lisanlar"
        }
        else if indexPath == [1,1]{
            cell.img.image = UIImage(named: "hizmet")!
            cell.lbl.text = "Hizmet Koşulları"
        }
        else if indexPath == [1,2]{
            cell.img.image = UIImage(named: "gizlilik")!
            cell.lbl.text = "Gizlilik Politikası"
        }
        else if indexPath == [2,0]{
            cell.img.image = UIImage(named: "bug")!
            cell.lbl.text = "Sorun Bildir"
        }
        else if indexPath == [2,1]{
            cell.img.image = UIImage(named: "rate-us")!
            cell.lbl.text = "Bizi Değerlendir"
        }
        else if indexPath == [3,0]{
            cell.img.image = UIImage(named: "ig")!
            cell.lbl.text = "@onlinecampus"
            cell.lbl.textColor = UIColor.systemBlue
        }
        else if indexPath == [3,1]{
            cell.img.image = UIImage(named: "twitter")!
            cell.lbl.text = "@onlinecampus"
            cell.lbl.textColor = UIColor.systemBlue
        }
        cell.backgroundColor = .white
        return cell
    }
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
              let headerView = UIView()
              headerView.backgroundColor = UIColor.white
   
              let headerLabel = UILabel(frame: CGRect(x: 12, y: 4, width:
                  tableView.bounds.size.width, height: 12))
                headerLabel.font = UIFont(name: Utilities.font, size: 12)
        
              headerLabel.textColor = UIColor.lightGray
              headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
              headerLabel.sizeToFit()
              headerView.addSubview(headerLabel)
            
              return headerView
          }

       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 20
      }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Güvenlik Ayarları"
        }else if section == 1 {
            return "Yasal"
        }
        else if section == 2 {
            return "Bize Ulaş"
        }
        else if section == 3 {
            return "Bizi Takip Edin"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
            return 120
        }else{
            return 0
        }
 
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0,0]{
//            cell.img.image = UIImage(named: "mail")!
         
            
        }else if indexPath == [0,1]{

//            cell.lbl.text = "Şifre Ayarları"
        }
        
        else if indexPath == [1,0]{
//            cell.lbl.text = "Lisanlar"
            let vc = LicenseTB()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath == [1,1]{
//            cell.lbl.text = "Hizmet Koşulları"
            let vc = KullanımKosulları()
             navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath == [1,2]{
//            cell.lbl.text = "Gizlilik Politikası"
            let vc = GizlilikPolitikasi()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath == [2,0]{
//            cell.lbl.text = "Sorun Bildir"
        }
        else if indexPath == [2,1]{
//            cell.lbl.text = "Bizi Değerlendir"
        }
        else if indexPath == [3,0]{
//            cell.lbl.text = "@onlinecampus"
        }
        else if indexPath == [3,1]{
//            cell.img.image = UIImage(named: "twitter")!
        }
    }
}
