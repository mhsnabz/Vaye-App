//
//  SignUp.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 21.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

private let student = "Cell"
private let teacher = "teacher"

class SignUp: UIViewController,HomeMenuBarSelectedIndex
{
    func getIndex(indexItem: Int) {
        
    }
    var school : SchoolModel?{
        didSet{
            navigationItem.title = school?.shortName.description
        }
    }
    //MARK:--properties
    lazy var collecitonView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    var selectedIndex : Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setNavigationBar()
        setupMenuBar()
        configureUI()
        navigationController?.navigationBar.prefersLargeTitles = false

    }

    lazy var menuBar : SignUpMenuBar = {
        let mb = SignUpMenuBar()
        mb.homeController = self
        return mb
    }()
    private func  setupMenuBar(){
        
        view.addSubview(menuBar)
        menuBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 44)
        menuBar.delegate = self
    }
    private func configureUI(){
        view.addSubview(collecitonView)
        collecitonView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collecitonView.register(StudentSignUp.self, forCellWithReuseIdentifier: student)
        collecitonView.register(TeacherSignUp.self, forCellWithReuseIdentifier: teacher)
        
        
        
    }
    func scrollToIndex ( menuIndex : Int) {
        let index = IndexPath(item: menuIndex, section: 0)
        
        self.collecitonView.isPagingEnabled = false
        self.collecitonView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        self.collecitonView.isPagingEnabled = true
    }
    // MARK: UICollectionViewDataSource


   

}
extension SignUp : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: student, for: indexPath) as! StudentSignUp
            cell.school = school
            cell.rootController = self
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: teacher, for: indexPath) as! TeacherSignUp
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = view.safeAreaInsets.top + view.safeAreaInsets.bottom + 45
        return CGSize(width: view.frame.width, height: view.frame.height - x)
    }
    
}
