//
//  FavouriteTableViewController.swift
//  CryptoCoin
//
//  Created by admin on 05.02.2018.
//  Copyright © 2018 skovcustom. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import ViewAnimator

class FavouriteTableViewController: UITableViewController, UISearchBarDelegate {
    
    private let animations = [AnimationType.from(direction: .bottom, offset: 60.0)]
    var crypts: [Crypt] = []
//    var favCrypts: [Crypt] = []
    var favouriteCrypts: [Crypt] {
        return self.crypts.filter({ UserDefaults.standard.bool(forKey: $0.id) })
    }
    
    var images = ["defaultImage", "downArrow", "upArrow"]
    var favRefreshControl = UIRefreshControl()
    var favFilteredCrypts = [Crypt]()
    var testFav = [Crypt]()
    
   var idFav = ["bitcoin", "ethereum"]
    
    
    @IBOutlet var favouriteTableView: UITableView! {
        didSet {
            favouriteTableView.delegate = self
            favouriteTableView.dataSource = self
        }
    }

    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        self.refreshData()
//        self.favRefreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        self.favRefreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableView.refreshControl = self.favRefreshControl
        self.favRefreshControl.layer.zPosition = -1
        var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "customCell")
        
        favSearchController.searchResultsUpdater = self as UISearchResultsUpdating
        favSearchController.obscuresBackgroundDuringPresentation = false
        favSearchController.searchBar.placeholder = "Search Coin"
        navigationItem.searchController = favSearchController
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.2
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    // refreshData
    
    @objc func refreshData() {
        
        self.loadData {
            self.tableView.reloadData()
//            self.tableView.animateViews(animations: self.animations)
        }
        self.refreshControl?.endRefreshing()
    }
    
    
    
    
    // MARK: - UITableViewDataSource
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return favFilteredCrypts.count
        }
//        return self.favCrypts.count
        return self.favouriteCrypts.count
//        return self.testFav.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        let crypt: Crypt
        if isFiltering {
            crypt = favFilteredCrypts[indexPath.row]
        }
        else {
            crypt = self.favouriteCrypts[indexPath.row]
//            crypt = self.favCrypts[indexPath.row]
//            crypt = self.testFav[indexPath.row]

        }
        cell.configure(withModel: crypt)
        
        
        // actions when refreshControl.isRefreshing
        
//        if favRefreshControl.isRefreshing {
//            cell.changeLabel.layer.borderWidth = 1
//            let marginSpace = CGFloat(integerLiteral: 3)
//            let insets = UIEdgeInsets(top: marginSpace, left: marginSpace, bottom: marginSpace, right: marginSpace)
//            cell.changeLabel.layoutMargins = insets
//            
//            let when = DispatchTime.now() + 1.5 // change  to desired number of seconds
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                cell.changeLabel.layer.borderWidth = 0
//            }
//        }
        
        var changes = crypt.percent_change_24h
        print(changes, "test")
        var changesInt = Float(changes)
        print(changesInt, "floatChange")
        
        func forin() {
//            for i in 0...favCrypts.count {
//                for n in 0...idFav.count {
//                    if favFilteredCrypts[i].id != idFav[n] {
//
//                    }
//                }
//            }
        }
        
        // actions when  < 0 changesInt >0
        
        if changesInt! > 0.00 {
            cell.arrowImage.image = UIImage(named: "upArrow")
            cell.changeLabel.textColor = UIColor(displayP3Red: 82.0/255.0, green: 146.0/255.0, blue: 96.0/255.0, alpha: 1)
        }
        else {
            cell.arrowImage.image = UIImage(named: "downArrow")
            cell.changeLabel.textColor = .red
        }
        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        favSearchController.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        favSearchController.searchBar.endEditing(true)
    }
    
    
    // MARK: - LoadData
    
    func loadData(completion: @escaping(() -> Void)) {

        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/", method: .get).responseData { (response) in

            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let crypts = try decoder.decode([Crypt].self, from: data)
                print(crypts)
                self.crypts = crypts
//                self.favCrypts = crypts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion()
                }
            } catch {
            }
        }
    }
    
    // MARK: - UITableViewDelegate
//    var idFav = ["bitcoin", "ethereum"]
//    func testFavor(_ idFav: String) {
//        testFav = favCrypts.filter({ (crypt: Crypt) -> Bool in
//            return crypt.name.lowercased().contains(idFav)})
//        tableView.reloadData()
//    }
    
 

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let crypt = self.crypts[indexPath.row]
        let crypt: Crypt
        if isFiltering {
            crypt = favFilteredCrypts[indexPath.row]
            //            searchController.searchBar.endEditing(true)
        }
        else {
            crypt = self.favouriteCrypts[indexPath.row]
//            crypt = self.testFav[indexPath.row]
        }
        self.performSegue(withIdentifier: "toSingleCoinTVC", sender: crypt)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SingleCoinTableViewController = segue.destination as? SingleCoinTableViewController, let crypt = sender as? Crypt {
            SingleCoinTableViewController.coinTitleName = crypt.name
            SingleCoinTableViewController.idSingleCoin = crypt.id
            SingleCoinTableViewController.title = crypt.name
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return favSearchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
//        favFilteredCrypts = favCrypts.filter({ (crypt: Crypt) -> Bool in
//            return crypt.name.lowercased().contains(searchText.lowercased())
//        })
        tableView.reloadData()
    }
    
//    func isFiltering() -> Bool {
//        return favSearchController.isActive && !searchBarIsEmpty()
//    }
    
    var isFiltering: Bool {
        return favSearchController.isActive && !searchBarIsEmpty()
    }
    
}

// MARK: - UISearchController

let favSearchController = UISearchController(searchResultsController: nil)
extension FavouriteTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController : UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
