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
         return lbl
    }()
    let storeLbl : UILabel = {
        let lbl = UILabel()
         return lbl
    }()
    let installBtn : UIButton = {
       let btn = UIButton()
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
            
            let stackView = UIStackView(arrangedSubviews: [advertiserLbl,starsView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            
            
            let stackHeadLine = UIStackView(arrangedSubviews: [headLineLbl,stackView])
            stackHeadLine.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .leading
            
            addSubview(stackHeadLine)
            stackHeadLine.anchor(top: nil, left: logoView.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 0, heigth: 45)
            stackHeadLine.centerYAnchor.constraint(equalTo: logoView.centerYAnchor ).isActive = true
            
            addSubview(bodyLbl)
            bodyLbl.anchor(top: logoView.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 8, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 50)
            
            addSubview(mediaImage)
            mediaImage.anchor(top: bodyLbl.bottomAnchor, left: leftAnchor, bottom: nil, rigth: rightAnchor, marginTop: 12, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 250)
            
            addSubview(installBtn)
            installBtn.anchor(top: mediaImage.bottomAnchor, left: nil, bottom: nil, rigth: rightAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 100, heigth: 40)
            addSubview(storeLbl)
            storeLbl.anchor(top: mediaImage.bottomAnchor, left: nil, bottom: nil, rigth: installBtn.leftAnchor, marginTop: 10, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 100, heigth: 40)
            
//            let stackStore = UIStackView(arrangedSubviews: [priceLbl,storeLbl,installBtn])
//            stackStore.axis = .horizontal
//            stackStore.distribution = .fillEqually
//            addSubview(stackStore)
//            stackStore
            
            
        }

}
