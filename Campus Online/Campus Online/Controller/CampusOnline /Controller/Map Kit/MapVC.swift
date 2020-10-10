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
    var locationManager : CLLocationManager?
    var seacrhInputView : SearchInputView!
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
        enableLocaitonMenager()
        configureViews()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        centerMapInUserLocation()
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
        seacrhInputView = SearchInputView()
        view.addSubview(seacrhInputView)
        seacrhInputView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: -(view.frame.height - 80), marginRigth: 0, width: 0, heigth: view.frame.height)
    }
    


}
extension MapVC : CLLocationManagerDelegate {
    func enableLocaitonMenager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        switch CLLocationManager.authorizationStatus(){
        
        case .notDetermined:
            DispatchQueue.main.async {
                let vc = MapKitPermissonVC()
                vc.modalPresentationStyle = .fullScreen
                vc.locationManager = self.locationManager
                self.present(vc, animated: true, completion: nil)
            }
            
        case .restricted:
            print("")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("always")
        case .authorizedWhenInUse:
            print("when used permission")
        @unknown default:
            print("nil")
        }
    }
}
//MARK: - map kit helper functions
extension MapVC
{
    func centerMapInUserLocation(){
        guard let coordinat = locationManager?.location?.coordinate else { return }
        let coordinateReigon = MKCoordinateRegion(center: coordinat, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateReigon, animated: true)
    }
}
