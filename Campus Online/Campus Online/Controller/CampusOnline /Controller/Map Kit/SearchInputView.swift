//
//  SearchInputView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 10.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MapKit
protocol SearchInputViewDelagete : class {
    func animateCenterMapButton(expansionState : SearchInputView.ExpansionState ,hideButton : Bool )
    func handleSearch(with SearchText : String)
    func addPolyLine(destinationMapItem : MKMapItem)
    func selectAnnotation(selectAnnotation mapItem : MKMapItem)
}
class SearchInputView: UIView {
    //MARK: -properites
    enum ExpansionState {
        case notExpanded
        case partiallyExpanded
        case fullyExpanded
 
        
    }
     var searchBar : UISearchBar!
     var tableView : UITableView!
    var expansionState : ExpansionState!
    weak var delegate : SearchInputViewDelagete?
    weak var mapController : MapVC?
    var directionEnable : Bool = false
    var searchResult : [MKMapItem]?{
        didSet{
           tableView.reloadData()
        }
    }
    
    let indicatorView : UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        v.layer.cornerRadius = 5
        v.alpha = 0.8
        return v
    }()
    
    //MARK: -lifeCycle
    override init(frame : CGRect){
        super.init(frame: frame)
        
        configureViewComponent()
        expansionState = .notExpanded
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -function
    func configureViewComponent(){
        backgroundColor = .white
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, left: nil, bottom: nil, rigth: nil, marginTop: 8, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 40, heigth: 8)
        indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        configureSearchBar()
    }
    
    func configureSearchBar(){
        searchBar = UISearchBar()
        searchBar.placeholder = "Konum Arayın"
        searchBar.barStyle = .blackOpaque
        searchBar.delegate = self
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        addSubview(searchBar)
        searchBar.anchor(top: indicatorView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 10, marginBottom: 0, marginRigth: 10, width: 0, heigth: 50)
        configureTableView()
    }
    func configureTableView()
    {
        tableView = UITableView()
        tableView.rowHeight = 60
        tableView.register(SearchCell.self, forCellReuseIdentifier: "id")
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 10, marginLeft: 0, marginBottom: 130, marginRigth: 0, width: 0, heigth:0)
        tableView.delegate = self
        tableView.dataSource = self
        configureGestureReginozers()
        
    }
    
    func configureGestureReginozers(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        let swipedown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipedown.direction = .down
        addGestureRecognizer(swipedown)
    }
    func animationInputView(targetPostion : CGFloat  , completion : @escaping(Bool) ->Void){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.frame.origin.y = targetPostion
        } completion: { (val) in
            completion(val)
        }

    }
    
    
    func disableViewIntercation(directionIsEnabled : Bool){
        self.directionEnable = directionIsEnabled
        if directionIsEnabled{
            tableView.allowsSelection = false
            searchBar.isUserInteractionEnabled = false
        }else{
            tableView.allowsSelection = true
            searchBar.isUserInteractionEnabled = true
        }
 
    }
    
    //MARK: -selectors
    @objc func handleSwipeUp(sender : UISwipeGestureRecognizer){
        
        if directionEnable{
            return
        }
        
        if sender.direction == .up{
            
            
            if expansionState == .notExpanded{
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)

                animationInputView(targetPostion: self.frame.origin.y  - self.frame.width / 2) { (_) in
                    self.expansionState = .partiallyExpanded
                }
            }
            if expansionState == .partiallyExpanded{
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)

                animationInputView(targetPostion: self.frame.origin.y  - self.frame.width + 100) { (_) in
                    self.expansionState = .fullyExpanded
                    
                }
            }
        }else{
            if expansionState == .fullyExpanded{
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                self.searchBar.showsCancelButton = false
                self.searchBar.endEditing(true)
                animationInputView(targetPostion: self.frame.origin.y  + self.frame.width - 100) { (_) in
                    self.expansionState = .partiallyExpanded
                    
                }
            }
            if expansionState == .partiallyExpanded{
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                animationInputView(targetPostion: self.frame.origin.y  + self.frame.width / 2) { (_) in
                    self.expansionState = .notExpanded
                }
            }
        }
    }
}

extension SearchInputView : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        delegate?.handleSearch(with: searchText)
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false

        animationInputView(targetPostion: self.frame.origin.y  + self.frame.width - 100) { (_) in
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
            self.expansionState = .partiallyExpanded
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
     
        if expansionState == .notExpanded{
            self.animationInputView(targetPostion: self.frame.origin.y  - self.frame.width / 2) { (_) in
                self.expansionState = .partiallyExpanded
                self.animationInputView(targetPostion: self.frame.origin.y  - self.frame.width + 100) { (_) in
                    self.expansionState = .fullyExpanded
                    
                }
            }
        }
        if expansionState == .partiallyExpanded{
            animationInputView(targetPostion: self.frame.origin.y  - self.frame.width + 100) { (_) in
                self.expansionState = .fullyExpanded
                
            }
        }
        
        searchBar.showsCancelButton = true
        delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false

        animationInputView(targetPostion: self.frame.origin.y  + self.frame.width - 100) { (_) in
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
            self.expansionState = .partiallyExpanded
        }

    }
}
extension SearchInputView : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = searchResult?.count else { return 0}
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath) as! SearchCell
        cell.contentView.isUserInteractionEnabled = false
        if let result = searchResult {
            cell.item = result[indexPath.row]
        }
        if let controller = mapController {
            cell.delegate = controller
        }
   
        return cell
     }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard var searchResult = searchResult else{
            return
        }
        let item = searchResult[indexPath.row]
        delegate?.selectAnnotation(selectAnnotation: item)
        //FIXME: -refactor
        
        if expansionState == .fullyExpanded{
            self.searchBar.showsCancelButton = false
            self.searchBar.endEditing(true)
         
          
            animationInputView(targetPostion: self.frame.origin.y  + self.frame.width - 100) { (_) in
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
                self.expansionState = .partiallyExpanded
                
            }
        }
        
        searchResult.remove(at: indexPath.row)
        searchResult.insert(item, at: 0)
        self.searchResult = searchResult
        let index = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: index, at: .top , animated: true)

        delegate?.addPolyLine(destinationMapItem: item)

   
        
        
        
    }
    
}
