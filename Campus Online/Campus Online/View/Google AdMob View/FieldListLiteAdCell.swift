//
//  FieldListLiteAdCell.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 17.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import GoogleMobileAds
class FieldListLiteAdCell: UICollectionViewCell,GADUnifiedNativeAdLoaderDelegate {
    
    var adLoader: GADAdLoader!
    var controller: HomeVC? {
           didSet {
               if let _ = controller {
                   fetchAds()
               }
           }
       }
    let mainView: GoogleAdBannerView = {
           let view = GoogleAdBannerView()
           view.backgroundColor = .white
           view.translatesAutoresizingMaskIntoConstraints = false
           return view
       }()
    
    lazy var refresh : UIButton = {
        let btn = UIButton()
        btn.setTitle("yenile", for: .normal)
        btn.setBackgroundColor(color: .black, forState: .normal)
        return btn
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainView)
        mainView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: frame.width  , heigth: 400)
        
    }
    
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader)
    {
        
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("Failed Ad Request: ", error)
    }
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        mainView.nativeAd = nativeAd
        nativeAd.delegate = self

        print("Ad has been received.")
        // Set the mediaContent on the GADMediaView to populate it with available
         // video/image asset.
        mainView.mediaView?.mediaContent = nativeAd.mediaContent

         // Populate the native ad view with the native ad assets.
         // The headline is guaranteed to be present in every native ad.
         (mainView.headlineView as? UILabel)?.text = nativeAd.headline

         // These assets are not guaranteed to be present. Check that they are before
         // showing or hiding them.
         (mainView.bodyView as? UILabel)?.text = nativeAd.body
        mainView.bodyView?.isHidden = nativeAd.body == nil

         (mainView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        mainView.callToActionView?.isHidden = nativeAd.callToAction == nil

         (mainView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        mainView.iconView?.isHidden = nativeAd.icon == nil

        (mainView.starsView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
        mainView.starRatingView?.isHidden = nativeAd.starRating == nil

         (mainView.storeView as? UILabel)?.text = nativeAd.store
        mainView.storeView?.isHidden = nativeAd.store == nil

         (mainView.priceView as? UILabel)?.text = nativeAd.price
        mainView.priceView?.isHidden = nativeAd.price == nil

         (mainView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        mainView.advertiserView?.isHidden = nativeAd.advertiser == nil

         // In order for the SDK to process touch events properly, user interaction
         // should be disabled.
        mainView.callToActionView?.isUserInteractionEnabled = false

         // Associate the native ad view with the native ad object. This is
         // required to make the ad clickable.
         // Note: this should always be done after populating the ad views.
        mainView.nativeAd = nativeAd
    }
    private func fetchAds() {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
           multipleAdsOptions.numberOfAds = 5
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/2521693316", rootViewController: controller, adTypes: [GADAdLoaderAdType.unifiedNative], options: [multipleAdsOptions])
           adLoader.delegate = self

        let adRequest = GADRequest()
        adLoader.load(adRequest)
        
        
   //        adLoader.load(GADRequest())
       }
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
}
extension FieldListLiteAdCell: GADUnifiedNativeAdDelegate {

    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        print("\(#function) called")
    }
}
