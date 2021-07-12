//
//  GroupCallingView.swift
//  one-to-many-call
//
//  Created by usama farooq on 15/06/2021.
//

import UIKit
import iOSSDKStreaming

protocol VideoDelegate: class {
    func didTapVideo(for baseSession: VTokBaseSession, state: VideoState)
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState)
    func didTapEnd(for baseSession: VTokBaseSession)
    func didTapFlip(for baseSession: VTokBaseSession, type: CameraType)
    func didTapSpeaker(baseSession: VTokBaseSession, state: SpeakerState)
}



class GroupCallingView: UIView {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var localView: UIView! {
        didSet {
            localView.clipsToBounds = true
            localView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var cameraSwitch: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var callTime: UILabel!
    @IBOutlet weak var connectedView: UIView!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var tryingStack: UIStackView!
    @IBOutlet weak var userNames: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var hangupButton: UIButton!
    var users:[User]?
    weak var delegate: VideoDelegate?
    var session: VTokBaseSession?
    private var counter: Int = 0
    private weak var timer: Timer?

    var userStreams: [UserStream]  = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
        connectedView.isHidden = true
        callStatus.isHidden = true
        localView.frame = CGRect(x: UIScreen.main.bounds.size.width - localView.frame.size.width + 1.1, y: UIScreen.main.bounds.size.height - localView.frame.size.height * 1.1, width: 120, height: 170)
        
    }
    
    @IBAction func didTapSpeaker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return }
        delegate?.didTapSpeaker(baseSession: session , state: sender.isSelected ? .onSpeaker : .onEarPiece)
    }
    
    @IBAction func didTapMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else { return }
        delegate?.didTapMute(for: session, state: sender.isSelected ? .mute : .unMute)
    }
    
    @IBAction func didTapCameraSwitch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else { return }
        delegate?.didTapFlip(for: session, type: sender.isSelected ? .front : .rear)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return }
        localView.isHidden = sender.isSelected ? true : false
        cameraSwitch.isEnabled = sender.isSelected ? false : true
        delegate?.didTapVideo(for: session, state: sender.isSelected ? .videoDisabled :.videoEnabled )
    }
    
    @IBAction func didTapHangup(_ sender: UIButton) {
        guard let session = session else { return }
        delegate?.didTapEnd(for: session)
    }
    
    func updateWith(baseSession: VTokBaseSession) {
        self.session = baseSession
    }
    
    func updateAudioVideoview(for session: VTokBaseSession) {
        
        self.session = session
      
        switch session.sessionMediaType {
        case .audioCall:
            titleLable.text = "You are audio calling with"
            localView.isHidden = true
            cameraSwitch.isHidden = true
            cameraButton.isHidden = true
        case .videoCall:
            titleLable.text = "You are video calling with"
            localView.isHidden = false
            cameraSwitch.isHidden = false
            cameraButton.isHidden = false
        }
    }
    
    func configureLocal(view: UIView) {
        for subView in localView.subviews {
            subView.removeFromSuperview()
        }
        localView.addSubview(view)
       
    }
    
    func updateView(for session: VTokBaseSession) {
      
        callStatus.isHidden = false
        tryingStack.isHidden = false
        speakerButton.isHidden = true
        self.session = session
        switch session.state {
        case .calling:
            callStatus.text = "Calling.."
            cameraSwitch.isHidden = true
            speakerButton.isHidden = true
            cameraButton.isEnabled = false
            setNames()
        case .ringing:
            cameraSwitch.isHidden = true
            speakerButton.isHidden = true
            callStatus.text = "Ringing.."
            cameraButton.isEnabled = false
            setNames()
        case .connected:
            connectedState()
        case .rejected:
            callStatus.text = "Rejected"
            
        default:
            break
        }
    }
    
    private func setNames() {
        let tempUser = users?.filter({session?.to.contains($0.refID) ?? false})
        let names = tempUser?.map({$0.fullName}).joined(separator: "\n")
        userNames.text = names
    }
    
    private func connectedState() {
        userAvatar.isHidden = true
        callStatus.isHidden = true
        connectedView.isHidden = false
        tryingStack.isHidden = true
        speakerButton.isHidden = false
        cameraSwitch.isHidden = false
        speakerButton.isHidden = false
        configureTimer()
    }
    
    func loadViewFor(mediaType: SessionMediaType) {
        
        switch mediaType {
        case .audioCall:
            localView.isHidden = true
            cameraSwitch.isHidden = true
            cameraButton.isEnabled = false
            speakerButton.isSelected = false
            
        case .videoCall:
            localView.isHidden = false
            cameraSwitch.isHidden = false
            cameraButton.isEnabled = false
            speakerButton.isSelected = true
//        case .screenshare:
//            break
        }
        
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    static func getView() -> GroupCallingView {
        let viewsArray = Bundle.main.loadNibNamed("GroupCallingView", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else{
                let view = viewsArray?.firstObject as! GroupCallingView
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
        return GroupCallingView()
    }
    
    func updateDataSource(with streams: [UserStream]) {
        userStreams = streams
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            self?.cameraButton.isEnabled = true
        })
        
    }

}

extension GroupCallingView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.configure(with: userStreams[indexPath.row], users: users)
        
    
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension GroupCallingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize(index: indexPath.row)
    }
}


//MARK:- CollectionViewCell Dynamic Cell Size
extension GroupCallingView {
    
    func getCellSize(index: Int) -> CGSize {
        
        let cellWidth: CGFloat = getRowWidth(index: index)
        let cellHeight: CGFloat = getRowHeight()
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    private func getRowWidth(index: Int) -> CGFloat {
        
        let width = self.collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        let cellWidth: CGFloat
        
        // Max width of the cell can be half of the width of collectionView
        // For one/two cell(s) width should be equal to width of collectionView
        // For odd numbers of cells width of the last cell will be equal to the width of collectionView and width of all others cells will be equal to the half of the width of collectionView
        // For even number of all cells width will be equal to the half of the width of collectionView
        if userStreams.count == 1 || userStreams.count == 2 {
            cellWidth = width
        } else if userStreams.count % 2 == 0 {
            cellWidth = width/2
        } else if userStreams.count == index + 1 {
            cellWidth = width
        } else {
            cellWidth = width/2
        }
        
        return cellWidth
    }
    
    private func getRowHeight() -> CGFloat {
        let extraNumber: CGFloat = 0
        let height = collectionView.bounds.size.height
        let rowHeight: CGFloat
        
        // Added in version 1.0
        // Added in build 1
        // Height of cell will be equal to the height of collectionView in case of single cell. Height of cell will be equal to the half of the height of collectionView in case of more than one cell
        if userStreams.count == 1 {
            rowHeight = height - extraNumber
        } else {
            rowHeight = (height - extraNumber) / 2
        }
            
        return rowHeight
    }
}


extension GroupCallingView {
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
      // 1
      let translation = gesture.translation(in: localView)

      // 2
      guard let gestureView = gesture.view else {
        return
      }

      gestureView.center = CGPoint(
        x: gestureView.center.x + translation.x,
        y: gestureView.center.y + translation.y
      )

      // 3
      gesture.setTranslation(.zero, in: localView)
        
        guard gesture.state == .ended else {
          return
        }

        // 1
        let velocity = gesture.velocity(in: localView)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200

        // 2
        let slideFactor = 0.1 * slideMultiplier
        // 3
        var finalPoint = CGPoint(
            x: gestureView.center.x + (velocity.x * slideFactor),
          y: gestureView.center.y + (velocity.y * slideFactor)
        )

        // 4
        finalPoint.x = min(max(finalPoint.x, 0), localView.bounds.width)
        finalPoint.y = min(max(finalPoint.y, 0), localView.bounds.height)
        let screenSize = self.bounds
          let constraints = self.getValidConstraints(for: gestureView)
        let point = CGPoint(x: screenSize.width - constraints.trailing - 65, y: screenSize.height - constraints.bottom - 85)
        
        // 5
        UIView.animate(
            withDuration: 0.1,
          delay: 0,
          options: .curveEaseOut,
          animations: {
            gestureView.center = point
          })
    }
    
    private func getValidConstraints(for view: UIView) -> (trailing: CGFloat, bottom: CGFloat) {
        let currentPoint = view.frame.origin
        print(currentPoint)
        let screenSize = self.bounds
        let viewSize = view.bounds
        let constraint: CGFloat = 20
        let constraints: (leading: CGFloat, trailing: CGFloat, top: CGFloat, bottom: CGFloat) = (constraint, constraint + localView.bounds.width, constraint, constraint + localView.bounds.height)
        let bottom: CGFloat
        let trailing: CGFloat
        if currentPoint.x < constraints.leading {
            trailing = screenSize.width - (constraints.leading + viewSize.width)
        } else if currentPoint.x > screenSize.width - constraints.trailing {
            trailing = 20
        } else {
            trailing = screenSize.width - (currentPoint.x + viewSize.width)
        }
        
        if currentPoint.y < constraints.top {
            bottom = screenSize.height - (constraints.top + viewSize.height)
        } else if currentPoint.y > (screenSize.height - constraints.bottom) {
            bottom = 20
        } else {
            bottom = screenSize.height - (currentPoint.y + viewSize.height)
        }
        
        return (trailing, bottom)
    }
}

extension GroupCallingView {
    private func configureTimer() {
        timer?.invalidate()
        timer = nil
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func timerAction() {
        counter += 1
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: counter)
        var timeString = ""
        if h > 0 {
            timeString += intervalFormatter(interval: h) + ":"
        }
        timeString += intervalFormatter(interval: m) + ":" +
                        intervalFormatter(interval: s)
        callTime.text = timeString
    }
    
    private func intervalFormatter(interval: Int) -> String {
        if interval < 10 {
            return "0\(interval)"
        }
        return "\(interval)"
    }
    
    private func secondsToHoursMinutesSeconds (seconds :Int) -> (hours: Int, minutes: Int, seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

extension GroupCallingView {
    func handleHanup(status: Bool) {
        hangupButton.isEnabled = status
    }
}
