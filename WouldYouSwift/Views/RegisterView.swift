//TODO AGGIUNGERE I CONTROLLI

import UIKit
import PureLayout

protocol RegisterViewDelegate {
    func didFinishRegister()
    func login()
}

class RegisterView: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let screenSize = UIScreen.main.bounds
    
    var delegate : RegisterViewController?
    
    var shouldSetupConstraints = true
    
    lazy var logBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = .orange
        btn.setTitle("Register", for: .normal)
        btn.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        btn.tintColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.autoSetDimension(.width, toSize: 150.0)
        btn.autoSetDimension(.height, toSize: 45.0)
        return btn
    }()
    
    lazy var labelRegister : UIButton = {
        let lbl = UIButton(type: .system)
        lbl.frame = CGRect.zero
        lbl.frame = CGRect.zero
        lbl.setTitle("Are you already registered? Log in", for: .normal)
        lbl.tintColor = UIColor.orange
        lbl.addTarget(self, action: #selector(register), for: .touchUpInside)
        return lbl
    }()
    
    let date : UITextField = {
        let date = UITextField(frame: CGRect.zero)
        date.placeholder = "Your birthday"
        date.borderStyle = UITextBorderStyle.roundedRect
        date.autoSetDimension(.width, toSize: 300.0)
        date.autoSetDimension(.height, toSize: 50.0)
        date.inputView = UIView()
        return date
    }()
    
    @objc func logIn () {
        delegate?.didFinishRegister()
    }
    
    @objc func register () {
        delegate?.login()
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
    
    let nameTxt : UITextField = {
        let name = UITextField(frame: CGRect.zero)
        name.placeholder = "Your name"
        name.borderStyle = UITextBorderStyle.roundedRect
        name.autoSetDimension(.width, toSize: 300.0)
        name.autoSetDimension(.height, toSize: 50.0)
        return name
    }()
    
    let gender : UITextField = {
        let gender = UITextField(frame: CGRect.zero)
        gender.placeholder = "Your gender"
        gender.borderStyle = UITextBorderStyle.roundedRect
        gender.autoSetDimension(.width, toSize: 300.0)
        gender.autoSetDimension(.height, toSize: 50.0)
        gender.inputView = UIView()
        return gender
    }()
    
    let surnameTxt : UITextField = {
        let surname = UITextField(frame: CGRect.zero)
        surname.placeholder = "Your surname"
        surname.borderStyle = UITextBorderStyle.roundedRect
        surname.autoSetDimension(.width, toSize: 300.0)
        surname.autoSetDimension(.height, toSize: 50.0)
        return surname
    }()
    
    let passwordTxt : UITextField = {
        let pass = UITextField(frame: CGRect.zero)
        pass.placeholder = "Choose a password"
        pass.isSecureTextEntry = true
        pass.borderStyle = UITextBorderStyle.roundedRect
        pass.autoSetDimension(.width, toSize: 300.0)
        pass.autoSetDimension(.height, toSize: 50.0)
        pass.autocapitalizationType = .none
        return pass
    }()
    
    let confirmPasswordTxt : UITextField = {
        let pass = UITextField(frame: CGRect.zero)
        pass.placeholder = "Confirm your password"
        pass.isSecureTextEntry = true
        pass.borderStyle = UITextBorderStyle.roundedRect
        pass.autoSetDimension(.width, toSize: 300.0)
        pass.autoSetDimension(.height, toSize: 50.0)
        pass.autocapitalizationType = .none
        return pass
    }()
    
    let picker : UIDatePicker = {
        let date = UIDatePicker(frame: CGRect.zero)
        date.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        date.datePickerMode = .date
        return date
    }()
    
    let genders = ["male", "female"]
    
    let genderPicker : UIPickerView = {
        let gender = UIPickerView (frame: CGRect.zero)
        return gender
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = genders[row]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        createDatePicker()
        createGenderPicker()
        
        self.addSubview(nameTxt)
        self.addSubview(surnameTxt)
        self.addSubview(date)
        self.addSubview(gender)
        self.addSubview(emailTxt)
        self.addSubview(passwordTxt)
        self.addSubview(confirmPasswordTxt)
        self.addSubview(logBtn)
        self.addSubview(labelRegister)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            
            let doubleOffset = 20.0
            let fixedOffsets = CGFloat(doubleOffset)
            
            nameTxt.autoPinEdge(toSuperviewEdge: .top, withInset: screenSize.height / 10)
            nameTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            
            surnameTxt.autoPinEdge(.top, to: .bottom, of: nameTxt, withOffset: fixedOffsets)
            surnameTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            
            date.autoPinEdge(.top, to: .bottom, of: surnameTxt, withOffset: fixedOffsets)
            date.autoAlignAxis(toSuperviewAxis: .vertical)
        
            gender.autoPinEdge(.top, to: .bottom, of: date, withOffset: fixedOffsets)
            gender.autoAlignAxis(toSuperviewAxis: .vertical)
            
            emailTxt.autoPinEdge(.top, to: .bottom, of: gender, withOffset: fixedOffsets)
            emailTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            
            passwordTxt.autoPinEdge(.top, to: .bottom, of: emailTxt, withOffset: fixedOffsets)
            passwordTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            
            confirmPasswordTxt.autoPinEdge(.top, to: .bottom, of: passwordTxt, withOffset: fixedOffsets)
            confirmPasswordTxt.autoAlignAxis(toSuperviewAxis: .vertical)
            
            logBtn.autoPinEdge(.top, to: .bottom, of: confirmPasswordTxt, withOffset: fixedOffsets)
            logBtn.autoAlignAxis(toSuperviewAxis: .vertical)
            
            labelRegister.autoPinEdge(.top, to: .bottom, of: logBtn, withOffset: fixedOffsets / 2)
            labelRegister.autoAlignAxis(toSuperviewAxis: .vertical)

            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneDatePressed))
        toolbar.setItems([done], animated: false)
        date.inputAccessoryView = toolbar
        date.inputView = picker
    }
    
    func createGenderPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneGenderPressed))
        toolbar.setItems([done], animated: false)
        gender.inputAccessoryView = toolbar
        gender.inputView = genderPicker
    }
    
    @objc func doneDatePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        date.text = formatter.string(from: picker.date)
        date.resignFirstResponder()
    }
    
    @objc func doneGenderPressed() {
        gender.resignFirstResponder()
    }
}
