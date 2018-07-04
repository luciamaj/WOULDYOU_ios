//
//  FourthViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 30/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout
import SwiftyUserDefaults
import SwiftyJSON
import Alamofire
import SDWebImage
import DZNEmptyDataSet
import SwiftyPlistManager

class ProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var collectionView: UICollectionView!
    
    var categoryColors : [UIColor] = [UIColor.flatRed, UIColor.flatGreen, UIColor.flatPurple, UIColor.flatSkyBlue]
    
    var arrRes = [[String:Any?]]()
    
    var json : JSON?
    
    let screenSize = UIScreen.main.bounds
    
    let cellIdentifier = "ImageCell"
    
    override func viewWillAppear(_ animated: Bool) {
        getMyEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyEvents()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        
        layout.sectionInset = UIEdgeInsets(top: 100, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.screenSize.width, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
                
        let logOutBtn = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickButton(sender:)))
        
        self.navigationItem.setRightBarButtonItems([logOutBtn], animated: true)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Welcome"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "The world is waiting for you! Partecipate to an event!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: view.bounds.width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        
        var dict = arrRes[indexPath.row]
        cell.nameLabel.text = dict["name"] as? String
        cell.nameLabel.text = cell.nameLabel.text?.uppercased()
        cell.descriptionLabel.text = dict["description"] as? String
        let date = dict["time_start_event"] as? String
        cell.timeLabel.text = UTCToLocal(date: date!)

        cell.colorView.backgroundColor = categoryColors[(dict["category_id"] as? Int)! - 1]
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        cell.alpha = 0.7;
        cell.contentView.alpha = 0.7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: (screenSize.width - 15), height: (width - 15)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 130, right: 5)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected row", indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ProfileReusable
            header.setNeedsLayout()
            getMyData {
                header.nameLabel.text = self.json!["name"].stringValue + " " + self.json!["second_name"].stringValue
                header.descriptionLabel.text = self.json!["description"].stringValue
                header.genderLabel.text = self.json!["gender"].stringValue
                header.ageLabel.text = "\(self.calcAge(birthday: self.json!["birthday"].stringValue))" +  " "
                header.profileImg.sd_setImage(with: URL(string: self.json!["imageUrl"].stringValue), placeholderImage: UIImage(named: "user-placeholder"))
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func getMyEvents() {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" +  "user-events-inactive", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let swiftyJsonVar = JSON(response.result.value!)
                if let resData = swiftyJsonVar.arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                    print(self.arrRes)    
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    func getMyData(completion: @escaping () -> Void) {
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "user/", method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                self.json = JSON(response.result.value!)
                self.collectionView.reloadData()
                completion()
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    func calcAge(birthday:String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        let age = calcAge.year
        return age!
    }
    
    @objc func clickButton(sender: UIBarButtonItem){
        Defaults.removeAll()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController =  storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginViewController, animated:true, completion:nil)
    }
}
