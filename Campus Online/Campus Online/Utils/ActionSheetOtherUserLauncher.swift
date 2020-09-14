//
//  ActionSheetOtherUserLauncher.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 14.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
class ActionSheetOtherUserLaunher : NSObject{
    //MARK: -properties
    private let currentUser : CurrentUser
    private var otherUser : OtherUser?
    private let target : String
    private let tableView = UITableView()
    private var window : UIWindow?
    private lazy var viewModel = ActionSheetHomeOtherUserViewModel(currentUser: currentUser, target: target)
    weak var delegate : ActionSheetOtherUserLauncherDelegate?
    private var tableViewHeight : CGFloat?
    var post : LessonPostModel?
    private lazy var cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Vazgeç", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.backgroundColor = .cancelColor()
        button.titleLabel?.font = UIFont(name: Utilities.font, size: 18)
        
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let fallowBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Takip Et", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 0.75
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let image : UIImageView = {
       let img = UIImageView()
        img.clipsToBounds = true
        img.layer.borderWidth = 0.75
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.backgroundColor = .lightGray
        return img
    }()
    private lazy var footerView : UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 12, width: 0, heigth: 0)
        cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cancelButton.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var blackView : UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    init(currentUser : CurrentUser , target : String ) {
        self.currentUser = currentUser
        self.target = target
        
        super.init()
        configureTableView()
    }
    //MARK:- helper
    fileprivate  func showTableView(_ shouldShow : Bool)
    {
        guard let window = window else { return }
        guard let heigth = tableViewHeight else { return }
        let y = shouldShow ? window.frame.height - heigth : window.frame.height
        tableView.frame.origin.y = y
        
        if !shouldShow {
            self.blackView.removeFromSuperview()
        }
        
    }
    
    func show(post : LessonPostModel , otherUser : OtherUser){
        self.post = post
        self.otherUser = otherUser
        self.tableView.reloadData()
        guard let window = UIApplication.shared.windows.first(where: { ($0.isKeyWindow)}) else { return }
        self.window = window
        window.addSubview(blackView)
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        let heigth = CGFloat( viewModel.imageOptions.count * 50 ) + 60
        self.tableViewHeight = heigth
        tableView.frame = CGRect(x: 0, y: window.frame.height,
                                 width: window.frame.width, height: heigth)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.tableView.frame.origin.y -= heigth
        }
        
    }
    func configureTableView()
    {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        tableView.register(ActionOtherUserCell.self, forCellReuseIdentifier: "id")
        
    }
    @objc  func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            let heigth = CGFloat( self.viewModel.imageOptions.count * 50 ) + 60
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += heigth
            
        }
    }
    private func addSlient(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post")
            .collection("post")
            .document(post!.postId)
        db.updateData(["silent":FieldValue.arrayUnion([currentUser.uid as Any])]) { (err) in
            if err == nil {
                Utilities.succesProgress(msg: "Bildirimler Kapatıldı")
                self.post?.silent.append(currentUser.uid)
                completion(true)
                
            }
        }
        
    }
    private func removeSlient(currentUser : CurrentUser , completion : @escaping(Bool) ->Void){
        Utilities.waitProgress(msg: nil)
        let db = Firestore.firestore().collection(currentUser.short_school)
            .document("lesson-post")
            .collection("post")
            .document(post!.postId)
        
        db.updateData(["silent":FieldValue.arrayRemove([currentUser.uid as Any])]) { (err) in
            if err == nil {
                
                
                if let index = self.post?.silent.firstIndex(of: currentUser.uid) {
                    Utilities.succesProgress(msg: "Bildirimler Açıldı")
                    self.post?.silent.remove(at: index)
                    completion(true)
                } else {
                    Utilities.errorProgress(msg: "Hata Oluştu")
                    completion(false)
                }
                
            }
        }
    }
}

extension ActionSheetOtherUserLaunher : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id",for: indexPath) as! ActionOtherUserCell
        cell.options = viewModel.imageOptions[indexPath.row]
        if cell.titleLabel.text == ActionSheetOtherUserOptions.fallowUser(currentUser).description{
           
            cell.titleLabel.text = otherUser!.username
            cell.logo.layer.cornerRadius = 25 / 2
            cell.logo.sd_setImage(with: URL(string: otherUser!.thumb_image))
            cell.addSubview(fallowBtn)
            fallowBtn.anchor(top: nil, left: nil
                , bottom: nil, rigth: cell.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 10, width: 125, heigth: 25)
            fallowBtn.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
        }  else  if cell.titleLabel.text == ActionSheetOtherUserOptions.reportUser(currentUser).description{
            cell.titleLabel.textColor = .red
            cell.titleLabel.font = UIFont(name: Utilities.fontBold, size: 13)
        }
            

        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _ = tableView.cellForRow(at: indexPath) as! ActionOtherUserCell
        //  print(currentCell.titleLabel.text)
        dismissTableView(indexPath)
//        if cell.titleLabel.text == ActionSheetOtherUserOptions.{
//
//            addSlient(currentUser: currentUser) {[weak self] (_val) in
//                if _val{
//                    self?.dismissTableView(indexPath)
//                }
//            }
//        }else if cell.titleLabel.text == "Gönderi Bildirimlerini Aç"{
//            removeSlient(currentUser: currentUser) {[weak self] (_) in
//                self?.dismissTableView(indexPath)
//            }
//        }else{
//            dismissTableView(indexPath)
//        }
        
        
    }
    
    fileprivate func dismissTableView(_ indexPath: IndexPath) {
        let option = viewModel.imageOptions[indexPath.row]
           delegate?.didSelect(option: option)
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            self.showTableView(false)
        }) { (_) in
            self.tableView.reloadData()
            self.delegate?.didSelect(option: option)
        }
    }
}

