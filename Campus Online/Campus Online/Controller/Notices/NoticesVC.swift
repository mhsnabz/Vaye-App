//
//  NoticesVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class NoticesVC: UIViewController {
    
    //MARK:- properites
    var collectionview: UICollectionView!
    
    var delegate : HomeControllerDelegate?
    var isMenuOpen : Bool = false


    let newPostButton : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "new-post")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
    }()
    
    
    var currentUser : CurrentUser
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
       
        setNavigationBar()
        navigationItem.title = currentUser.short_school + " Kulüp"
        
        configureUI()
    }
    
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- functions
    private func configureUI(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
//        collectionview.dataSource = self
//        collectionview.delegate = self
        collectionview.backgroundColor = .collectionColor()
        view.addSubview(collectionview)
        collectionview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        view.addSubview(newPostButton)
        newPostButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 12, marginRigth: 12, width: 50, heigth: 50)
        newPostButton.addTarget(self, action: #selector(newPost), for: .touchUpInside)
        newPostButton.layer.cornerRadius = 25
    }
    
    //MARK:-selector
    @objc func newPost(){
       
        let vc = ChooseClub(currentUser: currentUser, dataSource: NoticesService.shared.getHastag(currentUser: currentUser))
        navigationController?.pushViewController(vc, animated: true)
    }
     @objc func menuClick(){
        print("deneme")
//        dismiss(animated: true, completion: nil)
            self.delegate?.handleMenuToggle(forMenuOption: nil)
            if !isMenuOpen {
                self.isMenuOpen = false
            }
            else{
             self.isMenuOpen = true

         }
        }

}

//extension NoticesVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//
//
//}
