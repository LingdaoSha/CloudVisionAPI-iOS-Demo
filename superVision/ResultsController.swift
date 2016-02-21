//
//  ResultsController.swift
//  superVision
//
//  Created by Артур Антонов on 20/02/16.
//  Copyright © 2016 Артур Антонов. All rights reserved.
//

import UIKit

class ResultsController: UIViewController {

  //TODO: Set your own API key
  let apiKey = "YOUR_API_KEY"
  
  var b64String: String!
  var features: [String]!
  
  var result: [String: JSON]!
  var resultFeatures: [String]?
  
  var points: [CGPoint]!
  
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewDidAppear(animated: Bool) {
    let task = NSURLSession.sharedSession().dataTaskWithRequest(makeRequest()) { (data, response, err) in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      guard err == nil else {
        dispatch_async(dispatch_get_main_queue()) {
          self.showErrorAlert()
        }
        return
      }
      if let data = data, json = JSON(data: data)["responses"][0].dictionary {
        guard json["error"] == nil else { self.showErrorAlert(); return }
        self.result = json
        self.resultFeatures = Array(json.keys)
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          self.showErrorAlert()
        }
      }
    }
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    task.resume()
  }
  
  
  func makeRequest() -> NSURLRequest {
    var featuresWithMaxResults = [[String:String]]()
    for feature in features {
      let feaWithRes = ["type": feature, "maxResults": "32"]
      featuresWithMaxResults.append(feaWithRes)
    }
    let json = ["requests": [[
      "image": ["content": b64String],
      "features": featuresWithMaxResults
    ]]]
    let request = NSMutableURLRequest(URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!)
    request.HTTPMethod = "POST"
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request
  }
  
  func showErrorAlert() {
    let alertController = UIAlertController(title: "Error", message: "Something went wrong 😔", preferredStyle: .Alert);
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil);
    alertController.addAction(okAction);
    self.presentViewController(alertController, animated: true, completion: nil);
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let detailVC = segue.destinationViewController as! DetailVC
    detailVC.points = points
    detailVC.b64str = b64String
  }
}


extension ResultsController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    guard let number = resultFeatures?.count else { return 0 }
    return number
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return resultFeatures?[section]
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let key = resultFeatures![section]
    if key == "safeSearchAnnotation" {
      return 1
    }
    return result[key]?.arrayValue.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let key = resultFeatures![indexPath.section]
    var dict: [String: JSON]
    if key == "safeSearchAnnotation" {
      dict = result[key]!.dictionaryValue
    } else {
      let annotations = result[key]!.arrayValue
      dict = annotations[indexPath.row].dictionaryValue
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LabelCell
    cell.label.text = jsonToString(dict)
    return cell
  }
  
  func jsonToString(dict: [String: JSON]) -> String {
    var res = ""
    for key in Array(dict.keys) {
      if let strValue = dict[key]?.string {
        res += "\(key): \(strValue)\n"
      } else if let floatValue = dict[key]?.float {
        res += "\(key): \(floatValue)\n"
      }
    }
    res.removeAtIndex(res.endIndex.predecessor())
    return res
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let key = resultFeatures![indexPath.section]
    guard key != "safeSearchAnnotation" else { return }
    let annotations = result[key]!.arrayValue
    if let jsonPoints = annotations[indexPath.row]["boundingPoly"]["vertices"].array {
      guard jsonPoints.count > 1 else { return }
      points = [CGPoint]()
      for point in jsonPoints {
        points.append(CGPoint(x:point["x"].doubleValue, y:point["y"].doubleValue))
      }
      performSegueWithIdentifier("showBounds", sender: nil)
    }
  }
}