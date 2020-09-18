//
//  OtherUserProfile.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import GoogleMobileAds

private let cellId = "id"
private let profileId = "profileId"
class OtherUserProfile: UIViewController {

    var interstitial : GADInterstitial!
    var currentUser : CurrentUser
    var otherUser : OtherUser
    var collectionview: UICollectionView!
    let titleLbl : UILabel = {
       let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let dissmisButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "down-arrow"), for: .normal)
        
        return btn
    }()
    lazy var headerBar : UIView = {
       let v = UIView()
      
        v.addSubview(dissmisButton)
        dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(titleLbl)
        titleLbl.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLbl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                titleLbl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        return v
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        configureUI()
        configureCollectionView()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807")
        let request = GADRequest()
        interstitial.load(request)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute:
                                        {
                                            if self.interstitial.isReady {
                                                self.interstitial.present(fromRootViewController: self)
                                                self.interstitial = self.createAds()
                                            }else{
                                                print("failed to load")
                                            }
                                        })
    }
    
    init(currentUser : CurrentUser, otherUser : OtherUser) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -functions
    
    func createAds() ->GADInterstitial{
        let inter = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807")
        inter.load(GADRequest())
        return inter
    }
    
    func configureUI(){
         view.backgroundColor = .white
         view.addSubview(headerBar)
        headerBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 60)
         dissmisButton.addTarget(self, action: #selector(dissmis), for: .touchUpInside)
        titleLbl.text = otherUser.username
     }
    
    func configureCollectionView(){
             let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
             collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
//        collectionview.contentInsetAdjustmentBehavior = .never
             collectionview.dataSource = self
             collectionview.delegate = self
             collectionview.backgroundColor = .white
             collectionview.register(ProfileCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileId)
             view.addSubview(collectionview)
        collectionview.anchor(top: headerBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
         }
    
   
    
    //MARK:- selector
    @objc func dismissVC(){
        self.dismiss(animated: true) {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    @objc func dissmis(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
extension OtherUserProfile : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell
      
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 246)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileId, for: indexPath) as! ProfileHeader
            header.otherUser = otherUser
        
        return header
    }
    
}
enum GameState: NSInteger {
   case notStarted
   case playing
   case paused
   case ended
 }
