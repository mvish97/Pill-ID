//
//  MoreInfoVC.swift
//  Pill ID
//
//  Created by Vishnu on 11/9/17.
//  Copyright © 2017 MedAppJam. All rights reserved.
//

import Foundation
import UIKit

class MoreInfoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pillNameLabel: UILabel!
    
    var moreInfoArray: [MoreInfoModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        populateArray()
        
        pillNameLabel.text = "Benedryl"
        
    }
    
    func populateArray() {
        moreInfoArray = [
            MoreInfoModel(heading: "Treats the following illnesses", body: "Allergies, runny nose, sneezing, itchy eyes, and itching in the nose or throat"),
            MoreInfoModel(heading: "Side Effects", body: "Drowsiness, dry mouth, dizziness, nausea, headache, and loss of appetite."),
            MoreInfoModel(heading: "Purchase at", body: "Walgreens, Walmart, Albertsons or this link")
        ]
    }
}

extension MoreInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "moreInfo", for: indexPath) as? MoreInfoCell {
            cell.updateUI(info: moreInfoArray[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


class MoreInfoCell: UITableViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    func updateUI(info: MoreInfoModel) {
        headingLabel.text = info.heading
        bodyLabel.text = info.body
    }
    
}

class MoreInfoModel {
    
    private var _heading: String!
    private var _body: String!
    
    init(heading: String, body: String) {
        _heading = heading
        _body = body
    }
    
    var heading: String {
        if _heading == nil {
            _heading = ""
        }
        return _heading
    }
    
    var body: String {
        if _body == nil {
            _body = ""
        }
        return _body
    }
}
