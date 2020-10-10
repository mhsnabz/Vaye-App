//
//  SearchInputView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 10.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class SearchInputView: UIView {
    
    
    //MARK: -properites
    
    var searchBar : UISearchBar!
    var tableView : UITableView!
    let indicatorView : UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        v.layer.cornerRadius = 5
        v.alpha = 0.8
        return v
    }()
    
    //MARK: -lifeCycle
    override init(frame : CGRect){
        super.init(frame: frame)
        
        configureViewComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -selectors
    //MARK: -function
    func configureViewComponent(){
        backgroundColor = .white
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 40, heigth: 8)
        indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        configureSearchBar()
    }
    
    func configureSearchBar(){
        searchBar = UISearchBar()
        searchBar.placeholder = "Konum Arayın"
        searchBar.barStyle = .blackOpaque
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        addSubview(searchBar)
        searchBar.anchor(top: indicatorView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 50)
        configureTableView()
    }
    func configureTableView()
    {
        tableView = UITableView()
        tableView.rowHeight = 72
        tableView.register(SearchCell.self, forCellReuseIdentifier: "id")
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}
extension SearchInputView : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! SearchCell
        return cell
     }
    
    
}
