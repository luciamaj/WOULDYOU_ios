//
//  myCell.swift
//  wouldyou
//
//  Created by Lucia Maj on 30/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout


class MessageCell: UICollectionViewCell {
    
    let screenSize = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        addSubview(textBubbleView)
        addSubview(contentLabel)
        addSubview(profileImgView)
        addSubview(sentLabel)
        
        setConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let contentLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.sizeToFit()
        return lbl
    }()
    
    let sentLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Avenir-Light", size: 11)
        lbl.textColor = UIColor.gray
        return lbl
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 15
        img.layer.masksToBounds = true
        return img
    }()
    
    func setConstrains () {
        profileImgView.autoPinEdge(.right, to: .left, of: textBubbleView)
        sentLabel.autoPinEdge(.top, to: .bottom, of: textBubbleView, withOffset: 3.0)
        sentLabel.autoPinEdge(.right, to: .right, of: textBubbleView, withOffset: -10.0)
        profileImgView.autoSetDimension(.width, toSize: 30)
        profileImgView.autoSetDimension(.height, toSize: 30)
        profileImgView.backgroundColor = UIColor.red
    }
}
