//
//  GoogleAdBannerView.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 17.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//
import GoogleMobileAds
import UIKit
import Foundation
class GoogleAdBannerView: GADUnifiedNativeAdView {
    
   
    
    let logoView : UIImageView = {
       let img = UIImageView()
        return img
    }()
    let headLineLbl : UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.fontBold, size: 13)
        lbl.textColor = .black
        return lbl
    }()
    let advertiserLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .darkGray
         return lbl
    }()
    let starsView : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    let bodyLbl : UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = UIFont(name: Utilities.font, size: 12)
        lbl.textColor = .black
         return lbl
    }()
    let mediaImage : GADMediaView = {
       let img = GADMediaView()
        return img
    }()
    let img : UIImage = {
       let img = UIImage()
        return img
    }()
    
    let priceLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 16)
        lbl.textAlignment = .center
         return lbl
    }()
    let storeLbl : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 16)
        lbl.textAlignment = .center
         return lbl
    }()
    let installBtn : UIButton = {
       let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 16)
        btn.setBackgroundColor(color: .mainColor(), forState: .normal)
        return btn
        
    }()
    


        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)!
            setupViews()
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            backgroundColor = .red
        }

        func setupViews() {

            iconView = logoView
            headlineView = headLineLbl
            advertiserView = advertiserLbl
            starRatingView = starsView
            mediaView = mediaImage
            priceView = priceLbl
            storeView = storeLbl
            callToActionView = installBtn
            bodyView = bodyLbl
            addSubview(logoView)
            logoView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 45, heigth: 45)
            
            
            addSubview(headLineLbl)
            headLineLbl.anchor(top: logoView.topAnchor, left: logoView.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 15)
            
            addSubview(advertiserLbl)
            advertiserLbl.anchor(top: headLineLbl.bottomAnchor, left: logoView.rightAnchor, bottom: nil, rigth: nil, marginTop: 9, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 14)
            
            
            addSubview(starsView)
            starsView.anchor(top: nil, left: advertiserLbl.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 4, marginBottom: 0, marginRigth: 0, width: 75, heigth: 30)
            starsView.centerYAnchor.constraint(equalTo: advertiserLbl.centerYAnchor).isActive = true
            addSubview(bodyLbl)
            bodyLbl.anchor(top: logoView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 8, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 50)
            
            addSubview(mediaImage)
            mediaImage.anchor(top: bodyLbl.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 4, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 250)
            
            let stack = UIStackView(arrangedSubviews: [priceLbl,storeLbl,installBtn])
            stack.alignment = .center
            stack.distribution = .fillEqually
            stack.axis = .horizontal
            stack.spacing = 2
            
            addSubview(stack)
            stack.anchor(top: mediaImage.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 0, marginLeft: 5, marginBottom: 0, marginRigth: 5, width: 0, heigth: 40)
//            addSubview(storeLbl)
//            storeLbl.anchor(top: mediaImage.bottomAnchor, left: nil, bottom: nil, rigth: installBtn.leftAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 75, heigth: 30)
//            addSubview(priceLbl)
//            priceLbl.anchor(top: mediaImage.bottomAnchor, left: nil, bottom: nil, rigth: storeLbl.leftAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 75, heigth: 30)
        }

}
