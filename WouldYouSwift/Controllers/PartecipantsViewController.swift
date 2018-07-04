//
//  DetailsVC.swift
//  wouldyou
//
//  Created by Lucia Maj on 28/03/18.
//  Copyright © 2018 luciamaj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import SwiftyPlistManager
import SDWebImage

class PartecipantsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var number : String?
    
    var json = JSON()
    
    var count = 0
    
    var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        getPartecipants()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        getPartecipants()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = PartecipantCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        print(json[indexPath.row]["user"]["name"].stringValue)
        cell.nameLbl.text = json[indexPath.row]["user"]["name"].stringValue
        cell.surnameLbl.text = json[indexPath.row]["user"]["second_name"].stringValue
        let userImgUrl = json[indexPath.row]["user"]["imageUrl"].stringValue
        
        cell.profileImgView.sd_setImage(with: URL(string: userImgUrl), placeholderImage: UIImage(named: "user-placeholder"))
        return cell
    }
    
    func getPartecipants() {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "partecipations/" + self.number!, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                self.json = JSON(response.result.value!)
                print(self.json)
                self.tableView.reloadData()
            case .failure(let error):
                let data = JSON(response.result.value ?? "There was an error")
                /*let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        }
    }
}
