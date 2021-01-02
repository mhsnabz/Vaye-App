//
//  RecordSheet.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 30.12.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import Lottie
import AVFoundation
import MessageKit
protocol sendAudioProtocol : class {
    func sendAudioItem(item : URL , fileName : String)
}

class RecordSheet : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var duration : Float = 0
    var isPlaying : Bool = false
    var isRecording : Bool = false

     lazy var record = AnimationView()
    lazy var play_pause = AnimationView()
    lazy var send = AnimationView()
    weak var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
     var audioPlayer : AVAudioPlayer?
    var audioName : String = ""
    weak var delegate : sendAudioProtocol?
    var infoAtt : NSMutableAttributedString = {
        let name = NSMutableAttributedString()
        return name
    }()
    let lbl : UILabel = {
       let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    private let currentUser : CurrentUser
    private let otherUser : OtherUser
    private var window : UIWindow?
    weak var dismisDelgate : DismisDelegate?
    private lazy var blackView : UIView = {
       let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tap)
        return view
    }()
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
    
    private lazy var recordView : UIView = {
       let v = UIView()
        v.backgroundColor = .white
        v.addSubview(footerView)
        footerView.anchor(top: nil , left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 10, marginRigth: 0, width: 0, heigth: 40)
        v.addSubview(animationButtons)
        animationButtons.anchor(top: nil, left: v.leftAnchor, bottom: footerView.topAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 12, marginBottom: 12, marginRigth: 0, width: 0, heigth: 60)
        
        infoAtt = NSMutableAttributedString(string: "Yeni Bir", attributes: [NSAttributedString.Key.font : UIFont(name: Utilities.fontBold, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        infoAtt.append(NSAttributedString(string: " KAYIT", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.fontBold, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.red ]))
        infoAtt.append(NSAttributedString(string: " Yapmak için Kayıt Butonuna Basın", attributes: [NSAttributedString.Key.font:UIFont(name: Utilities.fontBold, size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.darkGray ]))
        lbl.attributedText = infoAtt
        v.addSubview(lbl)
        lbl.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: animationButtons.topAnchor, rigth: v.rightAnchor, marginTop: 4, marginLeft: 12, marginBottom: 4, marginRigth: 12, width: 0, heigth: 0)
        
        return v
    }()
    lazy var animationButtons : UIView = {
       let v = UIView()
        
        record.animation = Animation.named("record")
        play_pause.animation = Animation.named("play-pause")
        send.animation = Animation.named("send")
        send.animationSpeed = 1.5
        let stack = UIStackView(arrangedSubviews: [play_pause,record,send])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        
        
        let recordChoose = UITapGestureRecognizer(target: self, action:  #selector (recordBtn(_:)))
        record.addGestureRecognizer(recordChoose)
        let playTap = UITapGestureRecognizer(target: self, action:  #selector (playClick(_:)))
        play_pause.addGestureRecognizer(playTap)
        let sendTap = UITapGestureRecognizer(target: self, action:  #selector (sendClick(_:)))
        send.addGestureRecognizer(sendTap)
        
        
        v.addSubview(stack)
        stack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, rigth: v.rightAnchor, marginTop: 0, marginLeft: 0, marginBottom: 0, marginRigth: 0, width: 0, heigth: 0)
        
        play_pause.isHidden = true
        send.isHidden = true
        lbl.isHidden = true
        return v
    }()
    fileprivate  func showTableView(_ shouldShow : Bool)
    {
        guard let window = window else { return }
        
        let y = shouldShow ? window.frame.height - 160 : window.frame.height
        recordView.frame.origin.y = y
        
        if !shouldShow {
            self.blackView.removeFromSuperview()
        }
        
    }
    
    func show( audioName : String ){
        self.audioName = audioName
        guard let window = UIApplication.shared.windows.first(where: { ($0.isKeyWindow)}) else { return }
        self.window = window
        window.addSubview(blackView)
        blackView.frame = window.frame
        window.addSubview(recordView)
        recordView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 160)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.recordView.frame.origin.y -= 160
        }
    }
    
    func configureUIview(){
        recordView.backgroundColor = .white
        recordView.clipsToBounds = true
        recordView.layer.cornerRadius = 10
        
       
        
    }
    
    init(currentUser : CurrentUser , otherUser : OtherUser ){
        self.currentUser = currentUser
        self.otherUser = otherUser
    
        super.init()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.configureUIview()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    @objc  func handleDismiss(){
        UIView.animate(withDuration: 0.5) {

            self.blackView.alpha = 0
            self.recordView.frame.origin.y += 160
            self.dismisDelgate?.dismisMenu()
        }
    }
    func startRecording() {
        play_pause.isHidden = true
        send.isHidden  = true
        lbl.isHidden = true
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(audioName)\(DataTypes.auido.mimeType)")
                let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.delegate = self
            audioRecorder.record()
            isRecording = true

//            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
          //  recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
          //  recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    @objc func recordBtn(_ sender:UITapGestureRecognizer){
        if !isRecording {
            isRecording = true
            record.play(fromProgress: 0, toProgress: 100, loopMode: .none, completion: nil)
            
            record.animationSpeed = 1.5
            startRecording()
            print("start reccording")
            
        }else{
            record.play(fromFrame: 100, toFrame: 0, loopMode: .none) {[weak self] (val) in
                guard let sself = self else { return }
                if val {
                    sself.isRecording = false
                    sself.finishRecording(success: true)
                    sself.play_pause.isHidden = false
                    sself.send.isHidden = false
                    sself.lbl.isHidden = false
                }
            }
        }
    }
    func SetSessionPlayerOn()
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch _ {
        }
    }
    func SetSessionPlayerOff()
    {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
    @objc func playClick(_ sender:UITapGestureRecognizer){
        SetSessionPlayerOn()
        if !isPlaying {
            isPlaying = true
            play_pause.play(fromFrame: 0, toFrame: 60, loopMode: .none) {[weak self] (_) in
                guard let sself = self else { return }
                do{
                    sself.audioPlayer = try AVAudioPlayer(contentsOf: sself.getDocumentsDirectory().appendingPathComponent("\(sself.audioName)\(DataTypes.auido.mimeType)"))
                    sself.audioPlayer?.delegate = self
                    sself.audioPlayer?.play()
                }catch{
                    print("error")
                }
            }
        }else{
            play_pause.play(fromFrame: 60, toFrame: 0, loopMode: .none) { (_) in
                if ((self.audioPlayer?.isPlaying) != nil) {
                    self.audioPlayer?.pause()
                    self.isPlaying = false
                }
            }
        }
        

    }
    @objc func sendClick(_ sender:UITapGestureRecognizer){
        send.play(fromFrame: 0, toFrame: 120, loopMode: .none) {[weak self] (_val) in
            guard let sself = self else { return }
            if _val{
                sself.delegate?.sendAudioItem(item:sself.getDocumentsDirectory().appendingPathComponent("\(sself.audioName)\(DataTypes.auido.mimeType)"), fileName: "\(sself.audioName)\(DataTypes.auido.mimeType)")
                sself.handleDismiss()
                sself.audioPlayer = nil
                sself.audioName = ""
                sself.audioRecorder = nil
                sself.play_pause.isHidden = true
                sself.send.isHidden = true
            }
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if flag {
            play_pause.play(fromFrame: 60, toFrame: 0, loopMode: .none, completion: nil)
            play_pause.play(fromFrame: 60, toFrame: 0, loopMode: .none) { (val) in
                self.play_pause.currentFrame = 0
            }
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            
        }
    }
    
    
}

