//
//  myCell.swift
//  wouldyou
//
//  Created by Lucia Maj on 30/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout
import ChameleonFramework

class ProfileCell: UICollectionViewCell {
    
    let screenSize = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        colorView.autoSetDimension(.width, toSize: screenSize.width)
        colorView.autoSetDimension(.height, toSize: screenSize.height)
        
        addSubview(colorView)
        addSubview(descriptionLabel)
        addSubview(nameLabel)
        addSubview(timeLabel)
        
        setConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let colorView : UIView = {
        let color = UIView(frame: CGRect.zero)
        return color
    }()
    
    let nameLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Black", size: 30)
        lbl.textColor = UIColor.white
        return lbl
    }()
    
    let timeLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = lbl.text?.uppercased()
        lbl.font = UIFont(name: "Avenir-Black", size: 20)
        lbl.textColor = UIColor.white
        return lbl
    }()
    
    let descriptionLabel : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Light", size: 20)
        lbl.textColor = UIColor.white
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.frame.size.width = 300
        lbl.sizeToFit()
        return lbl
    }()
    
    func setConstrains () {
        
        colorView.autoAlignAxis(toSuperviewAxis: .vertical)
        colorView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        nameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
        nameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 15.0)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 15.0)
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 15.0)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: nameLabel)
        
        timeLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 15.0)
        timeLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 15.0)
    }
}
