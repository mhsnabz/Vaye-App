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
import FirebaseFirestore
class MapVC: UIViewController {

    //MARK: - properties
    var currentUser : CurrentUser
    var mapView : MKMapView!
    var locationManager : CLLocationManager?
    var seacrhInputView : SearchInputView!
    weak var coordinateDelegate : CoordinateManagerDelagete?
    weak var route : MKRoute?
     var coordinate : SetNewBuySellVC?
    var choosenAnnotation : MKAnnotation?
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
    let removeRoutateBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "x").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.clipsToBounds = true
        btn.setBackgroundColor(color: .red, forState: .normal)
        btn.alpha = 0
        btn.addTarget(self, action: #selector(handleRemoveRaoutae), for: .touchUpInside)
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
        mapView.delegate = self
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
        
        view.addSubview(removeRoutateBtn)
        removeRoutateBtn.anchor(top: nil, left: view.leftAnchor, bottom: seacrhInputView.topAnchor, rigth: nil, marginTop: 0, marginLeft: 10, marginBottom: view.frame.width / 2 + 10, marginRigth: 0, width: 45, heigth: 45)
        removeRoutateBtn.layer.cornerRadius = 45 / 2
    }
    
    //MARK:-selectors
    @objc func centerMapClick(){
        centerMapInUserLocation(loadAnnotation: false)
    }
    @objc func handleRemoveRaoutae(){
        
        seacrhInputView.directionEnable = false
        UIView.animate(withDuration: 0.5) {
            self.removeRoutateBtn.alpha = 0
            self.centerMapButton.alpha = 1
        }
        if mapView.overlays.count > 0 {
            self.mapView.removeOverlay(mapView.overlays[0])
            centerMapInUserLocation(loadAnnotation: false)
        }
        
        seacrhInputView.disableViewIntercation(directionIsEnabled: false)
        guard let selectedAnno = self.choosenAnnotation else { return }
        mapView.deselectAnnotation(selectedAnno, animated: true)
    }
}

extension MapVC : SearchInputViewDelagete {
    
    
    func selectAnnotation(selectAnnotation mapItem: MKMapItem)
    {
        mapView.annotations.forEach { (annotation ) in
            if annotation.title == mapItem.name{
                self.mapView.selectAnnotation(annotation, animated: true)
                self.zoomToFit(selectedAnnotation: annotation)
                self.choosenAnnotation = annotation
                UIView.animate(withDuration: 0.5) {
                    self.removeRoutateBtn.alpha = 1
                    self.centerMapButton.alpha = 0
                }
          
            }
        }
    }
    
    func addPolyLine(destinationMapItem: MKMapItem) {
//        directionEnable = true
//        seacrhInputView.directionEnable = directionEnable
        seacrhInputView.disableViewIntercation(directionIsEnabled: true)
        genaratePollyLine(forDestinationMapItem: destinationMapItem)
    }
    
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
            if !hideButton{
                UIView.animate(withDuration: 0.25) {
                    self.centerMapButton.alpha = 1.0
                }
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

//MARK: -map view delegate
extension MapVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyLine = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyLine)
            lineRenderer.strokeColor = .mainColor()
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

//MARK: - map kit helper functions
extension MapVC
{
    
    
    func zoomToFit(selectedAnnotation: MKAnnotation?) {
        if mapView.annotations.count == 0 {
            return
        }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if let selectedAnnotation = selectedAnnotation {
            for annotation in mapView.annotations {
                if let userAnno = annotation as? MKUserLocation {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, userAnno.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, userAnno.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, userAnno.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                
                if annotation.title == selectedAnnotation.title {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
            
            var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.65), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 3.0))
            
            region = mapView.regionThatFits(region)
            mapView.setRegion(region, animated: true)
        }
    }
    
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
    
    func genaratePollyLine ( forDestinationMapItem destination : MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { (response, err) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let pollyline = self.route?.polyline else { return }
            self.mapView.addOverlay(pollyline)
            
        }
    }
}
extension MapVC : SearchCellDelegate {
    func getDirection(forMapItem mapItem: MKMapItem) {
//        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        coordinate = SetNewBuySellVC(currentUser: currentUser, followers: [])
        print("title : \(mapItem.placemark.title)")
        print("addres : \(mapItem.placemark.name)")
        
        
//        Utilities.waitProgress(msg: "Konum Ekleniyor")
        let location : GeoPoint = GeoPoint(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        coordinate?.geoPoing = location
        self.navigationController?.popViewController(animated: true)
//        Utilities.succesProgress(msg: "Konum Eklendi")
//        let db = Firestore.firestore().collection("user")
//            .document(currentUser.uid)
//            .collection("coordinate").document("locaiton")
//        let dic = ["geoPoint" : location] as [String : Any]
//        db.setData(dic) { (err) in
//            if err == nil {
//                
//               
//            }
//        }
        
    }
    
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager?.location else { return nil}
        return userLocation.distance(from: location)
    }
    
    
}
