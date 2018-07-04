import UIKit
import PureLayout

class PartecipantCell: UITableViewCell {
    
    let nameLbl : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Light", size: 15)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    let profileImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 15
        img.layer.masksToBounds = true
        img.autoSetDimension(.width, toSize: 30.0)
        img.autoSetDimension(.height, toSize: 30.0)
        return img
    }()
    
    let surnameLbl : UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont(name: "Avenir-Light", size: 15)
        lbl.textColor = UIColor.black
        return lbl
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImgView)
        contentView.addSubview(nameLbl)
        contentView.addSubview(surnameLbl)
        
        setConstraints()
    }
    
    func setConstraints() {
        profileImgView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0)
        profileImgView.autoAlignAxis(toSuperviewAxis: .horizontal)
        nameLbl.autoPinEdge(.left, to: .right, of: profileImgView, withOffset: 10.0)
        nameLbl.autoAlignAxis(toSuperviewAxis: .horizontal)
        surnameLbl.autoPinEdge(.left, to: .right, of: nameLbl, withOffset: 5.0)
        surnameLbl.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
}
