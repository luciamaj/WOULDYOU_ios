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

class RegisterViewController: UIViewController, RegisterViewDelegate, UITextFieldDelegate {
    
    func login() {
        self.performSegue(withIdentifier: "backToLog", sender: nil)
    }
    
    let emailTxt : UITextField = {
        let email = UITextField(frame: CGRect.zero)
        email.placeholder = "Insert your message"
        email.borderStyle = UITextBorderStyle.roundedRect
        email.autoSetDimension(.width, toSize: 300.0)
        email.autoSetDimension(.height, toSize: 50.0)
        return email
    }()
    
    func didFinishRegister() {
        if (register.nameTxt.text!.isEmpty || register.surnameTxt.text!.isEmpty || register.gender.text!.isEmpty || register.date.text!.isEmpty || register.emailTxt.text!.isEmpty || register.passwordTxt.text!.isEmpty || register.confirmPasswordTxt.text!.isEmpty) {
                let alert = UIAlertController(title: "Fields missing", message: "Please fill all the fields", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            } else {
                let name = register.nameTxt.text!
                let surname = register.surnameTxt.text!
                let gender = register.gender.text!
                let bday = register.date.text!
                let email = register.emailTxt.text!
                let pass = register.passwordTxt.text!
                let confirmPass = register.confirmPasswordTxt.text!
                
                let parameters: Parameters = [
                "name": name,
                "second_name": surname,
                "gender": gender,
                "email": email,
                "password": pass,
                "password_confirmation": confirmPass,
                "birthday": bday,
                "admin": 0
                ]
                
                guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
                
                let url = "\(fetchedValue)" + "register"
                
                Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                response.result.ifSuccess {
                    let data = JSON(response.result.value ?? "There was an error")
                    if data["error"] == JSON.null {
                    self.performSegue(withIdentifier: "registered", sender: nil)
                    Defaults[.token] = data["success"]["token"].stringValue
                    print(Defaults[.token])
                    }
                    else {
                    let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    print(data)
                    self.present(alert, animated: true)
                    }
                }
                if response.result.isFailure == true {
                    /*let alert = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)*/
                    print("there was an error")
                }
            }
        }
    }
    
    var register: RegisterView!
    
    override func viewDidLoad() {
        
        emailTxt.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        register = RegisterView(frame: CGRect.zero)
        
        register.delegate = self
        self.view.addSubview(register)
        
        addDelegates()
        
        register.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addDelegates () {
        register.nameTxt.delegate = self
        register.surnameTxt.delegate = self
        register.emailTxt.delegate = self
        register.passwordTxt.delegate = self
        register.confirmPasswordTxt.delegate = self
    }
}
