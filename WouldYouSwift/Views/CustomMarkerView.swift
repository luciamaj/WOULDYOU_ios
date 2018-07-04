//
//  LoginViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import Foundation
import UIKit

class CustomMarkerView: UIView {
    var img: UIImage!
    var eventId: Int?
    
    init(frame: CGRect, image: UIImage, tag: Int, eventId: Int) {
        super.init(frame: frame)
        self.img = image
        self.tintColor = UIColor.cyan
        self.tag = tag
        self.eventId = eventId
        setupViews()
    }
    
    func setupViews() {
        let imgView = UIImageView(image: img)
        imgView.frame=CGRect(x: 0, y: 0, width: 30, height: 30)
        imgView.clipsToBounds = true
        
        self.addSubview(imgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}









