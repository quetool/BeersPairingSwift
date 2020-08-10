//
//  ViewController.swift
//  Beer Test
//
//  Created by Alfredo Rinaudo on 09/03/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    var allBeers: [Beer] = [Beer]()
    var suggestions: [String] = [String]()
    var suggestionsAux: [String] = [String]()
    var strongFirst: Bool = false
    var currentPage: Int = 1 // for pagination
    var perPage: Int = 20
    var searchTerm: String = ""
    var currentWindowSize: CGSize = CGSize.zero
    
    private var reachability: NetworkReachabilityManager!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var beerTable: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var randomBeerView: UIView!
    @IBOutlet weak var suggestionsVIew: UIView!
    @IBOutlet weak var suggestionsTableView: UITableView!
    
    @IBOutlet weak var topSearchViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingSearchBarConstraint: NSLayoutConstraint!
    
    final var apiClient = ApiClient()
    final var userDefaultsManger = UserDefaultsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentWindowSize = self.view.frame.size
        
        // REACHABILITY DE ALAMOFIRE
        self.reachability = NetworkReachabilityManager.init(host: "google.com")
        self.reachability.startListening()
        self.reachability.listener = { status in
            print("Reachability Status Changed: \(status)")
            if (!self.reachability.isReachable) {
                self.showErrorAlertWithMessage(message: "You are not connected to the internet")
            } else {
                // RETOMO LA REQUEST PREVIAMENTE GUARDADA
                let lastRequest = self.userDefaultsManger.getLastRequest()
                if !lastRequest.isEmpty {
                    self.apiClient.retryRequestAfterFail(request: lastRequest) { (response) in
                        self.apiClient.responseHandler(response: response) { (beers, error) in
                            if (error != nil) {
                                self.showLoader(show: false)
                                self.showErrorAlertWithMessage(message: error?.localizedCapitalized ?? "An error occurred!")
                                return
                            }
                            if let beers = beers {
                                self.allBeers = beers
                            }
                            self.beerTable.reloadData()
                            self.sortBeers()
                            self.enableSortButton(!self.allBeers.isEmpty)
                            self.showLoader(show: false)
                            self.userDefaultsManger.removeLastRequest()
                        }
                    }
                }
            }
        }
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        self.mainScrollView.delegate = self
        
        self.sortButton.setImage(UIImage(systemName: "arrowtriangle.up"), for: .normal)
        self.enableSortButton(false)
        self.leadingSearchBarConstraint.constant = self.currentWindowSize.width - 8.0
        
        self.beerTable.contentInset = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.beerTable.tableFooterView = UIView()
        self.suggestionsTableView.tableFooterView = UIView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarCancelButtonClicked))
        tapGesture.cancelsTouchesInView = false
        self.suggestionsVIew.addGestureRecognizer(tapGesture)
        
        self.setSuggestionsList()
        self.requestRandomBeer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.currentWindowSize = size
        if UIDevice.current.orientation.isLandscape { // TODO horrible parche temporal
            self.segmented.isHidden = true
            self.segmented.selectedSegmentIndex = 0
            self.onSegmentedControlChanges(self.segmented)
        } else {
            self.segmented.isHidden = false
        }
        self.leadingSearchBarConstraint.constant = self.currentWindowSize.width - 8.0
    }
    
    // MARK: data requests to API
    func requestRandomBeer() {
        self.randomBeerView.isHidden = true
        
        self.showLoader()
        self.apiClient.getMeRandomBeer { (response) in
            self.apiClient.responseHandler(response: response) { (beers, error) in
                if (error != nil) {
                    self.showLoader(show: false)
                    self.showErrorAlertWithMessage(message: error?.localizedCapitalized ?? "An error occurred!")
                    return
                }
                if let random = beers?.first {
                    self.randomBeerView.isHidden = false
                    self.showLoader(show: false)
                    
                    if let randomImageView = (self.randomBeerView.subviews.first { (subview) -> Bool in
                        return subview.accessibilityIdentifier == "randomImage"
                    }) {
                        (randomImageView as! UIImageView).kf.setImage(with: URL.init(string: random.image_url ?? ""), placeholder: UIImage(named: "placeholder"), options: [], progressBlock: nil) { (result) in
                        }
                    }
                    if let randomNameLabel = (self.randomBeerView.subviews.first { (subview) -> Bool in
                        return subview.accessibilityIdentifier == "randomName"
                    }) {
                        (randomNameLabel as! UILabel).text = random.name ?? ""
                    }
                    
                    if let randomDescriptionLabel = (self.randomBeerView.subviews.first { (subview) -> Bool in
                        return subview.accessibilityIdentifier == "randomDescription"
                    }) {
                        (randomDescriptionLabel as! UILabel).text = random.description ?? ""
                    }
                    
                    if let randomTagsLabel = (self.randomBeerView.subviews.first { (subview) -> Bool in
                        return subview.accessibilityIdentifier == "randomTags"
                    }) {
                        (randomTagsLabel as! UILabel).text = random.tagline ?? ""
                    }
                    
                    if let abvSubView = (self.randomBeerView.subviews.first { (subview) -> Bool in
                        return subview.accessibilityIdentifier == "randomAbvView"
                    }) {
                        abvSubView.layer.cornerRadius = 10.0
                        abvSubView.clipsToBounds = true
                        let labelView = abvSubView.subviews.first { (view) -> Bool in
                            return view.accessibilityIdentifier == "randomAbv"
                        }
                        if let abv = random.abv {
                            (labelView as! UILabel).text = String(format: "%.1f", abv) + "%"
                        }
                    }
                }
            }
        }
    }
    
    func requestBeersByFood(food: String = "") {
        if food == "" {
            return
        }
        self.searchTerm = food
        self.userDefaultsManger.saveSearch(searchText: food)
        self.setSuggestionsList()
        self.showLoader()
        self.apiClient.getAllBeers(byFood: food, fromPage: self.currentPage, perPage: self.perPage) { (response) in
            self.apiClient.responseHandler(response: response) { (beers, error) in
                if (error != nil) {
                    self.showLoader(show: false)
                    self.showErrorAlertWithMessage(message: error?.localizedCapitalized ?? "An error occurred!")
                    return
                }
                if let beers = beers {
                    self.allBeers = beers
                }
                self.beerTable.reloadData()
                self.sortBeers()
                self.enableSortButton(!self.allBeers.isEmpty)
                self.showLoader(show: false)
                self.userDefaultsManger.removeLastRequest()
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func newRandomBeer(_ sender: Any) {
        self.requestRandomBeer()
    }
    
    @IBAction func onSegmentedControlChanges(_ sender: UISegmentedControl) {
        let x = CGFloat(sender.selectedSegmentIndex) * (self.currentWindowSize.width - 16.0)
        self.mainScrollView.setContentOffset(CGPoint(x: x, y :0), animated: true)
    }
    
    @IBAction func sortByStrong(_ sender: UIButton) {
        self.strongFirst = !self.strongFirst
        self.sortButton.setImage(self.strongFirst ? UIImage(systemName: "arrowtriangle.down") : UIImage(systemName: "arrowtriangle.up"), for: .normal)
        self.sortBeers()
    }
    
    // MARK: UITableView delegates
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.beerTable {
            return ""
        }
        return " Previous search"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.beerTable {
            return self.allBeers.count
        }
        return self.suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.beerTable {
            let cell: BeerTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "BeerCell", for: indexPath) as? BeerTableViewCell
            
            cell?.beerImage.kf.setImage(with: URL(string: self.allBeers[indexPath.row].image_url ?? ""), placeholder: UIImage(named: "placeholder"), options: [], progressBlock: nil) { (result) in
            }
            
            if let abv = self.allBeers[indexPath.row].abv {
                cell?.abv.text = String(format: "%.1f", abv) + "%"
            }
            
            if let name: String = self.allBeers[indexPath.row].name {
                cell?.name.text = name
            }
            
            if let desc: String = self.allBeers[indexPath.row].description {
                cell?.desc.text = desc
            }
            
            if let pairings: [String] = self.allBeers[indexPath.row].food_pairing {
                var matches: [String] = []
                pairings.forEach { (pair) in
                    if !self.searchTerm.isEmpty && pair.lowercased().contains(self.searchTerm.lowercased()) {
                        matches.append(pair)
                    }
                }
                cell?.pairedFood.text = !matches.isEmpty ? matches.joined(separator: "\n") : ""
            }
            
            if let tags: String = self.allBeers[indexPath.row].tagline {
                cell?.tags.text = tags
            }
            
            cell?.layoutIfNeeded()
            
            return cell!
        } else {
            let cell: SuggestionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as? SuggestionTableViewCell
            
            cell?.suggestion.text = self.suggestions[indexPath.row]
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.beerTable {
            if let beerId: Int = self.allBeers[indexPath.row].id {
                self.apiClient.getBeerDetails(beerId: beerId) { (response) in
                    self.apiClient.responseHandler(response: response) { (beers, error) in
                        if (error != nil) {
                            print(error?.localizedCapitalized ?? "Error")
                            return
                        }
                        print(beers?.first?.toJSONString() ?? "No beer details")
                    }
                }
            }
        } else {
            print(self.suggestions[indexPath.row])
            self.searchBar.text = self.suggestions[indexPath.row]
            self.searchBarSearchButtonClicked(self.searchBar)
        }
    }
    
    // MARK: UIScrollView delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.mainScrollView {
            self.leadingSearchBarConstraint.constant = (self.currentWindowSize.width - 8.0) - scrollView.contentOffset.x
            print(self.leadingSearchBarConstraint.constant)
        }
    }
    
    // MARK: UISearchBar delegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.showSuggestionView(hide: (self.suggestionsAux.count == 0))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.requestBeersByFood(food: searchBar.text ?? "")
        self.showSuggestionView(hide: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.allBeers.isEmpty {
            self.searchBar.text = ""
        }
        self.view.endEditing(true)
        self.showSuggestionView(hide: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.setSuggestionsList()
            return
        }
        self.suggestions = self.suggestionsAux.filter { (suggestion) -> Bool in
            return suggestion.lowercased().contains(searchText.lowercased())
        }
        self.suggestionsTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
    }
    
    // MARK: helper functions
    
    func sortBeers() {
        self.allBeers.sort { (beerA, beerB) -> Bool in
            if (self.strongFirst) {
                return (beerA.abv ?? 0.0) > (beerB.abv ?? 0.0)
            } else {
                return (beerA.abv ?? 0.0) < (beerB.abv ?? 0.0)
            }
        }
        self.beerTable.reloadData()
    }
    
    func showLoader(show: Bool = true) {
        if show {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.startAnimating()
            indicator.color = .black
            indicator.center = self.view.center
            self.view.addSubview(indicator)
        } else {
            (self.view.subviews.first { (subview) -> Bool in
                return (subview is UIActivityIndicatorView)
            })?.removeFromSuperview()
        }
    }
    
    func showSuggestionView(hide: Bool) {
        self.suggestions = self.suggestionsAux.filter { (suggestion) -> Bool in
            if !self.allBeers.isEmpty && !searchBar.text!.isEmpty {
                return suggestion.lowercased().contains(searchBar.text!.lowercased())
            }
            return true
        }
        self.suggestionsTableView.reloadData()
        
        if !hide {
            self.suggestionsVIew.isHidden = hide
        }
        self.suggestionsVIew.layer.opacity = !hide ? 0.0 : 1.0
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        self.suggestionsVIew.layer.opacity = hide ? 0.0 : 1.0
                        self.view.layoutIfNeeded()
        }, completion: { (completed) -> Void in
            if hide {
                self.suggestionsVIew.isHidden = hide
            }
        })
    }
    
    func enableSortButton(_ enable: Bool) {
        self.sortButton.setImage(self.strongFirst ? UIImage(systemName: "arrowtriangle.down") : UIImage(systemName: "arrowtriangle.up"), for: .normal)
        self.sortButton.isEnabled = enable
        self.sortButton.tintColor = enable ? .systemBlue : .gray
        self.sortButton.setTitleColor( enable ? .systemBlue : .gray, for: .normal)
    }
    
    func setSuggestionsList() {
        self.suggestions = self.userDefaultsManger.getPreviousSearchs()
        self.suggestionsAux = self.suggestions
        self.suggestionsTableView.reloadData()
    }
    
    func showErrorAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

