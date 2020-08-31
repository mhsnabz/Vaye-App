//
//  ChooseSchool.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 24.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ChooseSchool: UITableViewController {
    
    
    var schools = [SchoolModel]()
     var dataSourceFiltred : [SchoolModel] = []
    let searchBar = UISearchBar()
      var isSearching = false
    
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Üniversiteni Seç" 
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismis))
        
        setNavigationBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.separatorStyle = .none
        tableView.register(ChooseSchoolCell.self, forCellReuseIdentifier: "id")
        getSchools()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    //MARK: -handelers
    
    func getSchools(){
        let db = Firestore.firestore().collection("schoolNames")
        db.getDocuments { (querySnap, err) in
            if err == nil {
                for doc in querySnap!.documents{
                    self.schools.append(SchoolModel.init(dic: doc.data()))
                    self.tableView.reloadData()
                }
            }else{
                return
            }
        }
    }
    
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Üniversite Adını Gir"

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
    
    //MARK: - tableview init
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! ChooseSchoolCell
        if isSearching {
            cell.logo.image = UIImage(named: dataSourceFiltred[indexPath.row].logo!)
            cell.name.text = dataSourceFiltred[indexPath.row].name
        }else{
            cell.logo.image = UIImage(named: schools[indexPath.row].logo!)
            cell.name.text = schools[indexPath.row].name
        }
   
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.dataSourceFiltred.count
        }else{
            return self.schools.count
        }

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RegisterVC()
        if isSearching
        {
            vc.school = dataSourceFiltred[indexPath.row]
        }else{
            vc.school = schools[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - SearchBarDelegate
extension ChooseSchool : UISearchBarDelegate {
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
            dataSourceFiltred = schools
            
            dataSourceFiltred = schools.filter({ object -> Bool in
                guard let text = searchBar.text else {return false}
                return object.name.contains(text)
            })

            self.tableView.reloadData()
            
        }
    }
}
