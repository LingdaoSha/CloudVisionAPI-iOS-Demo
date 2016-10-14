//
//  ChoseFeatureController.swift
//  superVision
//
//  Created by Артур Антонов on 20/02/16.
//  Copyright © 2016 Артур Антонов. All rights reserved.
//

import UIKit

class ChoseFeatureController: UITableViewController {
  
  var scaledImage: UIImage!
  
  var selectedFeatures = ["LABEL_DETECTION", "TEXT_DETECTION", "SAFE_SEARCH_DETECTION"]
  
  override func viewDidLoad() {
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)!
    if cell.accessoryType == .none {
      selectedFeatures.append((cell.textLabel?.text)!)
      cell.accessoryType = .checkmark
    } else {
      for (i, el) in selectedFeatures.enumerated() {
        if el == (cell.textLabel?.text)! {
          selectedFeatures.remove(at: i)
        }
      }
      cell.accessoryType = .none
    }
    navigationItem.rightBarButtonItem?.isEnabled = !selectedFeatures.isEmpty
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let data = UIImageJPEGRepresentation(scaledImage, 0.8) {
      let b64String = data.base64EncodedString(options: [])
      if let resultsVC = segue.destination as? ResultsController {
        resultsVC.b64String = b64String
        resultsVC.features = selectedFeatures
      }
    }
  }
}
