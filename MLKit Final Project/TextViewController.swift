//
//  TextViewController.swift
//  MLKit Starter Project
//
//  Created by Sai Kambampati on 5/20/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
//import Firebase

var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init()
        ai.activityIndicatorViewStyle = .whiteLarge
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
@available(iOS 13.0, *)

class TextViewController: UIViewController, UIImagePickerControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var pickerView: UIPickerView!
    var pickerViewDataSize:Int!
    var pickerViewData = [String]()
    var choice:Int!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        // Create a variable to store the name the user entered on textField
        let result_text = resultView.text ?? ""
        // Create a new variable to store the instance of the SecondViewController
        // set the variable from the SecondViewController that will receive the data
        let destinationVC = segue.destination as! resultview
        destinationVC.result_text = result_text
        destinationVC.choice = choice
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4;
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewData = ["防曬品","粉底","乳液化妝水","其他"]
      return pickerViewData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // 依據元件的 tag 取得 UITextField
    // 將 UITextField 的值更新為陣列 meals 的第 row 項資料
        choice = row
    }
//    func setUpPickerView(data:[String]) {
//      // 設置顯示資料
//      pickerViewData = data
////      pickerView.dataSource = self
////      pickerView.delegate = self
////      pickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3)
////      pickerView.center = view.center
////      view.addSubview(pickerView)
//      // 這邊我們會以我們資料數量乘上 100 作為我們 PickerView 的總 row 長。
//      pickerViewDataSize = pickerViewData.count
//      // 將我們的起始點設為中間
//      pickerView.selectRow(1, inComponent: 0, animated: false)
//    }
    let semaphore = DispatchSemaphore(value: 0)
    var data_text = String()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultView: UITextView!
    private let queue = DispatchQueue(label: "com.jimmy.ocr")
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let imagePicker = UIImagePickerController()
//    let vision = Vision.vision()
//    let textRecognizer = vision.cloudTextRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
//        textDetector = vision.textDetector()
        // Do any additional setup after loading the view.
    }
    @IBAction func uploadImage(_ sender: Any) {
        presentImagePicker()
//        imagePicker.allowsEditing = false
//        present(imagePicker, animated: true, completion: nil)
        
    }
    func presentImagePicker(){
        let imagePickerActionsheet = UIAlertController(title: "sanp/upload Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
          let camerabutton = UIAlertAction(title: "take photo", style: .default){
             (alert) -> Void in
            let imagepicker = UIImagePickerController()
            imagepicker.delegate = self
            imagepicker.sourceType = .camera
            self.present(imagepicker, animated: true)
          }
          imagePickerActionsheet.addAction(camerabutton)
        }
        let librarybutton = UIAlertAction(title: "choose Existing", style: .default) { (alert) -> Void in
          let imagepicker = UIImagePickerController()
          imagepicker.delegate = self
          imagepicker.sourceType = .photoLibrary
          imagepicker.allowsEditing = false
          self.present(imagepicker, animated: true)
        }
        imagePickerActionsheet.addAction(librarybutton)
        let cancelbutton = UIAlertAction(title: "cancel", style: .cancel){(alert) -> Void in
            self.removeSpinner()
        }
        imagePickerActionsheet.addAction(cancelbutton)
        present(imagePickerActionsheet, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var ttext_result = String()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        showSpinner(onView: self.view)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            applyOCR(uitext:resultView, image: pickedImage,completionHandler: {Errors,data in
            })
        }
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.waiting()
        }
//        activityIndicator.stopAnimating()
    }
    func waiting(){
        self.semaphore.wait()
        resultView.isSelectable = true
        resultView.isEditable = true
        resultView.text = data_text
        self.removeSpinner()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func applyOCR(uitext: UITextView,image: UIImage, completionHandler: @escaping(_ error: Error?, _ data : String? ) -> Void) {
        let imageData: NSData = UIImageJPEGRepresentation(image, 0.2)!as NSData
        var base64 = imageData.base64EncodedString(options:.endLineWithCarriageReturn)
        var body = "{ 'requests': [ { 'image': { 'content': '\(base64)' }, 'features': [ { 'type': 'DOCUMENT_TEXT_DETECTION' } ],  'imageContext': {'languageHints': ['en']} } ] }";
        var session = URLSession.shared
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyBpA_zbW2fSvVK5vrbHf1lEgEItRdk4BMU")

        var request = NSMutableURLRequest(url: url!, cachePolicy:
            NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data,
            response,
            error in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(error, nil)
            }
            if let data = data {
                do {
                    let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    var json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as![String: Any]
                    if let responseData = json["responses"] as? NSArray {
                        if let levelB = responseData[0] as? [String: Any] {
                            if let levelC = levelB["fullTextAnnotation"] as? [String: Any] {
                                if let text = levelC["text"] as? String {
//                                    print(text)
                                    self.data_text = text
//                                    uitext.text = text
                                    self.semaphore.signal()
                                    completionHandler(nil, text)
                                    return
                                }
                            }
                        }
                    }
                    let error = NSError(domain: "", code: 401,userInfo:[NSLocalizedDescriptionKey: "Invaild access token"])
                    completionHandler(error, nil)
                    return
                } catch {
                    print("error parsing \(error)")
                    completionHandler(error, nil)
                    return
                }
            }
        })
        task.resume()
    }
    
}

