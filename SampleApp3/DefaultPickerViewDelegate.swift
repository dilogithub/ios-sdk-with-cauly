//
//  DefaultPickerViewDelegate.swift
//  SampleApp3
//
//  Created by Kangaroo on 2021/05/26.
//

import UIKit

class DefaultPickerViewDelegate: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }


  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 1
  }


  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return ""
  }


  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

  }


}
