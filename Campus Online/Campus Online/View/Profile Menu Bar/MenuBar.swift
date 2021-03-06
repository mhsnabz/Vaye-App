//
//  MenuBar.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 27.11.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

struct MenuFilter {
    var model : ProfileModel!
    var options : ProfileFilterVM!
    
}


class MenuBar : UIView , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UICollectionViewDelegate {
    
    var barLeftAnchor: NSLayoutConstraint?{
        didSet {
            guard let constant = barLeftAnchor?.constant else { return }
            scrollMenuItem( point: constant)
        }
    }
    var options : ProfileFilterVM?{
        didSet{
            collectionView.reloadData()
        }
    }
    var menuFilter : MenuFilter?{
        didSet{
            guard let model = menuFilter?.model else { return }
            guard let option = menuFilter?.options else { return }
            let index = IndexPath(item: 0, section: 0)

            collectionView.selectItem(at: index, animated: false, scrollPosition: .left)
            setupHorizantalVar(size: CGFloat(option.options.count))
            collectionView.reloadData()
        }
    }
    var profileModel : ProfileModel?{
        didSet{
            guard let model = profileModel else { return }
            options = ProfileFilterVM(short_school: model.shortSchool, major: model.major, userUid: model.uid, currentUser: model.currentUser)
            collectionView.reloadData()
        }
    }
    weak var filterDelagate : UserProfileMenuBarDelegate?
    //MARK:-properites
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    lazy var horizantalBarView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
  
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: "id")

       
        
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func getShortMajor(major : String) ->String {
        var shortName  : String = ""
        let bolumName = major.components(separatedBy: " ")
        for item in bolumName {
            shortName += item[0].string
        }
        return shortName
    }
    func setupHorizantalVar(size : CGFloat){
        print("DEBUG :: size \(size)")
        
        horizantalBarView.backgroundColor = .black
        horizantalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizantalBarView)
        barLeftAnchor =  horizantalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        barLeftAnchor?.isActive = true
        horizantalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizantalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 / size).isActive = true
        horizantalBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = menuFilter?.options.options.count  else {
            return 4
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ProfileFilterCell
        
        if let filter = menuFilter {
            if  filter.options?.options[indexPath.row].description == ProfileFilterOptions.major(()).description {
                cell.option = getShortMajor(major: filter.model.major.description)
            }else if filter.options?.options[indexPath.row].description == ProfileFilterOptions.shortSchool(()).description{
                cell.option = filter.model.shortSchool.description
            }else if  filter.options?.options[indexPath.row].description == ProfileFilterOptions.vayeApp(()).description{
                cell.option = "vaye.app"
            }else if  filter.options?.options[indexPath.row].description == ProfileFilterOptions.fav(()).description{
                cell.option = "Favoriler"
            }
        }
        
       
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count =  menuFilter?.options?.options.count ?? 1
        return CGSize(width: Int(frame.width) / count, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let count = menuFilter?.options?.options.count else { return }
//        let cell = collectionView.cellForItem(at: indexPath) as! ProfileFilterCell
//        cell.underLine.removeFromSuperview()
//        cell.addSubview(cell.underLine)
//        cell.underLine.frame = CGRect(x: 0, y: 0, width: Int(frame.width) / count, height: 1)
     
        let x = indexPath.item  * Int(frame.width) / count
        barLeftAnchor?.constant = CGFloat(x)
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)

        guard let constant = barLeftAnchor?.constant else { return }
        scrollMenuItem( point: constant)
        filterDelagate?.didSelectOptions(option: (menuFilter?.options?.options[indexPath.row])!)
      
       

    }
    func scrollMenuItem(point : CGFloat){
//        let x = CGFloat(indexPath.item ) * frame.width / 3
        barLeftAnchor?.constant = point
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
