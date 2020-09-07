//
//  LessonInfo.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 7.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
private let cellId = "Cell"
private let headerIdOne = "header"
private let headerTwo = "head"
class LessonInfo: UIViewController {
    var collectionview: UICollectionView!
    var list = [LessonFallowerUser]()
    var lessonName : String
    var sorthSchoolName: String
    var major : String
    var isExist : Bool = false
    //MARK:- lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Ders Hakkında"
        view.backgroundColor = .white
        setNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismisVC))
        configureCollectionView()
        getTeacherInfo()
        UserService.shared.fetchFallowers(sorthSchoolName, major, lessonName) {[weak self] (user) in
            self?.list.append(user)
            self?.collectionview.reloadData()
        }

    }

    init(lessonName : String , major : String , sorthSchoolName : String){
        self.lessonName = lessonName
        self.major = major
        self.sorthSchoolName = sorthSchoolName
        print(self.lessonName)
        print(self.sorthSchoolName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  //MARK:- functions
    private func getTeacherInfo(){
       let db = Firestore.firestore().collection(sorthSchoolName)
                   .document("lesson").collection(major).document(lessonName)
        db.getDocument { (docSnap, err) in
            if err == nil {
                if let doc = docSnap {
                    if (doc.get("teacherName") as! String) == "empty"{
                        self.isExist = false
                    }else{
                        self.isExist = true
                    }
                }
            }
            
        }
    }
 

    
    private func configureCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
             collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
             collectionview.dataSource = self
             collectionview.delegate = self
        collectionview.backgroundColor = .white
        collectionview.register(LessonInfoCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.register(LessonInfoHeaderOne.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdOne)
        collectionview.register(LessonInfoHeaderTwo.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerTwo)
        view.addSubview(collectionview)
        collectionview.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 5, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
    }
    
    @objc func dismisVC (){
        self.dismiss(animated: true, completion: nil)
    }

}
extension LessonInfo : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LessonInfoCell
        cell.user = list[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if isExist {
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdOne, for: indexPath) as! LessonInfoHeaderOne
            header.headerOne.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 114)
                   return header
        }else {
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerTwo, for: indexPath) as! LessonInfoHeaderTwo
            header.headerTwo.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
                   return header
        }
 
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isExist{
            return CGSize(width: self.view.frame.width, height: 114)
        }else{
            return CGSize(width: self.view.frame.width, height: 40)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    
    
    
}
