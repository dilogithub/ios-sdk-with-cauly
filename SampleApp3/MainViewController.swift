//
//  ViewController.swift
//  SampleApp3
//
//  Created by Kangaroo on 2021/05/26.
//

import UIKit
import MediaPlayer
import DiloSDK

class MainViewController: UIViewController, DataDelegate,
                          CaulyAdViewDelegate,  // for cauly banner
                          CaulyInterstitialAdDelegate   // for cauly interstitial
{

  private let userDefaults = UserDefaults.standard

  private let adManager: AdManager = AdManager.sharedInstance

  @IBOutlet
  weak var companionView: UIView!
   
  @IBOutlet
  weak var companionWidthConstraint: NSLayoutConstraint!

  @IBOutlet
  weak var companionHeightConstraint: NSLayoutConstraint!

  @IBOutlet
  weak var progressView: UIProgressView!

  @IBOutlet
  weak var skipButton: UIButton!

  @IBOutlet
  weak var companionCloseButton: UIButton!

  @IBOutlet
  weak var logTextView: UITextView!

  var companionWidth: String = ""

  var companionHeight: String = ""

  var bundleId: String = ""

  var productType: String = ""

  var episodeCode: String = ""

  var fillType: String = ""

  var channelName: String = ""

  var duration: String = ""

  var episodeName: String = ""

  var adPosition: String = ""

  var creatorIdentifier: String = ""

  var creatorName: String = ""

  var adRequestDelay: Int = 0

  var albumJacketURLStr: String = ""
    
  var currentAd: AdInfo?

  var skipTime: Int = 0
    
  override func viewDidLoad() {
    super.viewDidLoad()

    self.skipButton.isEnabled = false

    setFields()
    setDiloSDK()

    #if DEBUG
    log("DEBUG")
    #elseif UAT
    log("UAT")
    #else
    log("RELEASE")
    #endif
  }

  @IBSegueAction func onAdSettingPresent(_ coder: NSCoder) -> AdSettingViewController? {
    let adSettingController = AdSettingViewController(coder: coder)

    adSettingController?.dataDatelage = self

    return adSettingController
  }

  func onData(_ data: String) {
    setFields()
  }

  func setFields() {
    companionWidth = userDefaults.string(forKey: "set_field_1") ?? "1"
    companionHeight = userDefaults.string(forKey: "set_field_2") ?? "1"
    bundleId = userDefaults.string(forKey: "set_field_3") ?? "com.queen.sampleapp.ios"
    productType = userDefaults.string(forKey: "set_field_4") ?? "dilo_plus_only"
    episodeCode = userDefaults.string(forKey: "set_field_5") ?? "test_live"
    fillType = userDefaults.string(forKey: "set_field_6") ?? "single_any"
    channelName = userDefaults.string(forKey: "set_field_7") ?? ""
    duration = userDefaults.string(forKey: "set_field_8") ?? "6"
    episodeName = userDefaults.string(forKey: "set_field_9") ?? ""
    adPosition = userDefaults.string(forKey: "set_field_10") ?? "pre"
    creatorIdentifier = userDefaults.string(forKey: "set_field_11") ?? ""
    creatorName = userDefaults.string(forKey: "set_field_12") ?? ""
    adRequestDelay = userDefaults.integer(forKey: "set_field_13")

    if adRequestDelay < 0 {
      adRequestDelay = 0
    }

    setAlbumJacket()

    let width = Int(companionWidth) ?? 0
    let height = Int(companionHeight) ?? 0
    var updateFlag = true

    if width < 1 {
      log("Companion Width is less than 1... IGNORE VALUE")
      updateFlag = false
    }

    if height < 1 {
      log("Companion Height is less than 1... IGNORE VALUE")
      updateFlag = false
    }

    if !updateFlag {
      return
    }

    let pWidth = Float(UIScreen.main.bounds.width - 10)
    let pHeight = Float(250)
    let r = Float(width) / Float(height)

    log("width: \(width)")
    log("height: \(height)")

    if r == 1 {
      companionWidthConstraint.constant = CGFloat(pHeight)
      companionHeightConstraint.constant = CGFloat(pHeight)
    } else if r > 1 {
      companionWidthConstraint.constant = CGFloat(pWidth)
      companionHeightConstraint.constant = CGFloat(pHeight / r)
    } else {
      companionWidthConstraint.constant = CGFloat(pWidth * r)
      companionHeightConstraint.constant = CGFloat(pHeight)
    }

    adManager.setCompanionSlot(companionView)
  }

  func setAlbumJacket() {
    albumJacketURLStr = userDefaults.string(forKey: "set_field_14") ?? ""

    if albumJacketURLStr.isEmpty {
      albumJacketURLStr = "https://studio.dilo.co.kr/assets/images/wave_1.png"
    }

    if let url = URL(string: albumJacketURLStr) {
      URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
        if let data = data {
          if let image = UIImage(data:data) {
            let artwork = MPMediaItemArtwork.init(boundsSize: image.size) { _ -> UIImage in
              return image
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
              MPMediaItemPropertyArtwork: artwork
            ]
          } else {
            self.log("No Image found")
          }
        } else {
          self.log("No data...")
        }
      })
      .resume()
    }

  }

  func setDiloSDK() {
    adManager.setCompanionSlot(companionView)
    adManager.setCloseButton(companionCloseButton)

    adManager.onAdReady {
      DispatchQueue.main.async {
        self.log("[AD READY]")
      }
      self.adManager.start()
    }

    adManager.onAdStart { (adInfo: AdInfo) in
      DispatchQueue.main.async {
        self.log("[AD START]")
        self.log("  - adType: \(adInfo.adType)")
        self.log("  - advertiser: \(adInfo.advertiser)")
        self.log("  - title: \(adInfo.title)")
        self.log("  - current: \(adInfo.current)")
        self.log("  - total: \(adInfo.total)")
        self.log("  - duration: \(adInfo.duration)")
        self.log("  - skipTime: \(adInfo.skipTime)")
        self.log("  - hasCompanion: \(adInfo.hasCompanion)")
          self.log("  - creatorIdentifier: \(self.creatorIdentifier)")
          
        self.currentAd = adInfo
      }
    }

    adManager.onTimeUpdate { (progress: DiloSDK.Progress) in
      DispatchQueue.main.async {
        let percentage = progress.seconds / progress.duration

        self.progressView.progress = Float(percentage)

        if let ad = self.currentAd {
          let countdown = Int(ceil(ad.skipTime - progress.seconds))

          if self.skipTime != countdown && countdown > 0 {
            self.skipTime = countdown
            self.log("SKIP :: After \(self.skipTime) seconds");
          }
        }
      }
    }

    adManager.onPause {
      DispatchQueue.main.async {
        self.log("[AD PAUSED]")
      }
    }

    adManager.onResume {
      DispatchQueue.main.async {
        self.log("[AD RESUME]")
      }
    }

    adManager.onAdCompleted {
      DispatchQueue.main.async {
        self.log("[AD COMPLETED]")
        self.skipButton.isEnabled = false
      }
    }

    adManager.onSkipEnabled { _ in
      DispatchQueue.main.async {
        self.log("[SKIP ENABLED]")
        self.skipButton.isEnabled = true
      }
    }

    adManager.onAllAdsCompleted {
      DispatchQueue.main.async {
        self.log("[ALL ADS ARE COMPLETED]")
        self.setAdViewInfoInit()
      }
    }

    adManager.onCompanionClosed {
      DispatchQueue.main.async {
        self.log("[Companion Closed]")
      }
    }

    adManager.onError { (errMessage: String) in
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "광고 요청/실행중 오류가 발생했습니다", message: errMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
          
      }
        
        DispatchQueue.main.async {
            self.loadCaulySdk()
        }
        
    }

    adManager.onNoFill {
      DispatchQueue.main.async {
        self.log("[NO FILL]");
      }
        
        DispatchQueue.main.async {
            self.loadCaulySdk()
        }

    }
  }

  func setAdViewInfoInit() {
    progressView.progress = 0
    skipButton.isEnabled = false
    skipTime = 0
    currentAd = nil
  }

  /*
   광고요청
   */
  @IBAction
  func onAdRequestButtonTouched(_ sender: UIButton) {
    self.log("[AD REQUEST QUEUED]");

    let bundleId = self.bundleId
    let epiCode = self.episodeCode
    let drs = Int(self.duration) ?? 0
    let productType = RequestParam.ProductType.init(rawValue: self.productType) ?? .DILO_PLUS
    let fillType = RequestParam.FillType.init(rawValue: self.fillType) ?? .SINGLE_ANY
    let adPositionType = RequestParam.AdPositionType.init(rawValue: self.adPosition) ?? .PRE

    if bundleId.count == 0 {
      self.log("NO BUNDLE ID")
      return
    }

    if epiCode.count == 0 {
      self.log("NO EPISODE CODE")
      return
    }

    if fillType != .SINGLE_ANY && drs == 0 {
      self.log("Duration is required")
      return
    }

    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
      let startTime = Date()
      let timer = DispatchSource.makeTimerSource()

      timer.schedule(deadline: .now(), repeating: .seconds(1))
      timer.setEventHandler {
        let elapsed = Int(Date().timeIntervalSince(startTime))

        if elapsed < self.adRequestDelay {
          debugPrint("Timer Check :: \(self.adRequestDelay - elapsed)")
          DispatchQueue.main.async {
            self.log("Ad Request Timer :: \(self.adRequestDelay - elapsed)")
          }

          return
        }

        timer.cancel()

        DispatchQueue.main.async {
          self.log("[AD REQUEST INVOKED]")
          self.log("Width: \(self.companionView.frame.width)")
          self.log("Height: \(self.companionView.frame.height)")
        }

        self.setAlbumJacket()

        let requestAdParam = RequestParam(
          bundleId: bundleId,
          epiCode: epiCode,
          chName: self.channelName,
          epName: self.episodeName,
          creatorName: self.creatorName,
          creatorIdentifier: self.creatorIdentifier,
          drs: drs,
          productType: productType,
          fillType: fillType,
          adPositionType: adPositionType
        )

        self.adManager.requestAd(requestAdParam)
      }

      timer.activate()
    }
  }

  /*
   재생/일시중지
   */
  @IBAction
  func onPlayOrPauseButtonTouched(_ sender: UIButton) {
    adManager.playOrPause()
  }

  /*
   광고종료
   */
  @IBAction
  func onAdStopButtonTouched(_ sender: UIButton) {
    self.log("[AD MANAGER IS TERMINATED]")
    adManager.stop()
    setAdViewInfoInit()
  }

  /*
   광고 스킵
   */
  @IBAction
  func onAdSkipButtonTouched(_ sender: UIButton) {
    self.log("[SKIP]")
    if (adManager.skip()) {
      setAdViewInfoInit()
    }
  }

  /*
   컴패니언 리로드
   */
  @IBAction
  func onCompanionReloadButtonTouched(_ sender: UIButton) {
    self.log("[RELOAD COMPANION]")
    adManager.reloadCompanion(companionView)
  }

  func log(_ log: String) {
    logTextView.insertText(log + "\n")
    logTextView.scrollRangeToVisible(NSRange(location: logTextView.text.count - 1, length: 1))
  }

  @objc func timerAction() {
    debugPrint("Timer test")
  }


    // [분기] 딜로 SDK nofill/error 시 카울리광고 설정에 따른 광고호출
    func loadCaulySdk() {
        log("load cauly interstitial ad.")
        loadCaulyInterstitial()
    }
    
    // [start] cauly interstitial
    var _interstitialAd:CaulyInterstitialAd? = nil

    // 광고환경설정
    func initCaulyInterstitialSetting() {
        // 상세 설정 항목들은 하단 표 참조, 설정되지 않은 항목들은 기본값으로 설정됩니다.
        let caulySetting = CaulyAdSetting.global();
        CaulyAdSetting.setLogLevel(CaulyLogLevelDebug)  //  Cauly Log 레벨
        caulySetting?.appId = "CAULY"                 //  App Store 에 등록된 App ID 정보 (필수)
        caulySetting?.appCode = "0d2VuoZV"              //  Cauly AppCode
        caulySetting?.closeOnLanding = true             //  app으로 이동할 때 webview popup창을 자동으로 닫아줍니다. 기본값은 false입니다.
    }

    // 광고 요청.
    func loadCaulyInterstitial() {
        
        initCaulyInterstitialSetting()
        
        self._interstitialAd = CaulyInterstitialAd.init()
        _interstitialAd?.delegate = self;    //  전면 delegate 설정
        _interstitialAd?.startRequest();     //  전면광고 요청
    }

    // [CallBack] 광고 정보 수신 성공
    func didReceive(_ interstitialAd: CaulyInterstitialAd!, isChargeableAd: Bool) {
        NSLog("Recevie intersitial");
        _interstitialAd?.show(withParentViewController: self)
    }
    // [CallBack] 광고 정보 수신 실패
    func didFail(toReceive interstitialAd: CaulyInterstitialAd!, errorCode: Int32, errorMsg: String!) {
        print("Recevie fail intersitial errorCode:\(errorCode) errorMsg:\(errorMsg!)");
        _interstitialAd = nil
    }

    // [CallBack] 광고가 보여지기 직전
    func willShow(_ interstitialAd: CaulyInterstitialAd!) {
        log("willShow")
    }

    // [CallBack] 광고가 닫혔을 때
    func didClose(_ interstitialAd: CaulyInterstitialAd!) {
        log("didClose")
        _interstitialAd=nil
    }
    // [end] cauly interstitial
    
}

