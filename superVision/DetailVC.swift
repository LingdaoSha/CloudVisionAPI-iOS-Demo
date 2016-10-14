//
//  DetailVC.swift
//  superVision
//
//  Created by Артур Антонов on 02/02/16.
//  Copyright © 2016 Артур Антонов. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  
  var b64str: String!
  var points: [CGPoint]!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let imageData = Data(base64Encoded: b64str, options: []),
           let image = UIImage(data: imageData) {
      imageView.image = image
    }
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    let image = imageView.image!
    let aspectRatioX = imageView.frame.width/image.size.width;
    let aspectRatioY = imageView.frame.height/image.size.height;
    var imageRect: CGRect
    if aspectRatioX < aspectRatioY {
      imageRect = CGRect(x: 0, y: (imageView.bounds.height - aspectRatioX*image.size.height)*0.5,
                     width: imageView.bounds.width, height: aspectRatioX*image.size.height)
    } else {
      imageRect = CGRect(x: (imageView.bounds.width - aspectRatioY*image.size.width)*0.5, y: 0,
                     width: aspectRatioY*image.size.width, height: imageView.bounds.height)
    }
    
    let bezPath = UIBezierPath()
    bezPath.move(to: CGPoint(x: points[0].x*imageRect.width/image.size.width, y: points[0].y*imageRect.height/image.size.height))
    for i in 1..<points.count {
      bezPath.addLine(to: CGPoint(x: points[i].x*imageRect.width/image.size.width,
                                     y: points[i].y*imageRect.height/image.size.height))
    }
    bezPath.close()
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame = imageRect
    shapeLayer.path = bezPath.cgPath
    shapeLayer.lineWidth = 1.5
    shapeLayer.strokeColor = UIColor.red.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    imageView.layer.addSublayer(shapeLayer)
  }
}
