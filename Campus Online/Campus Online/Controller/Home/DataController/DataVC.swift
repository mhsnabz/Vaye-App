//
//  DataVC.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 11.09.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
private let pdf_cell = "pdfCell"
private let img_cell = "imgCell"
private let doc_cell = "docCell"
class DataVC: UIViewController {
    //MARK:- properites
    
    let titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.font = UIFont(name: Utilities.font, size: 15)
        lbl.textColor = .black
        return lbl
    }()
    let dissmisButton : UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "down-arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    
    let downloadAll : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Bütün Dosyaları İndir", for: .normal)
        btn.titleLabel?.font = UIFont(name: Utilities.font, size: 12)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.black.cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderWidth = 0.75
        return btn
    }()
    
    lazy var headerBar : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.addSubview(dissmisButton)
        dissmisButton.anchor(top: nil, left: v.leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 20, marginBottom: 0, marginRigth: 0, width: 20, heigth: 20)
        dissmisButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        v.addSubview(downloadAll)
        downloadAll.anchor(top: nil, left: nil, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 150, heigth: 35)
        downloadAll.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        downloadAll.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        return v
    }()
    //MARK:- variables
    var DataUrl = [String]()
    var collectionview: UICollectionView!
    //MARK:- lifeCycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureCollectionView()
        dissmisButton.addTarget(self, action: #selector(dismisVC), for: .touchUpInside)
        
    }
   
    
    init(dataUrl : [String]){
        self.DataUrl = dataUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- selectors
    @objc func dismisVC(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func download_all(){
         let urlString = self.DataUrl[0]
                let url = URL(string: urlString)
                let fileName = String((url!.lastPathComponent)) as NSString
                // Create destination URL
                let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
                //Create URL to the source file you want to download
                let fileURL = URL(string: urlString)
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let request = URLRequest(url:fileURL!)
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            do {
                                //Show UIActivityViewController to save the downloaded file
                                let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                                for indexx in 0..<contents.count {
                                    if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                        DispatchQueue.main.async {
                                            let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                            self.present(activityViewController, animated: true, completion: nil)                                        }
                                       
                                    }
                                }
                            }
                            catch (let err) {
                                print("error: \(err)")
                            }
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                    } else {
                        print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
                    }
                }
                task.resume()
        }
//        FileDownloader.loadFileAsync(url: URL(string: DataUrl[1])!) { (path, error) in
//            print("PDF File downloaded to : \(path!)")
           


    
    //MARK:- functions
    fileprivate func configureCollectionView() {
        
        view.addSubview(headerBar)
        headerBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 50)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .black
        collectionview.isPagingEnabled = true
        view.addSubview(collectionview)
        collectionview.anchor(top: headerBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, rigth: view.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        collectionview.register(DataViewImage.self, forCellWithReuseIdentifier: img_cell)
        collectionview.register(DataViewPDF.self, forCellWithReuseIdentifier: pdf_cell)
        collectionview.register(DataViewDoc.self, forCellWithReuseIdentifier: doc_cell)
        
        downloadAll.addTarget(self, action: #selector(download_all), for: .touchUpInside)
        
        
    }
    
    
}
class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
extension DataVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataUrl.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //  \(URL(string: item)?.mimeType())
        if URL(string: DataUrl[indexPath.row])!.mimeType() == "image/jpeg" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: img_cell, for: indexPath) as! DataViewImage
            cell.url = DataUrl[indexPath.row]
            return cell
        }else if  URL(string: DataUrl[indexPath.row])!.mimeType() == "application/pdf" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pdf_cell, for: indexPath) as! DataViewPDF
            cell.url = DataUrl[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: doc_cell, for: indexPath) as! DataViewDoc
            cell.url = DataUrl[indexPath.row]
            return cell
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
