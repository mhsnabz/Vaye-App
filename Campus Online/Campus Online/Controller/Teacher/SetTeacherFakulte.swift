//
//  SetTeacherFakulte.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 15.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellID = "cellID"
class SetTeacherFakulte: UITableViewController {
    var isSearching = false
    var currentUser : CurrentUser
    var dataSourceFiltred : [String] = []
    var dataSource = [String]()
    let searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Fakültenizi Seçiniz"
        setNavigationBar()
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBarClick))
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(FakulteCell.self, forCellReuseIdentifier: cellID)
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        getFakulte()
    }
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:--functions
    private func getFakulte(){
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("fakulte").collection("fakulte")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                for doc in querySnap!.documents{
                    self.dataSource.append(doc.documentID)
                    self.tableView.reloadData()
                }
            }
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
    //MARK:--selector
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Fakulteni Adını Giriniz"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        if isSearching{
            let vc = TeacherBolumTB(currentUser: currentUser)
            vc.fakulteName = dataSourceFiltred[indexPath.row]

            self.navigationController?.pushViewController(vc, animated: true)
        }else{

            let vc = TeacherBolumTB(currentUser: currentUser)

            vc.fakulteName = dataSource[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension SetTeacherFakulte : UISearchBarDelegate {
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
