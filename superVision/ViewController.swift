

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

  @IBAction func takePhoto(_ sender: UIButton) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .camera
    present(imagePicker, animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let choseVC = segue.destination as? ChoseFeatureController {
      let image = imageView.image!
      //Resize image
      let size = image.size.applying(CGAffineTransform(scaleX: 0.6, y: 0.6))
      UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
      image.draw(in: CGRect(origin: CGPoint.zero, size: size))
      let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      choseVC.scaledImage = scaledImage
    }
  }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.image = image
      navigationItem.rightBarButtonItem?.isEnabled = true
    }
    dismiss(animated: true, completion: nil)
  }
}

