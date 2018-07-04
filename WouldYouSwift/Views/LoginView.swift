//
//  ProfileView.swift
//  would_you
//
//  Created by Lucia Maj on 27/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout

protocol LoginViewDelegate {
    func didFinishLogin()
    func register()
}

class LoginView: UIView {
    
    let screenSize = UIScreen.main.bounds
    
    var delegate : LoginViewController?
    
    var shouldSetupConstraints = true
    
    let logoImg : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20.0
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    var logBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = .orange
        btn.setTitle("Log in", for: .normal)
        btn.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        btn.tintColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.autoSetDimension(.width, toSize: 150.0)
        btn.autoSetDimension(.height, toSize: 45.0)
        return btn
    }()
    
    var labelRegister : UIButton = {
        let lbl = UIButton(type: .system)
        lbl.frame = CGRect.zero
        lbl.frame = CGRect.zero
        lbl.setTitle("Are you new? Register now", for: .normal)
        lbl.tintColor = UIColor.orange
        lbl.addTarget(self, action: #selector(register), for: .touchUpInside)
        return lbl
    }()
    
    @objc func logIn () {
        delegate?.didFinishLogin()
    }
    
    @objc func register () {
        delegate?.register()
    }
    
    let emailTxt : UITextField = {
        let email = UITextField(frame: CGRect.zero)
        email.placeholder = "Your email"
        email.borderStyle = UITextBorderStyle.roundedRect
        email.autoSetDimension(.width, toSize: 300.0)
        email.autoSetDimension(.height, toSize: 50.0)
        email.autocapitalizationType = .none
        return email
    }()
    
    let passwordTxt : UITextField = {
        let pass = UITextField(frame: CGRect.zero)
        pass.placeholder = "Your password"
        pass.isSecureTextEntry = true
        pass.borderStyle = UITextBorderStyle.roundedRect
        pass.backgroundColor = .white
        pass.translatesAutoresizingMaskIntoConstraints = false
        pass.autoSetDimension(.width, toSize: 300.0)
        pass.autoSetDimension(.height, toSize: 50.0)
        pass.text = pass.text?.lowercased()
        pass.autocapitalizationType = .none
        return pass
    }()
    
    var arrayReg = [UIControl]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(logoImg)
        self.addSubview(logBtn)
        self.addSubview(emailTxt)
        self.addSubview(passwordTxt)
        self.addSubview(labelRegister)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            
            logoImg.autoPinEdge(toSuperviewEdge: .top, withInset: screenSize.height / 4)
            logoImg.autoAlignAxis(toSuperviewAxis: .vertical)
            emailTxt.autoPinEdge(.top, to: .bottom, of: logoImg, withOffset: 20)
            emailTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            passwordTxt.autoPinEdge(.top, to: .bottom, of: emailTxt, withOffset: 20)
            passwordTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            logBtn.autoPinEdge(.top, to: .bottom, of: passwordTxt, withOffset: 20)
            logBtn.autoAlignAxis(toSuperviewAxis: .vertical)
            labelRegister.autoPinEdge(.top, to: .bottom, of: logBtn, withOffset: 10)
            labelRegister.autoAlignAxis(toSuperviewAxis: .vertical)
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
}
