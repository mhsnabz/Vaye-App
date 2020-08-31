//
//  FullScreenImage.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 31.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class FullScreenImage: UIViewController {
    var image : String?{
        didSet{
            guard let image = image else { return }
             profileImage.sd_imageIndicator = SDWebImageActivityIndicator.white
            profileImage.sd_setImage(with: URL(string: image), completed: nil)
        }
    }
    let profileImage : UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .black
        return img
    }()
    let cancel : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "x").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return btn
        
    }()
    lazy var scrollView : UIScrollView = {
        let scroolView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        scroolView.addSubview(profileImage)
        profileImage.anchor(top: scroolView.topAnchor, left: scroolView.leftAnchor, bottom: scroolView.bottomAnchor, rigth: scroolView.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: scroolView.frame.width, heigth: scroolView.frame.height)
        scroolView.isUserInteractionEnabled = true
        return scroolView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: view.frame.width, heigth: view.frame.height)
        view.addSubview(cancel)
        cancel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: nil, marginTop: 15, marginLeft: 15, marginBottom: 0, marginRigth: 0, width: 30, heigth: 30)

        cancel.addTarget(self, action: #selector(dismis), for: .touchUpInside)
        scrollView.delegate = self

    }
    
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }

}
extension FullScreenImage : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
     return profileImage
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = profileImage.image  {
            let W = profileImage.frame.width / image.size.width
            let H = profileImage.frame.height / image.size.height
            
            let ratio = W < H ? W : H
            let newW = image.size.width * ratio
            let newH = image.size.height * ratio
            
            let conditionLeft = newW*scrollView.zoomScale > profileImage.frame.width
            
            let left = 0.5 * (conditionLeft ? newW - profileImage.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
            let conditonTop = newH*scrollView.zoomScale > profileImage.frame.height
            
            let top = 0.5 * (conditonTop ? newH - profileImage.frame.height :
                (scrollView.frame.height - scrollView.contentSize.height))
            
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        }
        else {
            scrollView.contentInset = .zero
           }
    }
}
