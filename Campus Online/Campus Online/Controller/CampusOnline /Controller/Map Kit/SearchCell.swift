//
//  SearchCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 10.10.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import MapKit

protocol SearchCellDelegate : class {
    func distanceFromUser(location : CLLocation) ->CLLocationDistance?
}

class SearchCell: UITableViewCell {

    weak var delegate : SearchCellDelegate?
    
    var item : MKMapItem?{
        didSet{
            configure()
        }
    }


    lazy var addLocaitonButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setBackgroundColor(color: .white, forState: .normal)

        btn.alpha = 0
        return btn
        
    }()
    
    let locationImage : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = #imageLiteral(resourceName: "location-orange").withRenderingMode(.alwaysOriginal)
        return img
    }()
    let locationTitle : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 15)
        lbl.textColor = .black

        return lbl
    }()
    let locationDistance : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray

        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(locationImage)
        locationImage.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)
        locationImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let stack  = UIStackView(arrangedSubviews: [locationTitle,locationDistance])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.anchor(top: nil, left: locationImage.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(addLocaitonButton)
        addLocaitonButton.anchor(top: nil, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 12, width: 35, heigth: 35)
        addLocaitonButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addLocaitonButton.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //MARK: -selector
    @objc func addLocation(){
            print("locaiton added")
    }
    
    //MARK: -functions
    
    func animateButtonIn(){
        addLocaitonButton.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.addLocaitonButton.alpha = 1
            self.addLocaitonButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { (_) in
            self.addLocaitonButton.transform = .identity
        }

    }
    
   func configure(){
    locationTitle.text = item?.name
    let distanceFormatter = MKDistanceFormatter()
    distanceFormatter.unitStyle = .abbreviated
    guard let mapItemLocation = item?.placemark.location else { return }
    guard let distanceFromUser = delegate?.distanceFromUser(location: mapItemLocation) else { return }
    let distance = distanceFormatter.string(for: distanceFromUser)
    locationDistance.text = distance
   }

}
