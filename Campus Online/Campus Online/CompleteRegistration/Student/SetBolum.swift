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
class SetBolum: UITableViewController {

    var dataSourceFiltred : [String] = []
    var dataSource = [String]()
    let searchBar = UISearchBar()
    var taskUser : TaskUser
    var isSearching = false
    var fakulteName : String!{
        didSet {
            navigationItem.title = fakulteName
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        navigationItem.backBarButtonItem?.title = ""
        getBolumName(fakulteName : fakulteName)
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.register(FakulteCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
    }

    init(taskUser : TaskUser) {
        self.taskUser = taskUser
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
                for (_, value) in children! {
                    self.dataSource.append(value as! String)
                    self.dataSource.sort { (val1, val2) -> Bool in
                        return  val1 < val2
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
            return self.dataSourceFiltred.count
        }else{
            return self.dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FakulteCell
        if isSearching {
            cell.lbl.text = dataSourceFiltred[indexPath.row]
            
        }else{
            cell.lbl.text = dataSource[indexPath.row]
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching
        {
            let vc = CompleteRegistration()
            vc._bolumName = dataSourceFiltred[indexPath.row]
            vc._fakulteName = fakulteName
        //    vc.currentUser = currentUser
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            
            let vc = CompleteRegistration()
            vc._bolumName = dataSource[indexPath.row]
            vc._fakulteName = fakulteName
         //   vc.currentUser = currentUser
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
            dataSourceFiltred = dataSource
            dataSourceFiltred = dataSource.filter({ (name) -> Bool in
                guard let text = searchBar.text else { return false}
                return name.contains(text)
            })
            self.tableView.reloadData()
            
        }
    }
}

