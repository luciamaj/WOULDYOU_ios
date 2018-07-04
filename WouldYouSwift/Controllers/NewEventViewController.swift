//
//  LoginViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON
import Eureka
import CoreLocation
import GoogleMaps
import GooglePlaces
import PureLayout
import ChameleonFramework
import SwiftyPlistManager

class NewEventViewController: FormViewController, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    var address = ""
    var lat : Double = 0.0
    var long : Double = 0.0
    var tipology = 1
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var locationManager = CLLocationManager()
    
    func didConfirm() {
        addEvent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        
        form +++
            
            TextRow("Name") {
                $0.title = "Name:"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< TextAreaRow("Description") {
                $0.placeholder = "Description:"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< SegmentedRow<String>("Category"){
                $0.options = ["Fun", "Sport", "Culture", "Food"]
                $0.value = "One"
                $0.cell.tintColor = .orange
            }
            
            <<< TextRow("Place") {
                $0.title = "Chosen location:"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< ButtonRow() {
                $0.title = "Choose the location"
                }
                .onCellSelection { cell, row in
                    let autoCompleteController = GMSAutocompleteViewController()
                    autoCompleteController.delegate = self
                    
                    let filter = GMSAutocompleteFilter()
                    autoCompleteController.autocompleteFilter = filter
                    
                    self.locationManager.startUpdatingLocation()
                    self.present(autoCompleteController, animated: true, completion: nil)
            }
            
        <<< SwitchRow("Temporary") {
            $0.title = "Typology: "
            }.onChange { [weak self] row in
                let startDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                let endDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                
                if row.value ?? false {
                    self?.tipology = 2
                }
                    
                else {
                    self?.tipology = 1
                }
                
                startDate.updateCell()
                endDate.updateCell()
                startDate.inlineRow?.updateCell()
                endDate.inlineRow?.updateCell()
            }
            
            <<< DateTimeInlineRow("Starts") {
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*24)
                $0.disabled = .function(["Temporary"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Temporary")
                    return row.value ?? true == true
                })
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }
                .onExpandInlineRow { [weak self] cell, row, inlineRow in
                    inlineRow.cellUpdate() { cell, row in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "Temporary")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }
            
            <<< DateTimeInlineRow("Ends"){
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*25)
                $0.disabled = .function(["Temporary"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Temporary")
                    return row.value ?? true == true
                })
                }
                .onChange { [weak self] row in
                    let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    if row.value?.compare(startRow.value!) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                    }
                    else{
                        row.cell!.backgroundColor = .white
                    }
                    row.updateCell()
                }
                .onExpandInlineRow { [weak self] cell, row, inlineRow in
                    inlineRow.cellUpdate { cell, dateRow in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "Temporary")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Create the new event"
                $0.cell.backgroundColor = .orange
                $0.cell.tintColor = .white
                }
                .onCellSelection { cell, row in
                    row.section?.form?.validate()
                    if (self.form.validate().isEmpty) {
                        self.addEvent()
                    }
            }
        
    }

    @objc func addEvent() {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        print(self.form.values())

        var startTime : Date?
        var startString : String?
        var endTime : Date?
        var endString : String?
        
        if(self.tipology == 1) {
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startString = formatter.string(from: date)
            let hoursToAdd = 2
            var dateComponent = DateComponents()
            dateComponent.hour = hoursToAdd
            
            endTime = Calendar.current.date(byAdding: dateComponent, to: date)
            endString = formatter.string(from: endTime!)
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            startTime = form.rowBy(tag: "Starts")!.baseValue! as? Date
            endTime = form.rowBy(tag: "Ends")!.baseValue! as? Date
            endString = formatter.string(from: endTime!)
            startString = formatter.string(from: startTime!)
        }
        
        let segmentedValue = form.rowBy(tag: "Category")!.baseValue! as! String
        
        var category = ""
        
        print(self.lat)
        print(self.long)
        
        switch segmentedValue {
            case "Fun":
                category = "1"
            case "Sport":
                category = "2"
            case "Culture":
                category = "3"
            case "Food":
                category = "4"
            default:
                category = "1"
        }
        
        let parameters : Parameters = [
            "name" : form.rowBy(tag: "Name")!.baseValue!,
            "description" : form.rowBy(tag: "Description")!.baseValue!,
            "lat" : self.lat,
            "long" : self.long,
            "time_start_event" : startString!,
            "time_end_event" : endString!,
            "category_id" : category,
            "tipology_id" : self.tipology,
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "events", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJson = JSON(value)
                print (swiftyJson)
                _ = self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    func setupTextField(textField: UITextField, img: UIImage){
        textField.leftViewMode = UITextFieldViewMode.always
        textField.placeholder = "Search a location"
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
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
        self.lat = place.coordinate.latitude
        self.long = place.coordinate.longitude
        
        self.address = place.formattedAddress!
        let placeLabl: TextRow! = self.form.rowBy(tag: "Place")
        placeLabl.baseValue = self.address
        self.dismiss(animated: true, completion: nil)
    }
}

