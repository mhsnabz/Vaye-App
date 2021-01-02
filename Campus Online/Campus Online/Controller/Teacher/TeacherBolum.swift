//
//  TeacherBolum.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 23.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
private let cellID = "cellId"

class TeacherBolum: UITableViewController {

    var currentUser : TaskUser
    var dataSourceFiltred : [String] = []
    var dataSource = [String]()
    let searchBar = UISearchBar()
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.title = "Bölüm Seçiniz"
        getBolumName(fakulteName : currentUser.fakulte)
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.register(FakulteCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
    }

    
    init(currentUser : TaskUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching{
            return dataSourceFiltred.count
        }else{
            return dataSource.count
        }
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
            currentUser.bolum = dataSourceFiltred[indexPath.row]
            showAlert(fakulete: currentUser.fakulte, bolum: dataSourceFiltred[indexPath.row])
        }
        else
        {
            
            currentUser.bolum = dataSource[indexPath.row]
            showAlert(fakulete: currentUser.fakulte, bolum: dataSource[indexPath.row])
        }
    }
    //MARK: --functions
    private func getBolumName(fakulteName : String){
        let db = Firestore.firestore().collection(currentUser.short_school)
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
    
    private func showAlert(fakulete : String , bolum : String){
        // create the alert
              let alert = UIAlertController(title: "Kaydı Tamamla", message: "Fakulte : \(fakulete) \n Bölüm : \(bolum)", preferredStyle: UIAlertController.Style.alert)

              // add the actions (buttons)
              alert.addAction(UIAlertAction(title: "Kaydı Tamamla", style: UIAlertAction.Style.default, handler:  { [weak self] action in
                guard let sself = self else { return }
                sself.completeRegistiration(bolum: bolum, fakulte: fakulete) { (err) in
                    if err{
                        UserService.shared.getCurrentUser(uid: sself.currentUser.uid) { (user) in
                            Utilities.succesProgress(msg: "Kayıt Tamamlandı")
                            let vc = MainTabbar()
                            vc.modalPresentationStyle = .fullScreen
                            vc.currentUser = user
                            sself.present(vc, animated: true, completion: nil)
                        }
                     
                    }
                }
              }))
              alert.addAction(UIAlertAction(title: "Vazgeç", style: UIAlertAction.Style.cancel, handler: {action in
                
              }))

              // show the alert
              self.present(alert, animated: true, completion: nil)
    }
    func completeRegistiration(bolum : String , fakulte : String , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: "Lütfen Bekleyiniz")
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
        
        let dic = ["number":""
                   ,"short_school":currentUser.short_school as Any,
                   "schoolName":currentUser.schoolName as Any,
                   "fakulte":currentUser.fakulte as Any,
                   "bolum":currentUser.bolum as Any
                   ,"name":currentUser.name as Any
                   ,"slient":[],"friendList":[],"slientChatUser":[],
                   "mention":true,"comment":true,"like":true,"follow":true,"lessonNotices":true,
                   "profileImage":""
                   ,"unvan":currentUser.unvan as Any,
                   "thumb_image":""
                   ,"email":currentUser.email as Any,
                   "priority":"teacher"
                   ,"uid":currentUser.uid as Any,
                   "username":currentUser.username as Any ,
                   "instagram": "",
                   "twitter":"",
                   "linkedin":"",
                   "github":""] as [String : Any]
        
        db.setData(dic, merge: true) {[weak self] (err) in
            guard let sself = self else { return }
            if err == nil {
                let db = Firestore.firestore().collection("status")
                    .document(sself.currentUser.uid)
                db.setData(["status":true], merge: true) { (err) in
                    if err == nil {
                        let db = Firestore.firestore().collection(sself.currentUser.short_school)
                            .document("teacher")
                            .collection("uid").document(sself.currentUser.uid)
                        db.setData(["uid":sself.currentUser.uid as Any] as [String : Any], merge: true) { (err) in
                            if err == nil {
                                sself.setUserName(currentUser: sself.currentUser) { (_) in
                                    let db = Firestore.firestore().collection("task-teacher")
                                        .document(sself.currentUser.uid)
                                    db.delete { (err) in
                                        if err == nil {
                                            
                                            let db = Firestore.firestore().collection("user")
                                                .document(sself.currentUser.uid)
                                                .collection("saved-task")
                                                .document("task")
                                            
                                            db.setData(["data":[]] as [String:Any], merge: true) { (err) in
                                                if err == nil {
                                                    completion(true)
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                               
                            }
                        }
                    }
                }
            }
        }
        
       
        
    }
    
    func setUserName(currentUser : TaskUser, completion: @escaping(Bool) ->Void ){
        //username/@deneme
        //İSTE/teacher/uid/N2Hh7fsd3QZwa8Lv5vfMfEaPIgt1
        let db = Firestore.firestore().collection("username")
            .document(currentUser.username)
        let dic = ["uid":currentUser.uid as Any , "email":currentUser.email  as String, "username":currentUser.username as String] as [String : Any]
        db.setData(dic, merge: true) { (err) in
            if err == nil {
                let db = Firestore.firestore().collection(currentUser.short_school)
                    .document("teacher")
                    .collection("uid")
                    .document(currentUser.uid)
                db.setData(["uid":currentUser.uid as Any], merge: true) { (err) in
                    if err == nil {
                        completion(true)
                    }
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
    
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Bölümünü Gir"
        
    }

}
//MARK: - SearchBarDelegate
extension TeacherBolum : UISearchBarDelegate {
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
