//
//  DataViewPDF.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 12.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import PDFKit
import WebKit
class DataViewPDF: UICollectionViewCell, WKNavigationDelegate {
//    weak var activityIndicator: UIActivityIndicatorView!
    var url : String?{
        didSet{
           
            }
        }
    
    lazy var activityIndicator : UIActivityIndicatorView = {
       let a = UIActivityIndicatorView()
        a.hidesWhenStopped = true
        a.style = UIActivityIndicatorView.Style.gray
        return a
    }()
    lazy var btn : UIButton = {
        let btn  = UIButton(type: .system)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.setBackgroundColor(color: .white, forState: .normal)
        btn.setTitle("PDF'yi Görüntüle", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 14)
        
        return btn
        
    }()
    lazy var pdfView : WKWebView = {
        let pdf = WKWebView()
        return pdf
    }()
 
    deinit {
        print("denit data view pdf")
        if #available(iOS 9.0, *) {
          let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
          let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"

            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
              print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(pdfView)
        backgroundColor = .white
        addSubview(btn)
        btn.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 150, heigth: 40)
        btn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        btn.addTarget(self, action: #selector(showPdf), for: .touchUpInside)
    
       
        
        addSubview(activityIndicator)
        activityIndicator.center = center
//        pdfView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        
    }
    @objc func showPdf(){
        guard let urlString = url else { return }
        guard let url = URL(string: urlString) else {
            return }
        UIApplication.shared.open(url)
//        activityIndicator.startAnimating()
//        pdfView.isHidden = false
//        btn.isHidden = true
//
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        pdfView.isUserInteractionEnabled = true
//        pdfView.navigationDelegate = self
//         addSubview(self.pdfView)
//        self.pdfView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, rigth: rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
//        let request = URLRequest(url: url)
//        pdfView.load(request)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
