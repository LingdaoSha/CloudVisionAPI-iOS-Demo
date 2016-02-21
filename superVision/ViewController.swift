

import UIKit

class ViewController: UIViewController {
  
  
  @IBOutlet weak var imageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func takePhoto(sender: UIButton) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .Camera
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let choseVC = segue.destinationViewController as? ChoseFeatureController {
      let image = imageView.image!
      //Resize image
      let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.6, 0.6))
      UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
      image.drawInRect(CGRect(origin: CGPointZero, size: size))
      let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      choseVC.scaledImage = scaledImage
    }
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = image
      navigationItem.rightBarButtonItem?.enabled = true
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
}

