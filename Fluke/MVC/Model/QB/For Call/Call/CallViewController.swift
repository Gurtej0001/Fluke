//
//  CallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

protocol CallEndDelegate: class {
func endCallWithDurationInSecond(_ totalSeconds: String, receiverId: String)

}

enum CallViewControllerState : Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

struct CallStateConstant {
    static let disconnected = "Disconnected"
    static let connecting = "Connecting..."
    static let connected = "Connected"
    static let disconnecting = "Disconnecting..."
}

struct CallConstant {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call. Please, reduce the quality of the video settings", comment: "")
    static let sessionDidClose = NSLocalizedString("Session did close due to time out", comment: "")
}

class CallViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet private weak var opponentsCollectionView: UICollectionView!
    
    @IBOutlet private weak var toolbar: ToolBar!
    @IBOutlet private weak var btnNewSpeaker: UIButton!
    @IBOutlet private weak var btnNewMuteCall: UIButton!
    @IBOutlet private weak var btnNewCallButton: UIButton!
    @IBOutlet private weak var lblStatus: UILabel!
    @IBOutlet private weak var ivImage: UIImageView!
    
    @IBOutlet private weak var opponentVideoView: UIView!
    @IBOutlet private weak var myVideoView: UIView!
    
    //MARK: - Properties
    weak var usersDataSource: UsersDataSource?
    
    var otherUserId: String!
    var callEndDelegate:CallEndDelegate?
    
    //MARK: - Internal Properties
    private var timeDuration: TimeInterval = 0.0
    
    private var callTimer: Timer?
    private var beepTimer: Timer?
    
    //Camera
    var session: QBRTCSession?
    var callUUID: UUID?
    private var cameraCapture: QBRTCCameraCapture?
    
    //Containers
    private var users = [User]()
    private var videoViews = [UInt: UIView]()
    private var statsUserID: UInt?
    
    //Views
    lazy private var dynamicButton: CustomButton = {
        let dynamicButton = ButtonsFactory.dynamicEnable()
        return dynamicButton
    }()
    
    lazy private var audioEnabled: CustomButton = {
        let audioEnabled = ButtonsFactory.audioEnable()
        return audioEnabled
    }()
    
    private var localVideoView: LocalVideoView?
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    
    private lazy var statsItem = UIBarButtonItem(title: "Stats",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(updateStatsView))
    
    
    //States
    private var shouldGetStats = false
    private var didStartPlayAndRecord = false
    private var muteVideo = false {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        }
    }
    
    private var state = CallViewControllerState.connected {
        didSet {
            switch state {
            case .disconnected:
                self.lblStatus.text = CallStateConstant.disconnected
            case .connecting:
                self.lblStatus.text = CallStateConstant.connecting
            case .connected:
                self.lblStatus.text = CallStateConstant.connected
            case .disconnecting:
                self.lblStatus.text = CallStateConstant.disconnecting
            }
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        QBRTCAudioSession.instance().addDelegate(self)
        
        let profile = Profile()
        
        guard profile.isFull == true, let currentConferenceUser = Profile.currentUser() else {
            return
        }
        
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isInitialized == false {
            audioSession.initialize { configuration in
                // adding blutetooth support
                configuration.categoryOptions.insert(.allowBluetooth)
                configuration.categoryOptions.insert(.allowBluetoothA2DP)
                configuration.categoryOptions.insert(.duckOthers)
                // adding airplay support
                configuration.categoryOptions.insert(.allowAirPlay)
                guard let session = self.session else { return }
                if session.conferenceType == .video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                }
            }
        }
        
        configureGUI()
        let settings = Settings()
        guard let session = self.session else { return }
        
        if session.conferenceType == .video {
            
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat, position: settings.preferredCameraPostion)
            self.opponentsCollectionView.isHidden = false
            cameraCapture?.startSession(nil)
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
            
            #endif
        }
        
        self.opponentsCollectionView.collectionViewLayout = OpponentsFlowLayout()
        
        users.insert(currentConferenceUser, at: 0)

        let isInitiator = currentConferenceUser.userID == session.initiatorID.uintValue
        
        if isInitiator == true {
            startCall()
        } else {
            acceptCall()
        }
        
        self.lblStatus.text = CallStateConstant.connecting
        
        if session.initiatorID.uintValue == currentConferenceUser.userID {
            CallKitManager.instance.updateCall(with: callUUID, connectingAt: Date())
        }
        
        btnNewCallButton.layer.cornerRadius = btnNewCallButton.frame.size.width/2
        btnNewMuteCall.layer.cornerRadius = btnNewCallButton.frame.size.width/2
        btnNewSpeaker.layer.cornerRadius = btnNewCallButton.frame.size.width/2        
        ivImage.layer.cornerRadius = ivImage.frame.size.width/2
        
        btnNewMuteCall.layer.borderWidth = 0.5
        btnNewMuteCall.layer.borderColor = UIColor.black.cgColor
        
        btnNewSpeaker.layer.borderWidth = 0.5
        btnNewSpeaker.layer.borderColor = UIColor.black.cgColor
        
        ivImage.layer.borderWidth = 0.5
        ivImage.layer.borderColor = UIColor.black.cgColor
        
        self.setAllValues()
        
    }
    
    
    private func setAllValues() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.cancelCallAlertWith(UsersAlertConstant.checkInternet)
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        if cameraCapture?.hasStarted == false {
            cameraCapture?.startSession(nil)
        }
        session?.localMediaStream.videoTrack.videoCapture = cameraCapture
        reloadContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        state = CallViewControllerState.disconnecting
        cancelCallAlertWith(CallConstant.memoryWarning)
    }
    
    //MARK - Setup
    func configureGUI() {
        // when conferenceType is nil, it means that user connected to the session as a listener
        if let conferenceType = session?.conferenceType {
            switch conferenceType {
            case .video:
                toolbar.add(ButtonsFactory.videoEnable(), action: { [weak self] sender in
                    if let muteVideo = self?.muteVideo {
                        self?.muteVideo = !muteVideo
                        self?.localVideoView?.isHidden = !muteVideo
                    }
                })
                toolbar.add(ButtonsFactory.screenShare(), action: { [weak self] sender in
                    guard let self = self else {
                        return
                    }
                    guard let sharingVC = self.storyboard?.instantiateViewController(withIdentifier: CallConstant.sharingViewControllerIdentifier) as? SharingViewController else {
                        return
                    }
                    self.title = "Call"
                    sharingVC.session = self.session
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Call", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(sharingVC, animated: true)
                    
                })
            case .audio:
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QBRTCAudioSession.instance().currentAudioDevice = .receiver
                    dynamicButton.pressed = false
   
                    toolbar.add(dynamicButton, action: { sender in
                        let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
                        let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
                        QBRTCAudioSession.instance().currentAudioDevice = device
                    })
                }
            }

            session?.localMediaStream.audioTrack.isEnabled = true;
            toolbar.add(audioEnabled, action: { [weak self] sender in
                guard let self = self else {return}
                
                if let muteAudio = self.session?.localMediaStream.audioTrack.isEnabled {
                    self.session?.localMediaStream.audioTrack.isEnabled = !muteAudio
                }
            })
            
            CallKitManager.instance.onMicrophoneMuteAction = { [weak self] in
                guard let self = self else {return}
                self.audioEnabled.pressed = !self.audioEnabled.pressed
            }
            
            toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
                self?.session?.hangUp(["hangup": "hang up"])
            })
        }
        
        toolbar.updateItems()
        
        let mask: UIView.AutoresizingMask = [.flexibleWidth,
                                             .flexibleHeight,
                                             .flexibleLeftMargin,
                                             .flexibleRightMargin,
                                             .flexibleTopMargin,
                                             .flexibleBottomMargin]
        
        // stats view
        statsView.frame = view.bounds
        statsView.autoresizingMask = mask
        statsView.isHidden = true
        statsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateStatsState)))
        view.addSubview(statsView)
        
        // add button to enable stats view
        state = .connecting
    }
    
    @IBAction private func btnSpeakerClicked(_ btnSender: UIButton) {
        
        if(btnSender.tag == 0) {//Selected
            btnSender.tag = 1
            btnSender.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnSender.tintColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        }
        else {//Un selected
            btnSender.tag = 0
            btnSender.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1).withAlphaComponent(0.2)
            btnSender.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
        let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
        QBRTCAudioSession.instance().currentAudioDevice = device
    }
    
    @IBAction private func btnMuteAudioClicked(_ btnSender: UIButton) {
        
        if(btnSender.tag == 0) {//Selected
            btnSender.tag = 1
            btnSender.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            btnSender.tintColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        }
        else {//Un selected
            btnSender.tag = 0
            btnSender.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1).withAlphaComponent(0.2)
            btnSender.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if let muteAudio = self.session?.localMediaStream.audioTrack.isEnabled {
            self.session?.localMediaStream.audioTrack.isEnabled = !muteAudio
        }
    }
    
    @IBAction private func btnCallButtonClicked(_ btnSender: UIButton) {
        self.session?.hangUp(["hangup": "hang up"])
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.reloadContent()
        })
    }
    
    // MARK: - Actions
    func startCall() {
        //Begin play calling sound
        beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                         target: self,
                                         selector: #selector(playCallingSound(_:)),
                                         userInfo: nil, repeats: true)
        playCallingSound(nil)
        //Start call
        let userInfo = ["name": "Test", "url": "http.quickblox.com", "param": "\"1,2,3,4\""]
        
        session?.startCall(userInfo)
    }
    
    func acceptCall() {
        SoundProvider.stopSound()
        //Accept call
        let userInfo = ["acceptCall": "userInfo"]
        session?.acceptCall(userInfo)
    }
    
    private func closeCall() {
        
        CallKitManager.instance.endCall(with: callUUID)
        cameraCapture?.stopSession(nil)
        
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isInitialized == true,
            audioSession.audioSessionIsActivatedOutside(AVAudioSession.sharedInstance()) == false {
            debugPrint("[CallViewController] Deinitializing QBRTCAudioSession.")
            audioSession.deinitialize()
        }
        
        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if let callTimer = callTimer {
            callTimer.invalidate()
            self.callTimer = nil
        }
        
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.toolbar.alpha = 0.4
        }
        state = .disconnected
        QBRTCClient.instance().remove(self as QBRTCClientDelegate)
        QBRTCAudioSession.instance().removeDelegate(self)
        
        self.lblStatus.text = "\(string(withTimeDuration: timeDuration))"
        
        callEndDelegate?.endCallWithDurationInSecond("\(string(withTimeDuration:timeDuration))", receiverId: otherUserId)
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @objc func updateStatsView() {
        shouldGetStats = !shouldGetStats
        statsView.isHidden = !statsView.isHidden
    }
    
    @objc func updateStatsState() {
        updateStatsView()
    }
    
    //MARK: - Internal Methods
    private func zoomUser(userID: UInt) {
        statsUserID = userID
        reloadContent()
        navigationItem.rightBarButtonItem = statsItem
    }
    
    private func unzoomUser() {
        statsUserID = nil
        reloadContent()
        navigationItem.rightBarButtonItem = nil
    }
    
    private func userView(userID: UInt) -> UIView? {
        
        let profile = Profile()
        
        if profile.isFull == true, profile.ID == userID,
            session?.conferenceType != .audio {
            
            if cameraCapture?.hasStarted == false {
                cameraCapture?.startSession(nil)
                session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            }
            //Local preview
            if let result = videoViews[userID] as? LocalVideoView {
                return result
            } else if let previewLayer = cameraCapture?.previewLayer {
                let localVideoView = LocalVideoView(previewlayer: previewLayer)
                videoViews[userID] = localVideoView
                localVideoView.delegate = self
                self.localVideoView = localVideoView
                
                return localVideoView
            }
            
        } else if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            
            if let result = videoViews[userID] as? QBRTCRemoteVideoView {
                result.setVideoTrack(remoteVideoTraсk)
                return result
            } else {
                //Opponents
                let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                videoViews[userID] = remoteVideoView
                remoteVideoView.setVideoTrack(remoteVideoTraсk)
                
                return remoteVideoView
            }
        }
        return nil
    }
    
    private func userCell(userID: UInt) -> UserCell? {
        let indexPath = userIndexPath(userID: userID)
        guard let cell = opponentsCollectionView.cellForItem(at: indexPath) as? UserCell  else {
            return nil
        }
        return cell
    }
    
    private func createConferenceUser(userID: UInt) -> User {
        guard let usersDataSource = self.usersDataSource,
            let user = usersDataSource.user(withID: userID) else {
                let user = QBUUser()
                user.id = userID
                return User(user: user)
        }
        return User(user: user)
    }
    
    private func userIndexPath(userID: UInt) -> IndexPath {
        guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
            return IndexPath(row: 0, section: 0)
        }
        return IndexPath(row: index, section: 0)
    }
    
    func reloadContent() {
        videoViews.values.forEach{ $0.removeFromSuperview() }
        opponentsCollectionView.reloadData()
    }
    
    // MARK: - Helpers
    private func cancelCallAlertWith(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.closeCall()
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    // MARK: - Timers actions
    @objc func playCallingSound(_ sender: Any?) {
        SoundProvider.playSound(type: .calling)
    }
    
    @objc func refreshCallTime(_ sender: Timer?) {
        timeDuration += CallConstant.refreshTimeInterval
        self.lblStatus.text = "\(string(withTimeDuration: timeDuration))"
    }
    
    func string(withTimeDuration timeDuration: TimeInterval) -> String {
        let hours = Int(timeDuration / 3600)
        let minutes = Int(timeDuration / 60)
        let seconds = Int(timeDuration) % 60
        
        var timeStr = ""
        if hours > 0 {
            let minutes = Int((timeDuration - Double(3600 * hours)) / 60);
            timeStr = "\(hours):\(minutes):\(seconds)"
        } else {
            if (seconds < 10) {
                timeStr = "\(minutes):0\(seconds)"
            } else {
                timeStr = "\(minutes):\(seconds)"
            }
        }
        return timeStr
    }
}

extension CallViewController: LocalVideoViewDelegate {
    // MARK: LocalVideoViewDelegate
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
        guard let cameraCapture = self.cameraCapture else {
            return
        }
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        let animation = CATransition()
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight
        
        localVideoView.superview?.layer.add(animation, forKey: nil)
        cameraCapture.position = newPosition
    }
}

extension CallViewController: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        let isSpeaker = updatedAudioDevice == .speaker
        dynamicButton.pressed = isSpeaker
    }
}

// MARK: QBRTCClientDelegate
extension CallViewController: QBRTCClientDelegate {
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        guard session == self.session else {
            return
        }
        if session.opponentsIDs.count == 1, session.initiatorID == userID {
            closeCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard let session = session as? QBRTCSession,
            session == self.session,
            let user = users.filter({ $0.userID == userID.uintValue }).first else {
                return
        }
        
        if user.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate
            
            let userIndexPath = self.userIndexPath(userID: user.userID)
        }

        guard let selectedUserID = statsUserID,
            selectedUserID == userID.uintValue,
            shouldGetStats == true else {
                return
        }
        let result = report.statsString()
        statsView.updateStats(result)
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        if session != self.session {
            return
        }
        // remove user from the collection
        if statsUserID == userID.uintValue {
            unzoomUser()
        }
        
        guard let index = users.index(where: { $0.userID == userID.uintValue }) else {
            return
        }
        let user = users[index]
        if user.connectionState == .connected {
            return
        }
        
        user.bitrate = 0.0
        
        if let videoView = videoViews[userID.uintValue] as? QBRTCRemoteVideoView {
            videoView.removeFromSuperview()
            videoViews.removeValue(forKey: userID.uintValue)
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoViews[userID.uintValue] = remoteVideoView
        }
        reloadContent()
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        if session != self.session {
            return
        }
        
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            let user = users[index]
            user.connectionState = state
            let userIndexPath = self.userIndexPath(userID:userID.uintValue)
            
        } else {
            let user = createConferenceUser(userID: userID.uintValue)
            user.connectionState = state
            
            if user.connectionState == .connected {
                self.users.insert(user, at: 0)
                reloadContent()
                //JENi
            }
        }
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        if session != self.session {
            return
        }
        reloadContent()
    }
    
    /**
     *  Called in case when connection is established with opponent
     */
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        if session != self.session {
            return
        }

        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if callTimer == nil {
            let profile = Profile()
            if profile.isFull == true,
                self.session?.initiatorID.uintValue == profile.ID {
                CallKitManager.instance.updateCall(with: callUUID, connectedAt: Date())
            }
            
            callTimer = Timer.scheduledTimer(timeInterval: CallConstant.refreshTimeInterval,
                                             target: self,
                                             selector: #selector(refreshCallTime(_:)),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            closeCall()
        }
    }
}

//extension CallViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
//    }
//
//}

extension CallViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if session?.conferenceType == QBRTCConferenceType.audio {
            return users.count
        } else {
            return statsUserID != nil ? 1 : users.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstant.opponentCollectionViewCellIdentifier, for: indexPath) as? UserCell else {
            return UICollectionViewCell()
        }
        
        var index = indexPath.row
        
        if session?.conferenceType == QBRTCConferenceType.video {
            if let selectedUserID = statsUserID {
                let selectedIndexPath = userIndexPath(userID: selectedUserID)
                index = selectedIndexPath.row
            }
        }
        
        let user = users[index]
        let userID = NSNumber(value: user.userID)
        
        if let audioTrack = session?.remoteAudioTrack(withUserID: userID) {
            cell.muteButton.isSelected = !audioTrack.isEnabled
        }
        
        cell.didPressMuteButton = { [weak self] isMuted in
            let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
            audioTrack?.isEnabled = !isMuted
        }

        //JENI
        cell.videoView = userView(userID: user.userID)
        
        guard let currentUser = QBSession.current.currentUser, user.userID != currentUser.id else {
            return cell
        }
                
        return cell
    }
}

extension CallViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let user = users[indexPath.row]

        guard let currentUserID = session?.currentUserID,
            user.userID != currentUserID.uintValue else {
                return
        }
        guard let session = session else {
            return
        }
        
        if session.conferenceType == QBRTCConferenceType.audio {
            statsUserID = user.userID
            updateStatsView()
        }
        else {
        
            if statsUserID == nil {
                if user.connectionState == .connected {
                    zoomUser(userID: user.userID)
                }
            }
            else {
                unzoomUser()
            }
        }
    }
}
