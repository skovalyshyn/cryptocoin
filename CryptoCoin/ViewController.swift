//
//  ViewController.swift
//  CryptoCoin
//
//  Created by admin on 10.01.2018.
//  Copyright © 2018 skovcustom. All rights reserved.
//

import UIKit
import Alamofire

class Crypt: Codable {
    var id: String
    var name: String
    var price_usd: String
    var symbol: String
    var percent_change_24h: String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var crypts: [Crypt] = []
    var images = ["defaultImage", "downArrow", "upArrow"]
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.loadData()
    }

    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.crypts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        let crypt = self.crypts[indexPath.row]
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.fullNameLabel.text = crypt.name
        cell.priceLabel.text = crypt.price_usd + "$"
        cell.changeLabel.text = crypt.percent_change_24h + "%"
        cell.smallNameLabel.text = crypt.symbol
        cell.coinImage.image = UIImage(named: images[0])
        cell.coinImage.layer.cornerRadius = cell.coinImage.frame.height / 2
        

//        var changes: Int = Int(crypt.percent_change_24h)!
//        if changes < 0 {
//            cell.arrowImage.image = UIImage(named: images[1])
//            cell.changeLabel.textColor = .red
//        }
//        else {
//            cell.arrowImage.image = UIImage(named: images[2])
//            cell.changeLabel.textColor = .green
//        }
        
        
        return cell
    }

    
    // MARK: - LoadData
    
    func loadData() {
        
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/", method: .get).responseData { (response) in

            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let crypts = try decoder.decode([Crypt].self, from: data)
                self.crypts = crypts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                
            }
        }
    }
}

