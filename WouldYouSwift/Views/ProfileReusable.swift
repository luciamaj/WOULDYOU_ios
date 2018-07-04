//
//  HeaderReusable.swift
//  WeatherApp
//
//  Created by Lucia Maj on 03/04/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout

class ProfileReusable: UICollectionReusableView {
    
    let screenSize = UIScreen.main.bounds

    let profileImg : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20.0
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir-Medium", size: 15)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    let ageLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir-Book", size: 12)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    let genderLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir-Book", size: 12)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    let descriptionLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = ""
        lbl.font = UIFont(name: "Avenir-Light", size: 12)
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        profileImg.autoSetDimension(.width, toSize: screenSize.width / 4)
        profileImg.autoSetDimension(.height, toSize: screenSize.width / 4)
        
        addSubview(profileImg)
        addSubview(nameLabel)
        addSubview(ageLabel)
        addSubview(genderLabel)
        addSubview(descriptionLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImg.autoAlignAxis(toSuperviewAxis: .horizontal)
        profileImg.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        
        nameLabel.autoPinEdge(.left, to: .right, of: profileImg, withOffset: 20.0)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30.0)
        
        ageLabel.autoPinEdge(.left, to: .right, of: profileImg, withOffset: 20.0)
        ageLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 0.0)
        
        genderLabel.autoPinEdge(.left, to: .right, of: ageLabel, withOffset: 0.0)
        genderLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 0.0)
        
        descriptionLabel.autoPinEdge(.left, to: .right, of: profileImg, withOffset: 20.0)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: genderLabel, withOffset: 5.0)
    }
}
