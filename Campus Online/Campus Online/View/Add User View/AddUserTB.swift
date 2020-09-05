//
//  AddUserTB.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 5.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let cellId = "cellId"
import FirebaseFirestore
import SDWebImage
class AddUserTB: UITableViewController {
    
    //MARK:- properties
    let searchBar = UISearchBar()
    var currentUser : CurrentUser
    var users = [LessonFallowerUser]()
    var user : [String]?
    //MARK:- lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismissVC))
        tableView.register(AddUserCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        navigationItem.titleView = searchBar
        
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        searchBar.placeholder = "@kullanıcıAdı"
         
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    init(currentUser : CurrentUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- functions
    @objc func dismissVC()
    {
        self.dismiss(animated: false) {
            
        }
    }
    private func getUsers( _ name : String,completion : @escaping(_ user : LessonFallowerUser) ->Void){
        ///İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama/fallowers
       let path = Firestore.firestore().collection(currentUser.short_school).document("lesson")
        .collection("Bilgisayar Mühendisliği").document("Bilgisayar Programlama").collection("fallowers")
        .whereField("username", isGreaterThanOrEqualTo : name)
        path.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snapShot = querySnap else { return }
                print(snapShot.documents)
                if !snapShot.isEmpty{
                     self.users = []
                    for doc in snapShot.documents {
                        completion(LessonFallowerUser.init(username: doc.documentID, dic: doc.data()))
                        
                    }
                }else{
                    self.users = []
                }
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
      }
      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AddUserCell
        cell.name.text = users[indexPath.row].name
        cell.userName.text = users[indexPath.row].username
        cell.img.sd_imageIndicator = SDWebImageActivityIndicator.white
        cell.img.sd_setImage(with: URL(string: users[indexPath.row].thumb_image ?? ""))
          return cell
      }
    
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 50
      }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
    
        user?.append(self.users[indexPath.row].username!)
        self.dismiss(animated: false) {
        
        }
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            let vc = StudentNewPost(currentUser: currentUser)
            vc.users = self.user
    }

}
extension AddUserTB : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.users = []
        guard let name = searchBar.text else {return }
        getUsers(name) { (user) in
            print(user.name!)
            self.users.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
             self.users.sort {
                (user1, user2) -> Bool in
                 return (user1.username?.contains(name))!
                           }
            
        }
        if searchBar.text?.count == 0  {
            self.users = []
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
        }
        tableView.reloadData()
    }
}
