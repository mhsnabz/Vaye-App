//
//  ChooseClub.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class ChooseClub: UITableViewController {
    var currentUser : CurrentUser
    var isSearching = false
    let searchBar = UISearchBar()
    var dataSource = [String]()
    var dataSourceFiltred : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChooseHastagCell.self, forCellReuseIdentifier: "id")
        tableView.separatorStyle = .none
        navigationItem.title = "Kulüp Seç"
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    init(currentUser : CurrentUser , dataSource : [String]) {
        self.currentUser = currentUser
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! ChooseHastagCell
        if isSearching {
            cell.name = dataSourceFiltred[indexPath.row]
        }else{
            cell.name = dataSource[indexPath.row]
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return dataSourceFiltred.count
        }else{
            return dataSource.count
        }
        
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching {
            let vc = NoticesNewPost(currentUser: currentUser , clup : dataSourceFiltred[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = NoticesNewPost(currentUser: currentUser , clup : dataSource[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK:-functions
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
        isSearching = shouldShow
        tableView.reloadData()
        
    }
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Kulüp Adı Giriniz"
        
    }
    
    
}
extension ChooseClub : UISearchBarDelegate {
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
            
            dataSourceFiltred = dataSource.filter({ object -> Bool in
                guard let text = searchBar.text else {return false}
                return object.contains(text)
            })
            
            self.tableView.reloadData()
            
        }
    }
}
