//
//  TeacherSetLesson.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 25.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellId = "cellId"
class TeacherSetLesson: UITableViewController {

    var currentUser : CurrentUser
    var dataSourceFiltred = [LessonsModel]()
    var dataSource = [LessonsModel]()
    var centrelController : UIViewController!
    var isSearching = false
    let searchBar = UISearchBar()
    
    var selectedLesson : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            setNavigationBar()
        navigationItem.title = "Ders Ekle - Çıkar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismissController))
        tableView.register(LessonCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        getLessons { (model) in
            self.dataSource = model
            self.tableView.reloadData()
            Utilities.dismissProgress()
        }

    }
    
    init(currentUser : CurrentUser ) {
        self.currentUser = currentUser

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: --selectors
    @objc func dismissController()
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Ders Adını Gir"
        
    }
    
    //MARK: -func
    
    private func getLessons(completion : @escaping([LessonsModel])->Void){
        
        Utilities.waitProgress(msg: nil)
        var model = [LessonsModel]()
       
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson").collection(currentUser.bolum)
        db.getDocuments {(querySnap, err) in
            if err == nil {
                for doc in querySnap!.documents {
                    model.append(LessonsModel.init( dic: doc.data()))
                }
                completion(model)
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
    
    func checkExistLesson(lessonName : String , completion : @escaping(Bool) ->Void){
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid)
            .collection("lesson")
            .document(lessonName)
        db.getDocument { (docSnap,err ) in
            guard let snap = docSnap else {
                completion(false)
                return }
            if snap.exists{
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    
    
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      if isSearching {
            return self.dataSourceFiltred.count
        }else{
            return self.dataSource.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LessonCell
        cell.delegate = self
        if isSearching{
            checkExistLesson(lessonName: dataSourceFiltred[indexPath.row].lessonName) {[weak self] (_val) in
                if let sself = self{
                    if _val{
                        cell.mark.image = UIImage(named: "cancel")
                        cell.fallowerNumber.text = sself.dataSourceFiltred[indexPath.row].teacherName
                        cell.fallowerLabel.text = ""
                        sself.selectedLesson = sself.dataSourceFiltred[indexPath.row].lessonName
                    }else{
                        cell.mark.image = UIImage(named: "add")
                        cell.fallowerNumber.text = "Ders Seçilebilir"
                        cell.fallowerLabel.text = ""
                        sself.selectedLesson = sself.dataSourceFiltred[indexPath.row].lessonName
                    }
                    cell.lessonName.text = sself.dataSourceFiltred[indexPath.row].lessonName
                }
              
            }
           
        }else{
            checkExistLesson(lessonName: dataSource[indexPath.row].lessonName) {[weak self] (_val) in
                if let sself = self {
                    if _val{
                        
                        cell.mark.image = UIImage(named: "cancel")
                        cell.fallowerNumber.text = sself.dataSource[indexPath.row].teacherName
                        cell.fallowerLabel.text = ""
                        sself.selectedLesson = sself.dataSourceFiltred[indexPath.row].lessonName
                    }else{
                        cell.mark.image = UIImage(named: "add")
                        cell.fallowerNumber.text = "Ders Seçilebilir"
                        cell.fallowerLabel.text = ""
                        sself.selectedLesson = sself.dataSource[indexPath.row].lessonName
                    }
                    cell.lessonName.text = sself.dataSource[indexPath.row].lessonName
                }
               
            }
            
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}
 //MARK: - SearchBarDelegate
extension TeacherSetLesson : UISearchBarDelegate {
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
                return object.lessonName.contains(text)
            })
            
            self.tableView.reloadData()
            
        }
    }
}
extension TeacherSetLesson : ActionSheetLauncherDelegate{
    func didSelect(option: ActionSheetOptions) {
        switch option{
        
        case .addLesson(_):
            guard let lessonName = selectedLesson else { return }
            UserService.shared.teacherAddLesson(currentUser: currentUser, lessonName: lessonName) {[weak self] (_) in
                guard let sself = self else { return }
                Utilities.succesProgress(msg: "Ders Eklendi")
                sself.tableView.reloadData()
            }
        case .lessonInfo(_):
            break
        case .reportLesson(_):
            break
        case .showPicture(_):
            break
        case .removePicture(_):
            break
        case .takePicture(_):
            break
        case .choosePicture(_):
            break
        case .googleDrive(_):
            break
        case .dropBox(_):
            break
        case .yandexDisk(_):
            break
        case .iClould(_):
            break
        case .oneDrive(_):
            break
        case .mega(_):
            break
        }
    }
}
