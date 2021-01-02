//
//  MessagesVCLauncher.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 2.01.2021.
//  Copyright © 2021 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
class MessagesVCLauncher : NSObject {
    var currentUser : CurrentUser
    private let target : String
    private let tableView = UITableView()
    private var window : UIWindow?
    private var tableViewHeight : CGFloat?
    weak var delegate : MessagesVCSettingDelegate?
    private lazy var viewModel = MessagesVCViewModel(currentUser: currentUser, target: target)
    
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
    
    init(currentUser : CurrentUser , target : String) {
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
    func show(){
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
        tableView.register(MessagesVcLauncherCell.self, forCellReuseIdentifier: "id")
      
    }
    @objc  func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            let heigth = CGFloat( self.viewModel.imageOptions.count * 50 ) + 60
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += heigth
          
        }
    }
}
extension MessagesVCLauncher : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id",for: indexPath) as! MessagesVcLauncherCell
        cell.options = viewModel.imageOptions[indexPath.row]
        
        if cell.titleLabel.text == MessagesVCOptions.disableRequest(currentUser).description {
            if  currentUser.allowRequest {
                cell.titleLabel.text = MessagesVCOptions.disableRequest(currentUser).description
                cell.logo.image = #imageLiteral(resourceName: "on").withRenderingMode(.alwaysOriginal)
               
            }else{
                cell.titleLabel.text = "Mesaj İsteklerini Aç"
                cell.logo.image = #imageLiteral(resourceName: "off").withRenderingMode(.alwaysOriginal)
            }
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
        let option = viewModel.imageOptions[indexPath.row]
        delegate?.didSelect(option: option)
        UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 0
                self.showTableView(false)
        }) { (_) in
             self.tableView.reloadData()
         
        }
    }
    
}

class MessagesVcLauncherCell : UITableViewCell {
    var options : MessagesVCOptions?{
        didSet{
            configure()
        }
    }
  
     let logo : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        return img
    }()
     let titleLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: Utilities.font, size: 14)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "id")
        addSubview(logo)
        logo.anchor(top: nil, left: leftAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 8, marginBottom: 0, marginRigth: 0, width: 25, heigth: 25)
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: logo.rightAnchor, bottom: nil, rigth: nil, marginTop: 0, marginLeft: 12, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(){
        titleLabel.text = options?.description
        logo.image = options?.image
    }
    func configureNotificaiton(){
        titleLabel.text = options?.description
        logo.image = options?.image
    }
}
