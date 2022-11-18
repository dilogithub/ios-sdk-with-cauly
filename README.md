# ios-sdk-with-cauly

* 본 가이드는 Dilo SDK와 카울리 SDK를 모두 사용하는 사용자의 이해를 돕기 위하여 작성되었습니다.

* 샘플앱은 Dilo 광고가 없거나 Dilo SDK 오류 발생 시 카울리 SDK를 통하여 전면 광고를 동작시키도록 구현되었습니다.

* 최신 버전의 SDK 사용을 권장합니다

* Dilo SDK 관련 자세한 사항은 [딜로 SDK 가이드](https://github.com/dilogithub/ios-sdk)를 확인해 주세요.

* 카울리 SDK 관련 자세한 사항은 [카울리 SDK 가이드](https://github.com/cauly/iOS-SDK)를 확인해 주세요.

* 이해를 돕기 위하여 카울리 SDK는 샘플앱에 포함되어 있습니다. Dilo/카울리 SDK 적용을 위하여 위 가이드를 참고해 주세요,
  
>  
>  테스트 방법
>  1. Dilo SDK 동작 테스트 : 샘플앱 실행 후 광고요청 버튼을 누릅니다.
>  2. 카울리 SDK 동작 테스트 : 샘플앱 실행 후 설정버튼을 누릅니다.
>     + 딜로광고가 없는상황(no-fill)을 만들기 위하여  설정버튼 클릭 후 bundle id항목에 임의의값을 설정 합니다. (eg. com.nofill.app)
>     + 설정창을 아래로 드래그 해서 닫고 광고요청 버튼을 누릅니다.

---

Dilo 광고요청 no-fill/error 응답 시 카울리 SDK 호출 지점 (SWIFT)
===
```swift
  // Dilo SDK Error Call back.
  adManager.onError { (errMessage: String) in
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "광고 요청/실행중 오류가 발생했습니다", message: errMessage, preferredStyle: .alert)
      let action = UIAlertAction(title: "확인", style: .default)

      alert.addAction(action)

      self.present(alert, animated: true, completion: nil)

    }

    // 카울리 SDK 호출
    DispatchQueue.main.async {
        self.loadCaulySdk()
    }

  }

  // Dilo SDK Error Call back.
  adManager.onNoFill {
    DispatchQueue.main.async {
      self.log("[NO FILL]");
    }

    // 카울리 SDK 호출  
    DispatchQueue.main.async {
        self.loadCaulySdk()
    }

  }
```
---

카울리 SDK 관련 코드 (SWIFT)
===
```swift

  var _interstitialAd:CaulyInterstitialAd? = nil
  
  // 딜로 SDK nofill/error 시 카울리광고 설정에 따른 광고호출
  func loadCaulySdk() {
      log("load cauly interstitial ad.")
      loadCaulyInterstitial()
  }

  // 광고 요청.
  func loadCaulyInterstitial() {

      initCaulyInterstitialSetting()

      self._interstitialAd = CaulyInterstitialAd.init()
      _interstitialAd?.delegate = self;    //  전면 delegate 설정
      _interstitialAd?.startRequest();     //  전면광고 요청
  }

  // 광고설정 (상세 광고설정은 카울리 SDK 가이드를 참조해 주세요.)
  func initCaulyInterstitialSetting() {
      let caulySetting = CaulyAdSetting.global();
      CaulyAdSetting.setLogLevel(CaulyLogLevelDebug)  //  Cauly Log 레벨
      caulySetting?.appId = "CAULY"                   //  App Store 에 등록된 App ID 정보 (필수)
      caulySetting?.appCode = "0d2VuoZV"              //  테스트용 Cauly AppCode. (운영환경 반영 시 카울리에서 발급을 받습니다.) 
      caulySetting?.closeOnLanding = true             //  app으로 이동할 때 webview popup창을 자동으로 닫아줍니다. 기본값은 false입니다.
  }

  // [CallBack] 카울리 광고 정보 수신 성공
  func didReceive(_ interstitialAd: CaulyInterstitialAd!, isChargeableAd: Bool) {
      NSLog("Recevie intersitial");
      _interstitialAd?.show(withParentViewController: self)
  }
  // [CallBack] 카울리 광고 정보 수신 실패
  func didFail(toReceive interstitialAd: CaulyInterstitialAd!, errorCode: Int32, errorMsg: String!) {
      print("Recevie fail intersitial errorCode:\(errorCode) errorMsg:\(errorMsg!)");
      _interstitialAd = nil
  }

  // [CallBack] 카울리 광고가 보여지기 직전
  func willShow(_ interstitialAd: CaulyInterstitialAd!) {
      log("willShow")
  }

  // [CallBack] 카울리 광고의 닫기버튼 클릭 시
  func didClose(_ interstitialAd: CaulyInterstitialAd!) {
      log("didClose")
      _interstitialAd=nil
  }
```
---
