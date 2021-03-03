//
//  ImagesStack.swift
//  VayeApp
//
//  Created by mahsun abuzeyitoğlu on 2.03.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import SDWebImage
class ImagesStack : UIView {
    
    var imagesData : [String]?{
        didSet{
            guard let url = imagesData else { return }
            setThumbImage(urlDatas: url)
            totalImage.text = "+\(url.count - 3)"
        }
    }
    
    
    lazy var imageLayer_one : UIView = {
       let v  = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.addSubview(image_1_1)
        image_1_1.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    
     lazy var imageLayer_two : UIView = {
       let v  = UIView()
        v.backgroundColor = .white
//        v.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [image_2_1,image_2_2])
        stack.distribution = .fillEqually
        stack.alignment = .center
     //   stack.spacing = 2
        stack.axis = .horizontal
        v.addSubview(stack)
        stack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    lazy var imageLayer_there : UIView = {
       let v  = UIView()
        v.backgroundColor = .white
//        v.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [image_3_1,image_3_2])
        stack.distribution = .fillEqually
        stack.alignment = .center
       // stack.spacing = 2
        stack.axis = .vertical
         
        let finalStack = UIStackView(arrangedSubviews: [stack,image_3_3])
        finalStack.distribution = .fillEqually
        finalStack.alignment = .center
       // finalStack.spacing = 2
        finalStack.axis = .horizontal
        
        v.addSubview(finalStack)
        finalStack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    lazy var imageLayer_four : UIView = {
       let v  = UIView()
        v.backgroundColor = .white
//        v.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [image_4_1,image_4_2])
        stack.distribution = .fillEqually
        stack.alignment = .center
       // stack.spacing = 2
        stack.axis = .vertical
         
        let stack2 = UIStackView(arrangedSubviews: [image_4_3,transparentImage4_4])
        stack2.distribution = .fillEqually
        stack2.alignment = .center
       // finalStack.spacing = 2
        stack2.axis = .vertical
        
        let finalStack = UIStackView(arrangedSubviews: [stack,stack2])
        finalStack.distribution = .fillEqually
        finalStack.alignment = .center
       // finalStack.spacing = 2
        finalStack.axis = .horizontal
        
        v.addSubview(finalStack)
        finalStack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    
   
    
    let image_1_1 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_2_1 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_3_1 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_2_2 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_3_2 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    let image_3_3 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var image_4_4 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.addSubview(transparentView)
        transparentView.frame = imageView.frame
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_4_3 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_4_2 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let image_4_1 : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
       
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var transparentImage4_4 : UIView = {
       let v = UIView()
        v.addSubview(image_4_4)
        image_4_4.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        v.addSubview(transparentView)
        transparentView.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        return v
    }()
    
    lazy var transparentView : UIView = {
        let v = UIView()
        v.backgroundColor = .darkGray
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.cgColor
        v.alpha = 0.8
    
        
        v.addSubview(totalImage)
        totalImage.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 10, marginLeft: 10, marginBottom: 10, marginRigth: 10, width: 0, heigth: 0)
        return v
    }()
    
    let totalImage : UILabel = {
        let lbl = UILabel()
  
        lbl.textAlignment = .center
        lbl.font = UIFont(name: Utilities.fontBold, size: 40)
        lbl.textColor = .white
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageLayer_one)
        addSubview(imageLayer_two)
        addSubview(imageLayer_there)
        addSubview(imageLayer_four)
        imageLayer_one.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        imageLayer_two.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        imageLayer_there.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        imageLayer_four.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        imageLayer_one.isHidden = true
        imageLayer_two.isHidden = true
        imageLayer_there.isHidden = true
        imageLayer_four.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setThumbImage(urlDatas : [String]){
        if urlDatas.count == 1 {
            image_1_1.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_1_1.sd_setImage(with: URL(string: urlDatas[0]))
        }else if urlDatas.count == 2 {
            image_2_1.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_2_1.sd_setImage(with: URL(string: urlDatas[0]))
            
            image_2_2.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_2_2.sd_setImage(with: URL(string: urlDatas[1]))
        }else if urlDatas.count == 3 {
            image_3_1.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_3_1.sd_setImage(with: URL(string: urlDatas[0]))
            
            image_3_2.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_3_2.sd_setImage(with: URL(string: urlDatas[1]))
            
            image_3_3.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_3_3.sd_setImage(with: URL(string: urlDatas[2]))
            
        }else{
            image_4_1.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_4_1.sd_setImage(with: URL(string: urlDatas[0]))
            
            image_4_2.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_4_2.sd_setImage(with: URL(string: urlDatas[1]))
            
            image_4_3.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_4_3.sd_setImage(with: URL(string: urlDatas[2]))
            
            image_4_4.sd_imageIndicator = SDWebImageActivityIndicator.white
            image_4_4.sd_setImage(with: URL(string: urlDatas[3]))
        }
    }
}
