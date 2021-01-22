//
//  SetBolum.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 22.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore
private let cellID = "cellId"

struct BolumName {
    var key : String
    var bolumName : String
}

class SetBolum: UITableViewController {
    var data_source = [BolumName]()
    var data_source_filter = [BolumName]()
    


    let searchBar = UISearchBar()
    var taskUser : TaskUser
    var isSearching = false
    var fakulteName : String
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.title = fakulteName
        getBolumName(fakulteName : fakulteName)
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.register(FakulteCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
    }

    init(taskUser : TaskUser , fakulteName : String) {
        self.taskUser = taskUser
        self.fakulteName = fakulteName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    private func getBolumName(fakulteName : String){
        let db = Firestore.firestore().collection(taskUser.short_school)
            .document("fakulte").collection("fakulte").document(fakulteName)
        db.getDocument { (docSnap, err) in
            if err == nil {
                let children = docSnap!.data()
                for (key, value) in children! {
                    self.data_source.append(BolumName(key: key, bolumName: value as! String))
                  
                    self.data_source.sort { (val1, val2) -> Bool in
                        return  val1.key < val2.key
                    }
                   
                    self.tableView.reloadData()
                }
                
                
            }
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.data_source_filter.count
        }else{
            return self.data_source.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FakulteCell
        if isSearching {
            cell.lbl.text = data_source_filter[indexPath.row].bolumName
            
        }else{
            cell.lbl.text = data_source[indexPath.row].bolumName
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching
        {
            taskUser.bolum = data_source_filter[indexPath.row].bolumName
            taskUser.bolum_key = data_source_filter[indexPath.row].key
            let vc = CompleteSigingUp(taskUser: taskUser, _bolumName: data_source_filter[indexPath.row].bolumName, _fakulteName: taskUser.fakulte, _bolumKey :  data_source_filter[indexPath.row].key)
      
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            taskUser.bolum = data_source[indexPath.row].bolumName
            taskUser.bolum_key = data_source[indexPath.row].key
            let vc = CompleteSigingUp(taskUser: taskUser, _bolumName: data_source[indexPath.row].bolumName, _fakulteName: taskUser.fakulte, _bolumKey :  data_source[indexPath.row].key)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showSearchBar(shouldShow : Bool){
        if shouldShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBarClick))
        }else{
            navigationItem.rightBarButtonItem = nil
            
        }
    }
    func search( shouldShow : Bool ){
        showSearchBar(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
        
    }
    
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Bölümünü Gir"
        
    }
}
extension SetBolum : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("start")
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("cancel")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText == " " {
            isSearching = false
            self.tableView.reloadData()
        }
        else
        {
            
            isSearching = true
            data_source_filter = data_source
            data_source_filter = data_source.filter({ (name) -> Bool in
                guard let text = searchBar.text else { return false}
                return name.bolumName.contains(text)
            })
            self.tableView.reloadData()
            
        }
    }
}

