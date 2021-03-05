//
//  LessonList.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 28.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//
import UIKit
import FirebaseFirestore
private let cellId = "cellId"
class LessonList: UITableViewController {
    //MARK: -varibles
    var centrelController : UIViewController!
    var isSearching = false
    var currentUser : CurrentUser?
    var dataSourceFiltred = [LessonsModel]()
    var dataSource = [LessonsModel]()
    let searchBar = UISearchBar()
    var lesson_name : String?
    var teacherName : String?
    var teacher_id : String?
    var teacher_email : String?
    var lesson_key : String?
    
    private var actionSheet : ActionSheetLauncher
    //MARK: -lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Ders Ekle - Çıkar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismissController))
        
        tableView.separatorStyle = .none
        
        searchBar.sizeToFit()
        searchBar.delegate = self
        showSearchBar(shouldShow: true)
        tableView.register(LessonCell.self, forCellReuseIdentifier: cellId)
        getLessons { (model) in
            self.dataSource = model
            self.tableView.reloadData()
            Utilities.dismissProgress()
        }
        
        
    }
    
    init(currentUser : CurrentUser ){
        self.currentUser = currentUser
        self.actionSheet = ActionSheetLauncher(currentUser: currentUser, target: Target.lessonEdit.description)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -func
    
    private func getLessons(completion : @escaping([LessonsModel])->Void){
        
        Utilities.waitProgress(msg: nil)
        var model = [LessonsModel]()
        guard let user = currentUser else {
            Utilities.dismissProgress()
            return }
        //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
        let db = Firestore.firestore().collection(user.short_school)
            .document("lesson").collection(user.bolum)
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
    
    @objc func searchBarClick(){
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.backgroundColor = UIColor(white: 0.95, alpha: 0.7)
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Ders Adını Gir"
        
    }
    
    
    
    
    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func searchClick()
    {
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.dataSourceFiltred.count
        }else{
            return self.dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LessonCell
        cell.delegate = self
        if isSearching {
            checkExitLesson(lessonName: dataSourceFiltred[indexPath.row].lessonName) { (val) in
                if val {
                    cell.mark.image = UIImage(named: "add")
                }else{
                    cell.mark.image = UIImage(named: "cancel")
                }
            }
            if currentUser != nil {
                let db = Firestore.firestore().collection(currentUser!.short_school).document("lesson").collection(currentUser!.bolum).document(dataSourceFiltred[indexPath.row].lessonName).collection("fallowers")
                db.getDocuments { (querySnap, err) in
                    if err == nil {
                        if querySnap != nil {
                            cell.fallowerNumber.text = querySnap?.documents.count.description
                        }
                    }
                }
                
            }
            cell.lessonName.text = dataSourceFiltred[indexPath.row].lessonName
        }else {
            checkExitLesson(lessonName: dataSource[indexPath.row].lessonName ) { (val) in
                if val {
                    cell.mark.image = UIImage(named: "cancel")
                }else{
                    cell.mark.image = UIImage(named: "add")
                }
            }
            if currentUser != nil {
                let db = Firestore.firestore().collection(currentUser!.short_school).document("lesson").collection(currentUser!.bolum).document(dataSource[indexPath.row].lessonName)
                    .collection("fallowers")
                db.getDocuments { (querySnap, err) in
                    if err == nil {
                        if querySnap != nil {
                            cell.fallowerNumber.text = querySnap?.documents.count.description
                        }
                        
                    }
                }
                
            }
            cell.lessonName.text = dataSource[indexPath.row].lessonName
        }
        
        return cell
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        search(shouldShow: false)
        if isSearching {
            
            checkExitLesson(lessonName: dataSourceFiltred[indexPath.row].lessonName) {[weak self] (val) in
                if val {
                    self?.removeLesson(lessonName: self?.dataSourceFiltred[indexPath.row].lessonName, teacherName: self?.dataSourceFiltred[indexPath.row].teacherName, teacherID: self?.dataSourceFiltred[indexPath.row].teacherId, teacherEmail: self?.dataSourceFiltred[indexPath.row].teacherEmail)
                    
                }else{
                    self?.actionSheet.show()
                    self?.actionSheet.delegate = self
                    self?.teacher_id = self?.dataSourceFiltred[indexPath.row].teacherId
                    self?.teacherName = self?.dataSourceFiltred[indexPath.row].teacherName
                    self?.lesson_name =  self?.dataSourceFiltred[indexPath.row].lessonName
                    self?.teacher_email = self?.dataSourceFiltred[indexPath.row].teacherEmail
                    self?.lesson_key = self?.dataSourceFiltred[indexPath.row].lesson_key
                }
            }
            
        }else{
            checkExitLesson(lessonName: dataSource[indexPath.row].lessonName) {[weak self] (val) in
                if val {
                    self?.removeLesson(lessonName: self?.dataSource[indexPath.row].lessonName, teacherName: self?.dataSource[indexPath.row].teacherName, teacherID: self?.dataSource[indexPath.row].teacherId, teacherEmail: self?.dataSource[indexPath.row].teacherEmail)
                    
                        
                    
                }else{
                    self?.actionSheet.show()
                    self?.actionSheet.delegate = self
                    self?.teacher_id = self?.dataSource[indexPath.row].teacherId
                    self?.teacherName = self?.dataSource[indexPath.row].teacherName
                    self?.lesson_name =  self?.dataSource[indexPath.row].lessonName
                    self?.teacher_email = self?.dataSource[indexPath.row].teacherEmail
                    self?.lesson_key = self?.dataSource[indexPath.row].lesson_key
                }
            }
            
        }
    }
    
    
    //MARK: - functions
    private func addLesson(lessonName : String! ,teacherName : String!, teacherID : String! , teacherEmail : String!  , lesson_key : String!)
    {
        Utilities.waitProgress(msg: "Ekleniyor")
        guard let currentUser = currentUser else {
            Utilities.errorProgress(msg: "Eklenemedi")
            return }
            
        let dic = ["teacherName":teacherName as Any,"lesson_key":lesson_key as Any,
                   "teacherId":teacherID as Any,
                   "teacherEmail":teacherEmail as Any,
                   "lessonName":lessonName!] as [String:Any]
        
        Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!).setData(dic, merge: true) { (err) in
                if err == nil {
                    //İSTE/lesson/Bilgisayar Mühendisliği/Bilgisayar Programlama
                    let abc = Firestore.firestore().collection(currentUser.short_school)
                        .document("lesson").collection(currentUser.bolum)
                        .document(lessonName!).collection("fallowers").document(currentUser.username)
                    
                    let dict = ["username":currentUser.username as Any,"name":currentUser.name as Any,"email":currentUser.email as Any,"number":currentUser.number as Any,"thumb_image":currentUser.thumb_image ?? "" , "uid" : currentUser.uid as Any] as [String:Any]
                    abc.setData(dict, merge: true) { (err) in
                        if err == nil {
                            self.getAllPost(currentUser: currentUser, lessonName: lessonName) { (val) in
                                if !val.isEmpty{
                                    self.addAllPost(postId: val, currentUser: currentUser, lessonName: lessonName) { (_val) in
                                        if _val {
                                            Utilities.succesProgress(msg : "Ders Eklendi")
                                            self.tableView.reloadData()
                                            let dbNoti = Firestore.firestore().collection(currentUser.short_school)
                                                .document("lesson").collection(currentUser.bolum)
                                                .document(lessonName!).collection("notification_getter").document(currentUser.uid)
                                            dbNoti.setData(["uid":currentUser.uid as Any], merge: true) { (err) in
                                                
                                            }
                                        }else{
                                            Utilities.succesProgress(msg : "Ders Eklenemedi")
                                            self.tableView.reloadData()
                                        }
                                    }
                                }else{
                                    Utilities.succesProgress(msg : "Ders Eklendi")
                                    self.tableView.reloadData()
                                }
                               
                            }
                            
                        }else{
                            Utilities.errorProgress(msg: "Eklenemedi")
                        }
                    }
                }else{
                    Utilities.errorProgress(msg: "Eklenemedi")
                }
            }
    }
    private func checkExitLesson(lessonName : String? ,completion : @escaping (Bool) -> Void){
        
        guard let lessonName = lessonName else { return }
        guard let user = currentUser else { return }
        let db = Firestore.firestore().collection("user").document(user.uid).collection("lesson").document(lessonName)
        db.getDocument { (docSnap, err) in
            guard let docSnap = docSnap else { return }
            if docSnap.exists{
                completion(true)
            }else{
                completion(false)
            }
        }
        
    }
    private func getAllPost(currentUser : CurrentUser , lessonName : String , completion : @escaping([String]) ->Void){
        //İSTE/lesson-post/post/1599800825321
        var postId = [String]()
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post").collection("post").whereField("lessonName", isEqualTo: lessonName)
        db.getDocuments { (querySnap, err) in
            if err == nil {
                guard let snap = querySnap else {
                    completion([])
                    return }
                for doc in snap.documents {
                    postId.append(doc.documentID)
                }
                completion(postId)
            }
        }
    }
    private func addAllPost(postId : [String] , currentUser : CurrentUser, lessonName : String! , completion : @escaping(Bool) -> Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson-post/1599800825321
        for item in postId {
            let db = Firestore.firestore().collection("user")
                .document(currentUser.uid).collection("lesson-post").document(item)
            db.setData(["postId":item , "lessonName":lessonName as Any], merge: true) { (err) in
                if err == nil {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
        
    }
    private func removeAllPost(postId : [String] , currentUser : CurrentUser , completion : @escaping(Bool) -> Void){
        //user/2YZzIIAdcUfMFHnreosXZOTLZat1/lesson-post/1599800825321
        for item in postId {
            let db = Firestore.firestore().collection("user")
                .document(currentUser.uid).collection("lesson-post").document(item)
            db.delete { (err) in
                if err == nil {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
        
    }
    
    private func removeLesson (lessonName : String! ,teacherName : String!, teacherID : String! , teacherEmail : String! ){
        Utilities.waitProgress(msg: "Ders Siliniyor")
        guard let currentUser = currentUser else {
            Utilities.errorProgress(msg: "Ders Silinemedi")
            return }
        let db = Firestore.firestore().collection("user")
            .document(currentUser.uid).collection("lesson")
            .document(lessonName!)
        db.delete { (err) in
            if err == nil {
                let abc = Firestore.firestore().collection(currentUser.short_school)
                    .document("lesson").collection(currentUser.bolum)
                    .document(lessonName!).collection("fallowers").document(currentUser.username)
                abc.delete { (err) in
                    if err == nil {
                        self.getAllPost(currentUser: currentUser, lessonName: lessonName) { (val) in
                            if !val.isEmpty{
                                self.removeAllPost(postId: val, currentUser: currentUser) { (_val) in
                                    if _val{
                                        Utilities.succesProgress(msg : "Ders Silindi")
                                        self.tableView.reloadData()
                                        let dbNoti = Firestore.firestore().collection(currentUser.short_school)
                                            .document("lesson").collection(currentUser.bolum)
                                            .document(lessonName!).collection("notification_getter").document(currentUser.uid)
                                        dbNoti.delete()
                                        
                                    }else{
                                        Utilities.errorProgress(msg: "Ders Silinemedi")
                                    }
                                }
                            }else{
                                Utilities.succesProgress(msg : "Ders Silindi")
                                self.tableView.reloadData()
                            }
                          
                        }
                        
                    }else{
                        Utilities.errorProgress(msg: "Ders Silinemedi")
                    }
                }
            }else{
                Utilities.errorProgress(msg: "Ders Silinemedi")
            }
        }
    }
    
}

//MARK: - SearchBarDelegate
extension LessonList : UISearchBarDelegate {
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
//MARK: - ActionSheetLauncherDelegate
extension LessonList : ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option
        {
        case .addLesson(_):
            addLesson(lessonName: lesson_name!, teacherName: teacherName!, teacherID: teacher_id, teacherEmail: teacher_email! , lesson_key : lesson_key)
            break
        case .lessonInfo(_):
            guard let currentUser = currentUser else { return }
            let vc = LessonInfo(lessonName: lesson_name!,currentUser: currentUser)
            centrelController = UINavigationController(rootViewController: vc)
            centrelController.modalPresentationStyle = .fullScreen
            self.present(centrelController, animated: true) {
                return
            }
            break
        case .reportLesson(_):
            print("report lesson")
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

