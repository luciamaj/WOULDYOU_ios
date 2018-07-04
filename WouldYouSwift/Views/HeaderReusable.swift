//
//  HeaderReusable.swift
//  WeatherApp
//
//  Created by Lucia Maj on 03/04/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout

class HeaderReusable: UICollectionReusableView {
    
    let screenSize = UIScreen.main.bounds
    
    var segmentedControl: UISegmentedControl = {
        var v = UISegmentedControl(frame: CGRect.zero)
        v = UISegmentedControl(items: ["All events", "Events I'm in"])
        v.backgroundColor = .clear
        v.tintColor = .clear
        v.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 18)!,
            NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        v.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 18)!,
            NSAttributedStringKey.foregroundColor: UIColor.orange
            ], for: .selected)
        v.addTarget(self, action: #selector(EventsViewController.segmentedValueChanged(_:)), for: .valueChanged)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        segmentedControl.autoSetDimension(.width, toSize: screenSize.width / 1.2)
        
        segmentedControl.selectedSegmentIndex = 0
        
        addSubview(segmentedControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        segmentedControl.autoAlignAxis(toSuperviewAxis: .vertical)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
}
