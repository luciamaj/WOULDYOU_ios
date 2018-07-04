//
//  FourthViewController.swift
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
import KeyboardAdjuster
import SDWebImage
import SwiftyPlistManager

class ConversationViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, KeyboardAdjuster, UITextFieldDelegate {
    
    var keyboardAdjustmentHelper = KeyboardAdjustmentHelper()

    var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    let cellIdentifier = "ImageCell"
    let screenSize = UIScreen.main.bounds
    
    var chatTimer = Timer()
    
    @objc func runTimedCode() {
        getData()
    }
    
    var json = JSON()
    
    var imgUrl = ""
    
    var number : String!
    
    let messageTxt : UITextField = {
        let msg = UITextField(frame: CGRect.zero)
        msg.placeholder = "Insert your message"
        msg.borderStyle = UITextBorderStyle.roundedRect
        msg.autoSetDimension(.width, toSize: 300.0)
        msg.autoSetDimension(.height, toSize: 50.0)
        return msg
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        self.hideKeyboardWhenTappedAround()
        
        self.title = "Chat"
        super.viewDidLoad()
        
        chatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        self.messageTxt.returnKeyType = .send
        self.messageTxt.enablesReturnKeyAutomatically = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenSize.width, height: 200)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        self.messageTxt.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        view.addSubview(messageTxt)
        
        messageTxt.autoPinEdge(toSuperviewEdge: .bottom)
        messageTxt.autoPinEdge(toSuperviewEdge: .left)
        messageTxt.autoPinEdge(toSuperviewEdge: .right)
        
        keyboardAdjustmentHelper.constraint = view.bottomAnchor.constraint(equalTo: messageTxt.bottomAnchor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.chatTimer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activateKeyboardAdjuster()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deactivateKeyboardAdjuster()
    }
    
    @objc private func refreshData(_ sender: Any) {
        getData()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "There are no message yet"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Send a message and start the conversation!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return json.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        var dict = json[indexPath.row]
        cell.contentLabel.text = dict["text"].stringValue
        
        let messageText = dict["text"].stringValue

        cell.sentLabel.text = dict["created_at"].stringValue
        
        let userUnwrap = dict["user_id"].stringValue
        
        let userImgUrl = dict["user"]["imageUrl"].stringValue
        
        
        cell.profileImgView.sd_setImage(with: URL(string: userImgUrl), placeholderImage: UIImage(named: "user-placeholder"))
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.systemFont(ofSize: 18)], context: nil)
        
        print(Defaults[.id])
        print(userUnwrap)
        
        if (userUnwrap != (Defaults[.id])) {
            cell.contentLabel.frame = CGRect(x: 12 + 40, y: 6, width: estimatedFrame.width + 18, height: estimatedFrame.height + 20)
            
            cell.textBubbleView.frame = CGRect(x: 40, y: -4, width: estimatedFrame.width + 32, height: estimatedFrame.height + 20)
            
            cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            cell.contentLabel.textColor = .black
            print(cell.profileImgView.isHidden)
            cell.profileImgView.isHidden = false
            
        } else {
            
            cell.contentLabel.frame = CGRect(x: view.frame.width - estimatedFrame.width - 24, y: 6, width: estimatedFrame.width + 18, height: estimatedFrame.height + 20)
            
            cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 40, y: -4, width: estimatedFrame.width + 32, height: estimatedFrame.height + 20)
            
            cell.profileImgView.isHidden = true
            print(cell.profileImgView.isHidden)

            cell.textBubbleView.backgroundColor = .orange
            cell.contentLabel.textColor = .white
        }
        cell.contentLabel.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var dict = json[indexPath.row]
        let messageText = dict["text"].stringValue
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.systemFont(ofSize: 18)], context: nil)
        
        return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 180, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessage()
        return true
    }
    
    func sendMessage() {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        let parameters : Parameters = [
            "text" : self.messageTxt.text!
        ]
        
       guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "message/" + "\(self.number!)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let swiftyJsonVar = JSON(response.result.value as Any)
            print(swiftyJsonVar)
        }
        getData()
        self.collectionView.reloadData()
        self.messageTxt.text = ""
    }
    
    func getData() {
        
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Defaults[.token])"
        ]
        
        guard let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: "localUrl", fromPlistWithName: "Data") else { return }
        
        Alamofire.request("\(fetchedValue)" + "messages/" + number, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                self.json = JSON(response.result.value!)
                self.collectionView.reloadData()
            case .failure(let error):
                /*let data = JSON(response.result.value ?? "There was an error")
                let alert = UIAlertController(title: "Error", message: data["message"].stringValue, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))*/
                print(error)
                //self.present(alert, animated: true)
            }
        self.refreshControl.endRefreshing()
        }
    }
}
