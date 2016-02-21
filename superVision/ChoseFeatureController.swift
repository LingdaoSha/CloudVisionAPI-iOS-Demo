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

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)!
    if cell.accessoryType == .None {
      selectedFeatures.append((cell.textLabel?.text)!)
      cell.accessoryType = .Checkmark
    } else {
      for (i, el) in selectedFeatures.enumerate() {
        if el == (cell.textLabel?.text)! {
          selectedFeatures.removeAtIndex(i)
        }
      }
      cell.accessoryType = .None
    }
    navigationItem.rightBarButtonItem?.enabled = !selectedFeatures.isEmpty
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if let data = UIImageJPEGRepresentation(scaledImage, 0.8) {
      let b64String = data.base64EncodedStringWithOptions([])
      if let resultsVC = segue.destinationViewController as? ResultsController {
        resultsVC.b64String = b64String
        resultsVC.features = selectedFeatures
      }
    }
  }
}
