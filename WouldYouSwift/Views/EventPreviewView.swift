//
//  LoginViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import PureLayout

class EventPreviewView : UIView {
    
    let screenSize = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        setupViews()
    }
    
    func setData(title: String, img: UIImage, description: String) {
        lblTitle.text = title
        imgView.image = img
        lblDescription.text = description
    }
    
    func setupViews() {
        addSubview(containerView)
        containerView.autoPinEdge(toSuperviewEdge: .top, withInset: 20.0)
        containerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20.0)
        containerView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        containerView.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        
        containerIcon.autoSetDimension(.width, toSize: screenSize.width / 3.5)
        containerView.addSubview(containerIcon)
        containerIcon.autoPinEdge(toSuperviewEdge: .left, withInset: 10.0)
        containerIcon.autoPinEdge(toSuperviewEdge: .top, withInset: 10.0)
        containerIcon.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10.0)
        
        containerIcon.addSubview(imgView)
        imgView.autoAlignAxis(.vertical, toSameAxisOf: containerIcon)
        imgView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        containerView.addSubview(lblTitle)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 20.0)
        lblTitle.autoPinEdge(.left, to: .right, of: containerIcon, withOffset: 20.0)
        
        containerView.addSubview(lblDescription)
        lblDescription.autoPinEdge(.top, to: .bottom, of: lblTitle, withOffset: 5.0)
        lblDescription.autoPinEdge(.left, to: .right, of: containerIcon, withOffset: 20.0)
        lblDescription.autoPinEdge(.right, to: .right, of: containerView, withOffset: -20.0)
        
        addSubview(arrow)
        arrow.autoPinEdge(.top, to: .bottom, of: containerView, withOffset: -10)
        arrow.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    let containerView: UIView = {
        let v=UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.backgroundColor = .white
        return v
    }()
    
    let imgView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.autoSetDimension(.width, toSize: 50.0)
        img.autoSetDimension(.height, toSize: 50.0)
        return img
    }()
    
    let arrow: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "arrow")
        img.translatesAutoresizingMaskIntoConstraints=false
        return img
    }()
    
    let containerIcon: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.backgroundColor = FlatWhite()
        return v
    }()
    
    let lblTitle: UILabel = {
        let lbl=UILabel()
        lbl.text = "Name"
        lbl.font = UIFont(name: "Avenir-Black", size: 20)
        lbl.textColor = UIColor.black
        lbl.backgroundColor = UIColor.white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblDescription : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Oblique", size: 15)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.sizeToFit()
        return lbl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
