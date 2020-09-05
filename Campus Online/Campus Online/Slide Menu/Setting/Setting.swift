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
    
    let headerLbl : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .lightGray
        
        return lbl
    }()
    let line : UIView = {
       let view = UIView()
        view.backgroundColor = .lightGray
    
        return view
    }()
    lazy var header : UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.addSubview(headerLbl)
        headerLbl.anchor(top: nil, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        headerLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(line)
        line.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 0.4)
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
        
    }
}
extension Setting : UITableViewDelegate , UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SettingCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            headerLbl.text = "Deneme Header"
             return header
        }else if section == 4{
                 headerLbl.text = "section 4 Header"
                    return header
        }
        else{
            return nil
        }
       
    }
        
}
