//
//  EventsViewController.swift
//  wouldyou
//
//  Created by Lucia Maj on 30/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import PureLayout
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import DZNEmptyDataSet
import JJFloatingActionButton
import ChameleonFramework
import AFDateHelper
import SwiftyPlistManager

class EventsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var categoryColors : [UIColor] = [UIColor.flatRed, UIColor.flatGreen, UIColor.flatPurple, UIColor.flatSkyBlue]

    var selectedSegmeted : Int?
    
    var collectionView: UICollectionView!
    
    var json = JSON()
    
    let refreshControl = UIRefreshControl()
    
    let screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData(url: "inactive-events")
        
        self.title = "Events"
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: 100, left: 10, bottom: 100, right: 10)
        layout.itemSize = CGSize(width: self.screenSize.width, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        let newEventButton = JJFloatingActionButton()
        self.view.addSubview(newEventButton)
        newEventButton.translatesAutoresizingMaskIntoConstraints = false
        newEventButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        newEventButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        
        newEventButton.buttonColor = .white
        newEventButton.buttonImageColor = .orange
        newEventButton.addItem(title: "Loc", image: nil) { item in
            self.performSegue(withIdentifier: "formEvent", sender: nil)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        if (selectedSegmeted == 0) {
            getData(url: "inactive-events")
        }
        else {
            getData(url: "created-events")
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Welcome"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Start exploring now!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: view.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return json.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EventCell
        var dict = json[indexPath.row]
        cell.nameLabel.text = dict["name"].stringValue
        cell.nameLabel.text = cell.nameLabel.text?.uppercased()
        cell.descriptionLabel.text = dict["description"].stringValue
        let date = dict["time_start_event"].stringValue
        cell.timeLabel.text = UTCToLocal(date: date)
        if (dict["users_events"].arrayValue.count != 0) {
            cell.partepantsLbl.text = "Partecipants: " + "\(dict["users_events"].arrayValue.count)"
        }
        else {
           cell.partepantsLbl.text = "No partecipants yet"
        }
        cell.colorView.backgroundColor = categoryColors[(dict["category_id"].intValue) - 1]
        
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        
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
        self.performSegue(withIdentifier: "detailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsVC" {
            let view = segue.destination as! SingleEventController
            
            if let itemIndex = collectionView.indexPathsForSelectedItems?.first?.item {
                let selectedItem = self.json[itemIndex]["id"].stringValue
                view.number = selectedItem
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderReusable
            header.setNeedsLayout()
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func getData(url: String) {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let swiftyJsonVar = JSON(response.result.value!)
                self.json = swiftyJsonVar
                if self.json.count > 0 {
                    self.collectionView.reloadData()
                }
                self.refreshControl.endRefreshing()
                
            case .failure(let error):
                print("url", "\(fetchedValue)" + url)
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.collectionView.reloadData()
            selectedSegmeted = 0
            getData(url: "inactive-events")
            
        case 1:
            self.collectionView.reloadData()
            selectedSegmeted = 1
            getData(url: "created-events")
            
        default:
            break
        }
    }
}
