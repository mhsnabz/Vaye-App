//
//  ChooseLessonTB.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class ChooseLessonTB: UITableViewController {
    var currentUser : CurrentUser
    var dataSource = [String]()
    var dataSourceFilter = [String]()
    var isSearching = false
    let searchBar = UISearchBar()
    var fallower = [LessonFallowerUser]()
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Ders Seçin"
        setNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismisVC))
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(ChooseLessonCell.self, forCellReuseIdentifier: "id")
        getMyLesson()
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return dataSourceFilter.count
        }else{
            return dataSource.count
        }
        
  
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! ChooseLessonCell
        if isSearching {
         cell.lessonName.text = dataSourceFilter[indexPath.row]
        }else{
            cell.lessonName.text = dataSource[indexPath.row]
        }
       
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            Utilities.waitProgress(msg: nil)
                   UserService.shared.fetchFallower(currentUser.short_school, currentUser.bolum, dataSourceFilter[indexPath.row]) { [weak self] (item) in
                       guard let self = self else { return }
                       let vc = StudentNewPost(currentUser: self.currentUser, selectedLesson : self.dataSource[indexPath.row], users: item)
                       vc.selectedLesson = self.dataSource[indexPath.row]
                       self.navigationController?.pushViewController(vc, animated: true)
                       Utilities.dismissProgress()
                   }  
        }else {
            Utilities.waitProgress(msg: nil)
            UserService.shared.fetchFallower(currentUser.short_school, currentUser.bolum, dataSource[indexPath.row]) { [weak self] (item) in
                guard let self = self else { return }
                let vc = StudentNewPost(currentUser: self.currentUser, selectedLesson : self.dataSource[indexPath.row], users: item)
                vc.selectedLesson = self.dataSource[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
                Utilities.dismissProgress()
            }
        }
    }

    //MARK:- functions
    
   
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
        searchBar.placeholder = "Ders Adını Gir"
        
    }
    
    
    
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getMyLesson(){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
        db.getDocuments {[weak self] (querySnap, err) in
            if err == nil {
                if !querySnap!.isEmpty {
                    Utilities.dismissProgress()
                    for doc in querySnap!.documents{
                        self?.dataSource.append(doc.documentID)
                        self?.tableView.reloadData()
                    }
                }else{
                    Utilities.errorProgress(msg: "Hiç Ders Takip Etmiyorsunuz")
                }
            }
        }
        
    }


}

class ChooseLessonCell : UITableViewCell {
    let lessonName : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let rigthArrow : UIImageView = {
       let img = UIImageView()
        img.image = UIImage(named: "rigth-arrow")?.withRenderingMode(.alwaysOriginal)
        img.contentMode = .scaleAspectFit
        return img
    }()
    let line : UIView = {
       let v = UIView()
        v.backgroundColor = .lightGray
        
        return v
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(lessonName)
        lessonName.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        lessonName.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(rigthArrow)
        rigthArrow.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 25, heigth: 25)
        rigthArrow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(line)
        line.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - SearchBarDelegate
extension ChooseLessonTB : UISearchBarDelegate {
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
            dataSourceFilter = dataSource
            dataSourceFilter = dataSource.filter({ (lessonName) -> Bool in
            guard let text = searchBar.text else {return false}
                return lessonName.contains(text)
            })
            self.tableView.reloadData()
            
        }
    }
}
