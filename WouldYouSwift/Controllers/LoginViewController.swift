//
//  LoginViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import SwiftyPlistManager

class LoginViewController: UIViewController, LoginViewDelegate, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    var login: LoginView!
    
    func register() {
        self.performSegue(withIdentifier: "register", sender: nil)
    }
    
    func didFinishLogin() {
        if (login.emailTxt.text!.isEmpty || login.passwordTxt.text!.isEmpty) {
            let alert = UIAlertController(title: "Fields missing", message: "Please type your username and password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let email = login.emailTxt.text
            let password = login.passwordTxt.text
            let parameters : Parameters = [
                "email": email!,
                "password": password!,
            ]
            
            guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
            
            let url = "\(fetchedValue)" + "login"
            Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                response.result.ifSuccess {
                    let data = JSON(response.result.value ?? "There was an error")
                    if data["error"] == JSON.null {
                        Defaults[.id] = data["success"]["user_id"].stringValue
                        Defaults[.token] = data["success"]["token"].stringValue
                        print(Defaults[.token])
                        print(Defaults[.id])
                        self.performSegue("logged")
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                if response.result.isFailure == true {
                    let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        let viewController1 = UIViewController()
        viewController1.title = "Controller A"
        
        let viewController2 = UIViewController()
        viewController2.title = "Controller B"
        
        self.hideKeyboardWhenTappedAround()

        login = LoginView(frame: CGRect.zero)
                
        login.delegate = self
        self.view.addSubview(login)
        
        login.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
    }
    
    func addDelegates () {
        login.emailTxt.delegate = self
        login.passwordTxt.delegate = self
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func fromStringToDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: date)
        return myDate!
    }
    
    func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd H:mm:ss"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYY-mm-dd H:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let dt = dateFormatter.date(from: date) else { return "not found" }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd-mm-YYYY H:mm"
        return dateFormatter.string(from: dt)
    }
    
    func UTCToLocalWithSec(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd-mm-YYYY H:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
}

extension DefaultsKeys {
    static let token = DefaultsKey<String>("access_token")
    static let id = DefaultsKey<String>("user_id")
}
