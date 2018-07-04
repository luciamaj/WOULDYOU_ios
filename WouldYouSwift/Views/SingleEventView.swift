//
//  ProfileView.swift
//  would_you
//
//  Created by Lucia Maj on 27/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout
import ChameleonFramework

protocol SingleEventViewDelegate {
    func chat()
    func partHandlerBtn()
    func partecipants()
    func addToCalendar()
}

class SingleEventView: UIView {
    
    let screenSize = UIScreen.main.bounds
    
    var delegate : SingleEventController?
    
    var shouldSetupConstraints = true
    
    var nameLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = lbl.text?.uppercased()
        lbl.font = UIFont(name: "Avenir-Black", size: 35)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    let descriptionLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Oblique", size: 20)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    let whenLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Light", size: 15)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    let partecipantsLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Light", size: 15)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.text = "60 partecipanti"
        lbl.sizeToFit()
        return lbl
    }()
    
    let categoryImg : UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    let categoryLbl : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Black", size: 15)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    let tipologyLbl : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Black", size: 15)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    lazy var addToCalendarBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = ClearColor()
        btn.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.autoSetDimension(.height, toSize: 30.0)
        btn.autoSetDimension(.width, toSize: 30.0)
        btn.setImage(UIImage(named: "add-to-calendar"), for: .normal)
        btn.tintColor = UIColor.orange
        return btn
    }()
    
    lazy var seePartecipantsBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = ClearColor()
        btn.addTarget(self, action: #selector(partecipants), for: .touchUpInside)
        btn.tintColor = UIColor.clear
        btn.layer.cornerRadius = 5
        btn.autoSetDimension(.height, toSize: 30.0)
        btn.autoSetDimension(.width, toSize: 30.0)
        btn.setImage(UIImage(named: "see-partecipants"), for: .normal)
        btn.tintColor = UIColor.orange
        return btn
    }()
    
    lazy var chatBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = FlatWhiteDark()
        btn.setTitle("See the conversation", for: .normal)
        btn.addTarget(self, action: #selector(chat), for: .touchUpInside)
        btn.tintColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.autoSetDimension(.height, toSize: screenSize.width / 8)
        return btn
    }()
    
    lazy var partBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect.zero
        btn.backgroundColor = .orange
        btn.setTitle("Partecipate", for: .normal)
        btn.addTarget(self, action: #selector(partHandlerBtn), for: .touchUpInside)
        btn.tintColor = UIColor.white
        btn.layer.cornerRadius = 15
        btn.autoSetDimension(.height, toSize: screenSize.width / 8)
        return btn
    }()
    
    @objc func chat () {
        delegate?.chat()
    }
    
    @objc func addToCalendar () {
        delegate?.addToCalendar()
    }
    
    @objc func partecipants () {
        delegate?.partecipants()
    }
    
    @objc func partHandlerBtn () {
        delegate?.partHandlerBtn()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        nameLabel.autoSetDimension(.width, toSize: screenSize.width / 1.5)
        self.addSubview(nameLabel)
        self.addSubview(tipologyLbl)
        self.addSubview(categoryLbl)
        self.addSubview(descriptionLabel)
        self.addSubview(addToCalendarBtn)
        self.addSubview(whenLabel)
        self.addSubview(seePartecipantsBtn)
        self.addSubview(partBtn)
        self.addSubview(chatBtn)
        self.addSubview(partecipantsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            nameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 40.0)
            nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 60.0)
            
            categoryLbl.autoPinEdge(toSuperviewEdge: .left, withInset: 40.0)
            categoryLbl.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 10.0)
            
            tipologyLbl.autoPinEdge(.left, to: .right, of: categoryLbl)
            tipologyLbl.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 10.0)
            
            descriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 40.0)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 40.0)
            descriptionLabel.autoPinEdge(.top, to: .bottom, of: categoryLbl, withOffset: 20.0)
            
            addToCalendarBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 40.0)
            addToCalendarBtn.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 30.0)
            
            whenLabel.autoAlignAxis(.horizontal, toSameAxisOf: addToCalendarBtn)
            whenLabel.autoPinEdge(.left, to: .right, of: addToCalendarBtn, withOffset: 20.0)
            
            seePartecipantsBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 40.0)
            seePartecipantsBtn.autoPinEdge(.top, to: .bottom, of: addToCalendarBtn, withOffset: 20.0)
            
            partecipantsLabel.autoAlignAxis(.horizontal, toSameAxisOf: seePartecipantsBtn)
            partecipantsLabel.autoPinEdge(.left, to: .right, of: seePartecipantsBtn, withOffset: 20.0)
            
            partBtn.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            partBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            partBtn.autoPinEdge(.top, to: .bottom, of: whenLabel, withOffset: 80.0)
            
            chatBtn.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
            chatBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
            chatBtn.autoPinEdge(.top, to: .bottom, of: partBtn, withOffset: 10.0)
            
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
}
