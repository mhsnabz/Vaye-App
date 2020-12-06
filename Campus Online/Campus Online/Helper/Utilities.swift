//
//  Utilities.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import SVProgressHUD
class Utilities  {
    
    
    static func waitProgress(msg : String?){
        if msg != nil{
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBorderColor(.white)
            SVProgressHUD.show(withStatus: msg)
            SVProgressHUD.setForegroundColor(.white)
        }else{
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setBorderColor(.white)
            SVProgressHUD.show(withStatus: nil)
            SVProgressHUD.setForegroundColor(.white)
        }
        
    }
    static func succesProgress(msg : String?){
        if msg != nil{
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setBorderColor(.white)
            SVProgressHUD.showSuccess(withStatus: msg)
            SVProgressHUD.setForegroundColor(.white)
            SVProgressHUD.dismiss(withDelay: 1500)
        }else{
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setBorderColor(.white)
            SVProgressHUD.showSuccess(withStatus: nil)
            SVProgressHUD.setForegroundColor(.white)
            SVProgressHUD.dismiss(withDelay: 1500)
        }
        
    }
    static func dismissProgress(){
        SVProgressHUD.dismiss()
    }
    static func errorProgress(msg : String?){
        if  msg == nil {
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setBorderColor(.white)
            
            SVProgressHUD.showError(withStatus: nil)
            SVProgressHUD.setForegroundColor(.white)
            SVProgressHUD.dismiss(withDelay: 1500)
        }else{
            SVProgressHUD.setBackgroundColor(.black)
            SVProgressHUD.setFont(UIFont(name: Utilities.font, size: 12)!)
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setBorderColor(.white)
            
            SVProgressHUD.showError(withStatus: msg)
            SVProgressHUD.setForegroundColor(.white)
            SVProgressHUD.dismiss(withDelay: 1500)
        }
        
    }
    
    static func checkUserExist(username : String , comletion : @escaping(Bool) -> Void){
        guard username != "" else { return }
        
        let db = Firestore.firestore().collection("username").document(username)
        db.getDocument { (docSnap, err) in
            if err == nil{
                if docSnap!.exists {
                    comletion(true)
                }else{
                    comletion(false)
                }
            }
            
        }
        
    }
    static func checkUserNumberExist(usernumber : String,school : String , comletion : @escaping(Bool) -> Void){
        guard usernumber != "" else { return }
        let db = Firestore.firestore().collection(school).document("students").collection("student-number").document(usernumber)
        db.getDocument { (docSnap, err) in
            if err == nil {
                if docSnap!.exists {
                    comletion(true)
                }else{
                    comletion(false)
                }
            }
            
        }}
    
    //  static  func notificaitonSetting (uid : String , type : String , comletion : @escaping(Bool) -> Void ){
    //        let doc = Firestore.firestore().collection("notificationSetting").document(uid)
    //        doc.getDocument { (docSnap, err) in
    //            if err == nil{
    //                if docSnap!.exists {
    //                    if type == "Sizin Gönderinizi Beğendi" {
    //                        if docSnap?.get("like") as! Bool {
    //                            comletion(true)
    //                        }else{
    //                            comletion(false)
    //                        }
    //                    }
    //                    else if type == "Sizin Gönderinize Yorum Yaptı"{
    //                        if docSnap?.get("comment") as! Bool {
    //                            comletion(true)
    //                        }else{
    //                            comletion(false)
    //                        }
    //                    }
    //                    else if type == "Yeni Bir Gönderi Paylaştı"{
    //                        if docSnap?.get("notice") as! Bool
    //                        {
    //
    //                            comletion(true)
    //
    //                        }else{
    //
    //                            comletion(false)
    //
    //                        }
    //                    }else if type == "Size Mesaj Göndemek İstiyor"{
    //                        if docSnap?.get("request") as! Bool
    //                        {
    //                            comletion(true)
    //                        }else{
    //                            comletion(false)
    //                        }
    //                    }else if type == "Size Mesaj Gönderdi" {
    //                        if docSnap?.get("msg") as! Bool
    //                        {
    //                            comletion(true)
    //                        }else{
    //                            comletion(false)
    //                        }
    //                    }else if type == "Mesaj İsteğinizi Kabul Etti" {
    //                        if docSnap?.get("request") as! Bool
    //                        {
    //                            comletion(true)
    //                        }else{
    //                            comletion(false)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    
    static var font =  "AvenirNext-Medium"
    static var fontBold =  "AvenirNext-DemiBold"
    static var italic = "AvenirNext-Italic"
    static var adUnitID = "ca-app-pub-3940256099942544/2521693316" 
    //   let adUnitID = "ca-app-pub-3940256099942544/2521693316"  // "ca-app-pub-3940256099942544/3986624511"
    //    let adUnitID = "ca-app-pub-1362663023819993/1801312504"
    static var takip = "Sizi Takip Etmeye Başladı"
    static var mesajIstegi = "Size Mesaj Göndemek İstiyor"
    static var begeni = "Sizin Gönderinizi Beğendi"
    static var yorum = "Sizin Gönderinize Yorum Yaptı"
    static var yeniMesaj = "Size Mesaj Gönderdi"
    static var yeniGonderi = "Yeni Bir Gönderi Paylaştı"
    static var mesajRed = "Mesaj İsteğinizi Kabul Etmedi"
    static var mesajKabul = "Mesaj İsteğinizi Kabul Etti"
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.mainColor()
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    static func enabledButton (_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.mainColorTransparent()
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    //    static func sendNotification( currentUser : CurrentUser ,  getterUid : String ,  msg : String ,  time : Int64,  type : String)
    //    {
    //
    //        notificaitonSetting(uid: getterUid, type: type) { (setting) in
    //            if setting {
    //
    //
    //                let db = Firestore.firestore().collection("notification")
    //                    .document(getterUid).collection("notification")
    //                let oUser = Firestore.firestore().collection("user").document(getterUid)
    //                oUser.getDocument { (docSnap, err) in
    //                    if err == nil {
    //                        if docSnap!.exists {
    //                            let dic = ["senderName":currentUser.name!,"getterTokenID":docSnap?.get("tokenID") as? String ?? "","from":currentUser.uid! ,"to":getterUid,"type":type,"senderImage":currentUser.profileImage!,"time":time,"msg":msg] as [String:Any]
    //                            db.addDocument(data: dic)
    //                        }
    //                    }
    //                }
    //            }
    //
    //        }
    //
    //
    //
    //    }
}
extension UIView{
    func anchor(top : NSLayoutYAxisAnchor?
                ,left : NSLayoutXAxisAnchor?,
                bottom : NSLayoutYAxisAnchor? ,
                rigth: NSLayoutXAxisAnchor?,
                marginTop : CGFloat ,
                marginLeft : CGFloat ,
                marginBottom: CGFloat
                ,marginRigth : CGFloat ,
                width : CGFloat ,
                heigth : CGFloat){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: marginTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: marginLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -marginBottom).isActive = true
        }
        if let rigth = rigth {
            self.rightAnchor.constraint(equalTo: rigth, constant: -marginRigth).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if heigth != 0{
            heightAnchor.constraint(equalToConstant: heigth).isActive = true
        }
    }
}
extension UIColor {
    static func mainColor() -> UIColor {
        return  UIColor.init(red: 80/255, green: 145/255, blue: 233/255, alpha: 1)
    }
    static func mainColorTransparent() -> UIColor {
        return  UIColor.init(red: 80/255, green: 145/255, blue: 233/255, alpha: 0.4)
    }
    static func linkColor() -> UIColor {
        return  UIColor.init(red: 70/255, green: 140/255, blue: 247/255, alpha: 1)
    }
    static func cancelColor() -> UIColor {
        return  UIColor.init(red: 241/255, green: 238/255, blue: 246/255, alpha: 1)
    }
    static func collectionColor () -> UIColor {
        return UIColor.init(red: 218/255, green: 230/255, blue: 245/255, alpha: 1)
    }
    
}
extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return " şimdi "
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) dk "
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) sa"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) g"
        }
        
        return "\(secondsAgo / week) h"
    }
}
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
var vSpinner : UIView?




extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension Double {
    
    
    // returns the date formatted.
    var dateFormatted : String? {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
        return dateFormatter.string(from: date)
    }
    
    // returns the date formatted according to the format string provided.
    func dateFormatted(withFormat format : String) -> String{
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
}
extension UIViewController {
    func setNavigationBar(){
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: Utilities.fontBold, size: 14)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
}
extension StringProtocol where Self: RangeReplaceableCollection {
    var removingAllWhitespaces: Self {
        filter { !$0.isWhitespace }
    }
    mutating func removeAllWhitespaces() {
        removeAll(where: \.isWhitespace)
    }
}
extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz1234567890-._")
        return self.filter {okayChars.contains($0) }
    }
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
extension String {
    func yuksek(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func genis(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension StringProtocol {
    subscript(_ offset: Int) -> Element
    { self[index(startIndex, offsetBy: offset)] }
    
    subscript(_ range: Range<Int>)   -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    
    subscript(_ range: ClosedRange<Int>)-> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence
    { prefix(range.upperBound.advanced(by: 1)) }
    
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence
    { prefix(range.upperBound) }
    
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence
    { suffix(Swift.max(0, count-range.lowerBound)) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
