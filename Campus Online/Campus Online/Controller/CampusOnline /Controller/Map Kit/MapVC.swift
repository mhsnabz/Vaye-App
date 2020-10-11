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
    
    let centerMapButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.clipsToBounds = true
        btn.setBackgroundColor(color: .white, forState: .normal)
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.layer.borderWidth = 0.75
        btn.addTarget(self, action: #selector(centerMapClick), for: .touchUpInside)
        return btn
    }()
    
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
        centerMapInUserLocation(loadAnnotation: true)
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
        view.addSubview(centerMapButton)
       
        seacrhInputView = SearchInputView()
        seacrhInputView.delegate = self
        seacrhInputView.mapController = self
        view.addSubview(seacrhInputView)
        seacrhInputView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: -(view.frame.height - 80), marginRigth: 0, width: 0, heigth: view.frame.height)
        centerMapButton.anchor(top: nil, left: nil, bottom: seacrhInputView.topAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 10, marginRigth: 10, width: 45, heigth: 45)
        centerMapButton.layer.cornerRadius = 45 / 2
        
        
    }
    
    //MARK:-selectors
    @objc func centerMapClick(){
        centerMapInUserLocation(loadAnnotation: false)
    }
}

extension MapVC : SearchInputViewDelagete {
    func handleSearch(with SearchText: String) {
        removeAnnotions()
        loadAnnotationByQuery(query: SearchText)
    }
    
    
    
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState , hideButton : Bool) {
        switch expansionState{
        
        case .notExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.frame.origin.y -= self.view.frame.width / 2
            }
            if hideButton{
                self.centerMapButton.alpha = 0.0
            }else{
                self.centerMapButton.alpha = 1.0
            }
        case .partiallyExpanded:
            UIView.animate(withDuration: 0.25) {
                if hideButton {
                    self.centerMapButton.alpha = 0.0
                    }else{
                        UIView.animate(withDuration: 0.25) {
                            self.centerMapButton.frame.origin.y += self.view.frame.width / 2
                        }
                }
                
            }
            //
        case .fullyExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.alpha = 1.0
            }
            
     
        }
    }
    
    func loadAnnotationByQuery( query : String){
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchBy(natureLanguage: query, region: region, coordinate: coordinate) { (response, err) in
            response?.mapItems.forEach({ (mapItem) in
              let annotion = MKPointAnnotation()
                annotion.title = mapItem.name
                annotion.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotion)
            })
            self.seacrhInputView.searchResult = response?.mapItems
        }
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
    func centerMapInUserLocation(loadAnnotation : Bool){
        guard let coordinat = locationManager?.location?.coordinate else { return }
        let coordinateReigon = MKCoordinateRegion(center: coordinat, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateReigon, animated: true)
        if loadAnnotation{
           loadAnnotationByQuery(query: "Market")
        }
    }
    
    func searchBy(natureLanguage : String , region : MKCoordinateRegion , coordinate : CLLocationCoordinate2D , completion : @escaping(_ reposponse : MKLocalSearch.Response? , _ Error : NSError?) ->Void){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = natureLanguage
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { (response, err) in
            guard let response = response else {
                completion(nil, err as NSError? )
                return
                
            }
            completion(response,nil)
            
        }
    }
    
    func removeAnnotions(){
        mapView.annotations.forEach { (annotion) in
            if let annotion = annotion as? MKPointAnnotation{
                mapView.removeAnnotation(annotion)
            }
        }
    }
    
    func loadIntialSeacrData(searchQuery : String){
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchBy(natureLanguage: searchQuery, region: region, coordinate: coordinate) { (response, err) in
            response?.mapItems.forEach({ (mapItem) in
              let annotion = MKPointAnnotation()
                annotion.title = mapItem.name
                annotion.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotion)
            })
        }
    }
    
    
}
extension MapVC : SearchCellDelegate {
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager?.location else { return nil}
        return userLocation.distance(from: location)
    }
    
    
}
