//
//  AdSettingViewController.swift
//  SampleApp3
//
//  Created by Kangaroo on 2021/05/26.
//

import UIKit

class AdSettingViewController: UIViewController {

  private let userDefaults = UserDefaults.standard

  private var pickerArray: [String] = ["a", "b"];

  var dataDatelage: DataDelegate?

  @IBOutlet
  weak var companionWidthTextField: UITextField!

  @IBOutlet
  weak var companionHeightTextField: UITextField!
  
  @IBOutlet
  weak var bundleIdTextField: UITextField!

  @IBOutlet
  weak var productTypeTextField: UITextField!

  @IBOutlet
  weak var episodeCodeTextField: UITextField!

  @IBOutlet
  weak var fillTypeTextField: UITextField!

  @IBOutlet
  weak var channelNameTextField: UITextField!

  @IBOutlet
  weak var durationTextField: UITextField!

  @IBOutlet
  weak var episodeNameTextField: UITextField!

  @IBOutlet
  weak var adPositionTextField: UITextField!

  @IBOutlet
  weak var creatorIdentifierTextField: UITextField!

  @IBOutlet
  weak var creatorNameTextField: UITextField!

  @IBOutlet
  weak var adRequestDelayTextField: UITextField!

  @IBOutlet
  weak var albumJacketURLTextField: UITextField!
    
    override func viewDidLoad() {
    super.viewDidLoad()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

    companionWidthTextField.text = userDefaults.string(forKey: "set_field_1") ?? "1"
    companionHeightTextField.text = userDefaults.string(forKey: "set_field_2") ?? "1"
    bundleIdTextField.text = userDefaults.string(forKey: "set_field_3") ?? "com.queen.sampleapp.ios"
    productTypeTextField.text = userDefaults.string(forKey: "set_field_4") ?? "dilo_plus_only"
    episodeCodeTextField.text = userDefaults.string(forKey: "set_field_5") ?? "test_live"
    fillTypeTextField.text = userDefaults.string(forKey: "set_field_6") ?? "single_any"
    channelNameTextField.text = userDefaults.string(forKey: "set_field_7") ?? ""
    durationTextField.text = userDefaults.string(forKey: "set_field_8") ?? "6"
    episodeNameTextField.text = userDefaults.string(forKey: "set_field_9") ?? ""
    adPositionTextField.text = userDefaults.string(forKey: "set_field_10") ?? "pre"
    creatorIdentifierTextField.text = userDefaults.string(forKey: "set_field_11") ?? ""
    creatorNameTextField.text = userDefaults.string(forKey: "set_field_12") ?? ""
    adRequestDelayTextField.text = userDefaults.string(forKey: "set_field_13") ?? "0"
     albumJacketURLTextField.text = userDefaults.string(forKey: "set_field_14") ?? ""
      
  }

  override func viewDidDisappear(_ animated: Bool) {
    dataDatelage?.onData("refresh")
  }

  @objc func dismissKeyboard(_ sender: Any) {
    view.endEditing(true)
  }

  @IBAction
  func onSettingTextFieldEditEnd(_ sender: UITextField) {
    userDefaults.set(sender.text, forKey: "set_field_\(sender.tag)")
  }

}

