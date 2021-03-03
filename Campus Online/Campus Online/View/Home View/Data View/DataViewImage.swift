//
//  DataViewImage.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 12.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class DataViewImage: UICollectionViewCell, UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = img.image {
                let ratioW = img.frame.width / image.size.width
                let ratioH = img.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > img.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - img.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > img.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - img.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }

    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scrollView.delegate = self
        scrollView.addSubview(img)
//        img.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, rigth: scrollView.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        img.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        return scrollView
    }()
    
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
        img.backgroundColor = .black
        return img
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
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
