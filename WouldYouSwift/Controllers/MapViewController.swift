//
//  LoginViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import SwiftyJSON
import SegueAddition
import JJFloatingActionButton
import SwiftyUserDefaults
import GoogleMaps
import GooglePlaces
import SwiftyPlistManager

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate {
    
    let actionButton = JJFloatingActionButton()
    let locButton = JJFloatingActionButton()
    var json : JSON?
    
    let currentLocationMarker = GMSMarker()
    var locationManager = CLLocationManager()
    
    let customMarkerWidth: Int = 40
    let customMarkerHeight: Int = 40
    
    var myMapView : GMSMapView?
    
    let txtFieldSearch: UITextField = {
        let tf=UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.white.cgColor
        tf.placeholder="Search for a location"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var eventPreviewView: EventPreviewView = {
        let v = EventPreviewView()
        return v
    }()
    
    var imageIcons : [[UIImage]] = [[UIImage(named: "gamePIN")!, UIImage(named: "sportPIN")!, UIImage(named:"culturePIN")!, UIImage(named: "foodPIN")!],[UIImage(named: "pinrosso")!, UIImage(named: "pinverde")!, UIImage(named: "pinviola")!, UIImage(named: "pinblu")!]]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if (Defaults[.token] == "") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController =  storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginViewController, animated:true, completion:nil)
        }
        else {
            guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
            getData(url: "\(fetchedValue)" + "ins active-events")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        getData(url: "\(fetchedValue)" + "active-events")
        myMapView = GMSMapView()
        myMapView!.translatesAutoresizingMaskIntoConstraints=false

        self.view.backgroundColor = UIColor.white
        myMapView?.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupViews()
        
        initGoogleMaps()
        
        txtFieldSearch.delegate=self
        
        if (self.json != nil) {
            for i in 0..<self.json!.count {
                let lat : Double = self.json![i]["lat"].doubleValue
                let long : Double = self.json![i]["long"].doubleValue
                let eventId : Int = self.json![i]["event_id"].intValue
                let tag : Int = i + 1
                let categoryId = self.json![i]["category_id"].intValue
                let tipologyId = self.json![i]["tipology_id"].intValue
                let img : UIImage = imageIcons[tipologyId - 1][categoryId - 1]
                self.showEventMarkers(lat: lat, long: long, tag: tag, eventId: eventId, img: img, category: categoryId, tipology: tipologyId)
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        return false
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        myMapView?.camera = camera
        txtFieldSearch.text = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 10.0)
        self.myMapView?.camera = camera
        self.myMapView?.delegate = self
        self.myMapView?.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last
        let lat = (location?.coordinate.latitude)!
        let long = (location?.coordinate.longitude)!
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        
        self.myMapView?.animate(to: camera)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return false }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, tag: customMarkerView.tag, eventId: customMarkerView.eventId!)
        
        marker.iconView = customMarker
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return nil }
        let data = json?[customMarkerView.tag - 1]
        let name = data!["name"].stringValue
        let categoryId = data!["category_id"].intValue
        let tipologyId = data!["tipology_id"].intValue
        marker.infoWindowAnchor = CGPoint(x: 0.25, y: 0.1)
        eventPreviewView.setData(title: name.uppercased(), img: imageIcons[tipologyId - 1][categoryId - 1], description: data!["description"].stringValue)
        return eventPreviewView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let eventId = customMarkerView.eventId
        eventTapped(eventId: eventId!)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, tag: customMarkerView.tag, eventId: customMarkerView
            .eventId!)
        marker.iconView = customMarker
    }
    
    func showEventMarkers(lat: Double, long: Double, tag: Int, eventId: Int, img: UIImage, category: Int, tipology: Int) {
        let marker=GMSMarker()
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, tag: tag, eventId: eventId)
        marker.iconView=customMarker
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.map = self.myMapView
        print(tag)
    }
    
    @objc func eventTapped(eventId: Int) {
        performSegue("details") { segue in
            guard let toViewController = segue.destination as? SingleEventController else {
                fatalError()
            }
            toViewController.number = "\(eventId)"
        }
    }
    
    func setupTextField(textField: UITextField, img: UIImage){
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    func setupViews() {
        view.addSubview(myMapView!)
        myMapView!.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        myMapView!.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        myMapView!.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        myMapView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        self.view.addSubview(txtFieldSearch)
        txtFieldSearch.autoSetDimension(.height, toSize: 50.0)
        txtFieldSearch.borderStyle = .none
        txtFieldSearch.autoPinEdge(toSuperviewEdge: .top)
        txtFieldSearch.autoPinEdge(toSuperviewEdge: .left)
        txtFieldSearch.autoPinEdge(toSuperviewEdge: .right)
        setupTextField(textField: txtFieldSearch, img: (UIImage (named: "target"))!)
        
        eventPreviewView = EventPreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 30, height: 190))
        
        self.view.addSubview(locButton)
        locButton.translatesAutoresizingMaskIntoConstraints = false
        locButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        locButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 90)
        
        locButton.buttonColor = .orange
        locButton.addItem(title: "Loc", image: UIImage(named: "mediumposition")) { item in
            let location: CLLocation? = self.myMapView!.myLocation
            if location != nil {
                self.myMapView!.animate(toLocation: (location?.coordinate)!)
            }
        }
        
        actionButton.buttonColor = .orange
        actionButton.buttonImage = UIImage(named: "littlefilter")
        actionButton.buttonAnimationConfiguration = .transition(toImage: UIImage(named: "littlex")!)
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        actionButton.addItem(title: "Food", image: UIImage(named: "littlefood")?.withRenderingMode(.alwaysTemplate)) { item in
            self.myMapView!.clear()
            self.getData(url: "\(fetchedValue)" + "category/1")
            self.setMarkers()
            print("food")
        }
        
        actionButton.addItem(title: "Culture", image: UIImage(named: "littleculture")?.withRenderingMode(.alwaysTemplate)) { item in
            self.myMapView!.clear()
            self.getData(url: "\(fetchedValue)" + "category/2")
            self.setMarkers()
            print("culture")
        }
        
        actionButton.addItem(title: "Sport", image: UIImage(named: "littlesport")?.withRenderingMode(.alwaysTemplate)) { item in
            self.myMapView!.clear()
            self.getData(url: "\(fetchedValue)" + "category/3")
            self.setMarkers()
            print("sport")
        }
        
        actionButton.addItem( title: "Entertainment", image: UIImage(named: "littleenter")?.withRenderingMode(.alwaysTemplate)) { item in
            self.myMapView!.clear()
            self.getData(url: "\(fetchedValue)" + "category/4")
            self.setMarkers()
            print("fun")
        }
        
        actionButton.addItem(title: "All", image: UIImage(named: "all")?.withRenderingMode(.alwaysTemplate)) { item in
            self.myMapView!.clear()
            self.getData(url: "\(fetchedValue)" + "inactive-events")
            self.setMarkers()
            print("all")
        }
    }
    
    func getData(url: String) {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                self.json = JSON(response.result.value!)
                self.setMarkers()
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    func setMarkers() {
        if (self.json != nil) {
            for i in 0..<self.json!.count {
                let lat : Double = json![i]["lat"].doubleValue
                let long : Double = json![i]["long"].doubleValue
                let eventId : Int = json![i]["id"].intValue
                let tag : Int = i + 1
                let categoryId = self.json![i]["category_id"].intValue
                let tipologyId = self.json![i]["tipology_id"].intValue
                let img = imageIcons[tipologyId - 1][categoryId - 1]
                self.showEventMarkers(lat: lat, long: long, tag: tag, eventId: eventId, img: img, category: categoryId, tipology: tipologyId)
            }
        }
    }
}




