//
//  DataViewImage.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 12.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class DataViewImage: UICollectionViewCell {

    var url : String?{
        didSet{
            guard let url = url else { return }
            img.sd_imageIndicator = SDWebImageActivityIndicator.white
            img.sd_setImage(with: URL(string: url))
        }
    }
    let img : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = UIColor(white: 0.90, alpha: 0.7)
        img.clipsToBounds = true
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(img)
        img.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        img.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(imageClick)))
        img.enableZoom()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func imageClick(){
//        delegate?.imageClik(for: self)
            
    }
}
extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}
