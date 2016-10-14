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
  
  override func viewDidAppear(_ animated: Bool) {
    let task = URLSession.shared.dataTask(with: makeRequest(), completionHandler: { (data, response, err) in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      guard err == nil else {
        DispatchQueue.main.async {
          self.showErrorAlert()
        }
        return
      }
      if let data = data, let json = JSON(data: data)["responses"][0].dictionary {
        guard json["error"] == nil else { self.showErrorAlert(); return }
        self.result = json
        self.resultFeatures = Array(json.keys)
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      } else {
        DispatchQueue.main.async {
          self.showErrorAlert()
        }
      }
    }) 
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    task.resume()
  }
  
  
  func makeRequest() -> URLRequest {
    var featuresWithMaxResults = [[String:String]]()
    for feature in features {
      let feaWithRes = ["type": feature, "maxResults": "32"]
      featuresWithMaxResults.append(feaWithRes)
    }
    let json = ["requests": [[
                "image": ["content": "\(b64String ?? "")"],
                "features": featuresWithMaxResults]]
               ]
    let request = NSMutableURLRequest(url: URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!)
    request.httpMethod = "POST"
    if JSONSerialization.isValidJSONObject(json) {
        request.httpBody = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request as URLRequest
  }
  
  func showErrorAlert() {
    let alertController = UIAlertController(title: "Error", message: "Something went wrong 😔", preferredStyle: .alert);
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
    alertController.addAction(okAction);
    self.present(alertController, animated: true, completion: nil);
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let detailVC = segue.destination as! DetailVC
    detailVC.points = points
    detailVC.b64str = b64String
  }
}


extension ResultsController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let number = resultFeatures?.count else { return 0 }
    return number
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return resultFeatures?[section]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let key = resultFeatures![section]
    if key == "safeSearchAnnotation" {
      return 1
    }
    return result[key]?.arrayValue.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let key = resultFeatures![(indexPath as NSIndexPath).section]
    var dict: [String: JSON]
    if key == "safeSearchAnnotation" {
      dict = result[key]!.dictionaryValue
    } else {
      let annotations = result[key]!.arrayValue
      dict = annotations[(indexPath as NSIndexPath).row].dictionaryValue
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LabelCell
    cell.label.text = jsonToString(dict)
    return cell
  }
  
  func jsonToString(_ dict: [String: JSON]) -> String {
    var res = ""
    for key in Array(dict.keys) {
      if let strValue = dict[key]?.string {
        res += "\(key): \(strValue)\n"
      } else if let floatValue = dict[key]?.float {
        res += "\(key): \(floatValue)\n"
      }
    }
    res.remove(at: res.characters.index(before: res.endIndex))
    return res
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let key = resultFeatures![(indexPath as NSIndexPath).section]
    guard key != "safeSearchAnnotation" else { return }
    let annotations = result[key]!.arrayValue
    if let jsonPoints = annotations[(indexPath as NSIndexPath).row]["boundingPoly"]["vertices"].array {
      guard jsonPoints.count > 1 else { return }
      points = [CGPoint]()
      for point in jsonPoints {
        points.append(CGPoint(x:point["x"].doubleValue, y:point["y"].doubleValue))
      }
      performSegue(withIdentifier: "showBounds", sender: nil)
    }
  }
}
