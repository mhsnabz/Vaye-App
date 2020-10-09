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
    
    
    //MARK: - functions
    fileprivate func configureViews(){
        view.backgroundColor = .white
        setNavigationBar()
        self.navigationController?.navigationBar.topItem?.title = " "
        navigationController?.navigationItem.title = "Konum Ekle"
        mapView = MKMapView()
        view.addSubview(mapView)
        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
    }
    


}
