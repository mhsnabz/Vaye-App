//
//  TeacherChooseLesson.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 26.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
class TeacherChooseLesson: UITableViewController {
    
    var currentUser : CurrentUser
    var dataSource = [String]()
    var count : Int = 0
    var lessonName : String?{
        didSet{
            guard let lessonName = lessonName else {
                return}
            navigationItem.title = lessonName
        }
    }
    var isSearching = false
    var followers = [String]()
    let rigtButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Devam Et", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.fontBold, size: 11)
        return btn
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismisVC))
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(ChooseLessonCell.self, forCellReuseIdentifier: "id")
        getMyLesson()
        
        navigationItem.title = "Ders Seçin"
        setRigthBarButton()
    }
    
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:--functions
    
    func setRigthBarButton(){
        
        rigtButton.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
        rigtButton.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem()
        item1.customView = rigtButton
        navigationItem.rightBarButtonItem =  item1
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
    
    
    //MARK:--selectors
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func action(sender: UIBarButtonItem) {
        guard let lessonName = lessonName else { return }
        let vc = TeacherSetNewPost(currentUser : currentUser , lessonName : lessonName , users : followers)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
        
        
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! ChooseLessonCell
        
        cell.lessonName.text = dataSource[indexPath.row]
        cell.rigthArrow.isHidden = true
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        Utilities.waitProgress(msg: "Dersi Alan Öğrenciler Seçiliyor")
        count = count + 1
        if count > 1 {
            lessonName = "Genel Duyuru"
        }else{
            lessonName = dataSource[indexPath.row]
        }
        UserService.shared.getLessonFallowers(currentUser: currentUser, lessonName: dataSource[indexPath.row]) {[weak self] (user) in
            guard let sself = self else { return }
            
            if user.count > 0 {
                
                for id in user {
                    if !sself.followers.contains(id) {
                        sself.followers.append(id)
                    }
                }
            }
            Utilities.succesProgress(msg: "\(sself.followers.count) Öğrenci Seçildi")
        }
        
       
        dataSource.remove(element: dataSource[indexPath.row])
        self.tableView.reloadData()
    }
    
    
    
    
}

