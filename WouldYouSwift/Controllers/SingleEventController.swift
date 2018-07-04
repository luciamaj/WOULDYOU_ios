//
//  DetailsVC.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import JJFloatingActionButton
import ChameleonFramework
import GooglePlaces
import GoogleMaps
import EventKit
import EventKitUI
import AFDateHelper
import Eureka
import SwiftyPlistManager
import Toucan
import Presentation

class SingleEventController : UIViewController, SingleEventViewDelegate, GMSMapViewDelegate {
    
    func partecipants() {
        self.performSegue(withIdentifier: "partecipants", sender: nil)
    }
    
    var categoryColors : [UIColor] = [UIColor.flatRed, UIColor.flatGreen, UIColor.flatPurple, UIColor.flatSkyBlue]
    
    var imageIcons : [[UIImage]] = [[UIImage(named: "gamePINresized")!, UIImage(named: "sportPINresized")!, UIImage(named:"culturePINresized")!, UIImage(named: "foodPINresized")!],[UIImage(named: "pinrossoresized")!, UIImage(named: "pinverderesized")!, UIImage(named: "pinviolaresized")!, UIImage(named: "pinbluresized")!]]
    
    let eventStore = EKEventStore()
    
    let screenSize = UIScreen.main.bounds
    
    var json = JSON()
    
    var partecipation = 0
    var idPartecipation : String?
    
    func partHandlerBtn() {
        switch self.partecipation {
        case 0 :
            self.partecipate()
        case 1 :
            self.deletePartecipation()
        case 2 :
            self.deleteEvent()
        default:
            print("Error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            let view = segue.destination as! ConversationViewController
            
            view.number = number
        }
        
        else if segue.identifier == "editEvent" {
            let view = segue.destination as! EditEventViewController
            
            view.number = number
        }
        
        else if segue.identifier == "partecipants" {
            let view = segue.destination as! PartecipantsViewController
            
            view.number = number
        }
    }
    
    let myScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints=false
        scrollView.showsVerticalScrollIndicator=false
        scrollView.showsHorizontalScrollIndicator=false
        return scrollView
    }()
    
    let containerView: UIView = {
        let v=UIView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    func chat() {
        performSegue(withIdentifier: "goToChat", sender: nil)
    }
    
    var number : String!
    
    var eventView: SingleEventView!
    
    override func viewWillAppear(_ animated: Bool) {
        getData {
            self.setupContraints()
            self.setContent()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        eventView = SingleEventView(frame: CGRect.zero)
        eventView.delegate = self
        view.backgroundColor = UIColor.flatWhite
    }
    
    let myMapView: GMSMapView = {
        let v=GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: (self.json["lat"].doubleValue), longitude: (self.json["long"].doubleValue), zoom: 10.0)
        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView.isMyLocationEnabled = true
    }
    
    @objc func navigate() {
        self.performSegue("editEvent")
    }
    
    func setContent () {
        let position = CLLocationCoordinate2D(latitude: (self.json["lat"].doubleValue), longitude: (self.json["long"].doubleValue))
        let eventPos = GMSMarker(position: position)
        eventPos.title = self.json["name"].stringValue
        eventPos.icon = Toucan(image: self.imageIcons[(self.json["tipology_id"].int)! - 1][(self.json["category_id"].int)! - 1]).resize(CGSize(width: 40, height: 40), fitMode: Toucan.Resize.FitMode.clip).image
        eventPos.map = self.myMapView
        self.initGoogleMaps()
        self.navigationItem.title = self.json["name"].stringValue.uppercased()
        self.eventView.nameLabel.text = self.json["name"].stringValue.uppercased()
        self.eventView.nameLabel.textColor = self.categoryColors[(self.json["category_id"].int)! - 1]
        self.eventView.descriptionLabel.text = self.json["description"].stringValue
        self.eventView.whenLabel.text = UTCToLocal(date: (self.json["time_start_event"].stringValue))
        self.eventView.partecipantsLabel.text = "\(self.json["users_events"].count)"
        self.eventView.categoryImg.image = self.imageIcons[(self.json["tipology_id"].int)! - 1][(self.json["category_id"].int)! - 1]
        
        switch (self.json["category_id"].stringValue) {
            case "1":
                self.eventView.categoryLbl.text = "Entertainment - "
            case "2":
                self.eventView.categoryLbl.text = "Sport - "
            case "3":
                self.eventView.categoryLbl.text = "Culture - "
            case "4":
                self.eventView.categoryLbl.text = "Food - "
            default :
                self.eventView.categoryLbl.text = " - "
        }
        
        switch (self.json["tipology_id"].stringValue) {
            case "2":
                self.eventView.tipologyLbl.text = "Temporary"
            case "1":
                self.eventView.tipologyLbl.text = "Programmed"
            default :
                self.eventView.tipologyLbl.text = " "
        }
        
        if (self.partecipation == 1) {
            self.eventView.partBtn.backgroundColor = UIColor.red
            self.eventView.partBtn.setTitle("Annulla partecipazione", for: .normal)
            self.eventView.chatBtn.isEnabled = true
        }
        else if (self.partecipation == 0) {
            self.eventView.partBtn.backgroundColor = UIColor.flatGreen
            self.eventView.partBtn.setTitle("Partecipa", for: .normal)
            self.eventView.chatBtn.isEnabled = false
        }
        else if (self.partecipation == 2) {
            self.eventView.partBtn.backgroundColor = UIColor.flatRed
            self.eventView.partBtn.setTitle("Elimina evento", for: .normal)
            
            let editBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickButton(sender:)))
            
            self.navigationItem.setRightBarButtonItems([editBtn], animated: true)
            
            self.navigationItem.setRightBarButtonItems([editBtn], animated: true)
        }
    }
    
    @objc func clickButton(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: "editEvent", sender: nil)
    }
    
    func setupContraints() {
        self.view.addSubview(myScrollView)
        myScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        myScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        myScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        myScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive=true
        myScrollView.contentSize.height = 600
        
        myScrollView.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: myScrollView.centerXAnchor).isActive=true
        containerView.topAnchor.constraint(equalTo: myScrollView.topAnchor).isActive=true
        containerView.widthAnchor.constraint(equalTo: myScrollView.widthAnchor).isActive=true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive=true
        
        containerView.addSubview(eventView)
        
        containerView.addSubview(myMapView)
        myMapView.autoSetDimension(.height, toSize: screenSize.height / 6)
        myMapView.autoPinEdge(toSuperviewEdge: .bottom)
        myMapView.autoPinEdge(toSuperviewEdge: .left)
        myMapView.autoPinEdge(toSuperviewEdge: .right)
        
        eventView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
    }
    
    func deleteEvent() {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "event/" + number!, method: .delete, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("\(fetchedValue)" + "event/" + self.number!)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func deletePartecipation() {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "user-event/" + idPartecipation!, method: .delete, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    self.partecipation = 0
                    self.getData {
                        self.setupContraints()
                        self.setContent()
                    }
                case .failure(let error):
                    /*let data = JSON(response.result.value ?? "There was an error")
                    let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                    print(error)
                    //self.present(alert, animated: true)
                }
        }
    }
    
    func getData(completion: @escaping () -> Void) {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "event/" + number, method: .get, headers: headers).responseJSON { response in
            switch response.result {
                case .success:
                        let data = response.result.value
                        self.json = JSON(data ?? "")
                        print(self.json)
                        if (Defaults[.id] == self.json["user_id"].stringValue) {
                            self.partecipation = 2
                        }
                        else {
                            for i in 0..<self.json["users_events"].count {
                                if (Defaults[.id] == self.json["users_events"][i]["user_id"].stringValue) {
                                    self.partecipation = 1
                                    self.idPartecipation = self.json["users_events"][i]["id"].stringValue
                                    print("id partecipazione")
                                }
                            }
                        }
                    completion()
                case .failure(let error):
                    /*let data = JSON(response.result.value ?? "There was an error")
                    let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                    print(error)
                    //self.present(alert, animated: true)
            }
        }
    }
    
    func partecipate() {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "user-event/" + number, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                print(response.result)
                self.partecipation = 1
                print("number", "\(fetchedValue)" + "event/" + self.number!)
                self.getData {
                    self.setupContraints()
                    self.setContent()
                }
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    func addToCalendar() {
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let alert2 = UIAlertController(title: "Save the event", message: "Do you want to save the event in the calendar?", preferredStyle: UIAlertControllerStyle.alert)
                
                alert2.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    let event : EKEvent = EKEvent(eventStore: eventStore)
                    event.title = self.json["name"].stringValue
                    event.notes = self.json["description"].stringValue
                    event.startDate = self.fromStringToDate(date: (self.json["time_start_event"].stringValue))
                    event.endDate = self.fromStringToDate(date: (self.json["time_end_event"].stringValue))
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                        let alert = UIAlertController(title: "Event saved", message: "The event was saved in the calendar", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    catch let error as NSError {
                        print(error)
                    }
                }))                
                alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("The event was not saved")
                }))
                self.present(alert2, animated: true, completion: nil)
            } else {
                print("access not granted")
            }
        })
    }
}
