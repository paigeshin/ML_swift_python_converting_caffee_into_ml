//
//  ViewController.swift
//  flower_recognition
//
//  Created by shin seunghyun on 2020/04/18.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            guard let convertedImage = CIImage(image: userPickedImage) else {fatalError("Cannot convert to CIImage")}
            imageView.image = userPickedImage
            detect(image: convertedImage)
        }
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Cannot import model") }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            let classification = request.results?.first as? VNClassificationObservation
        
            self.navigationItem.title = classification?.identifier.capitalized
            self.requestInfo(flowerName: classification!.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    //flower name을 기준으로 request, detectd의 결과값인
    func requestInfo(flowerName: String) {
        
        let parameters : [String: String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            
            print(response.result)
            
            //json parsing using swifty json
            
             let flowerJSON: JSON
            
            switch response.result {
            case .success(let value):
                flowerJSON = JSON(value)
                
                print("flowerJSON: \(flowerJSON)")
                
                let pageId = flowerJSON["query"]["pageids"][0].stringValue
                
                print(flowerJSON["query"])
                
                let flowerDescription = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                
                let flowerImageURL = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
                self.label.text = flowerDescription
                
            case .failure(let error):
                print(error)
            }
            
           
            

            
        }
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
}

