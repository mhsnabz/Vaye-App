//
//  MapVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 9.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapVC: UIViewController {

    //MARK: - properties
    var currentUser : CurrentUser
     var mapView : MKMapView!
    

    //MARK: -lifeCycle
    init(currentUser : CurrentUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK: - functions
   
    
    fileprivate func configureViews(){
        view.backgroundColor = .white
        setNavigationBar()
        self.navigationController?.navigationBar.topItem?.title = " "
        navigationItem.title = "Konum Ekle"
        setMapViewConfiguration()
    }
    fileprivate func setMapViewConfiguration() {
        mapView = MKMapView()
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
    }
    


}
