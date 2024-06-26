//
//  ViewController.swift
//  Project13
//
//  Created by Guillermo Suarez on 2/4/24.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var scale: UISlider!
    
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func applyProcessing() {
        
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            
            currentFilter.setValue(scale.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }

        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        
//        print("appling \(actionTitle)")
        self.setFilter(filterName: actionTitle)
    }
    
    func setFilter(filterName: String) {
        
        currentFilter = CIFilter(name: filterName)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            
            if let intensityValue = currentFilter.value(forKey: kCIInputIntensityKey) as? Float {
                
                intensity.setValue(Float.minimum(intensityValue, 1.0), animated: true)
            }
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            
            if let scaleValue = currentFilter.value(forKey: kCIInputScaleKey) as? Float {
                
                scale.setValue(Float.minimum(scaleValue/10.0, 1.0), animated: true)
            }
        }
        
        scale.isEnabled = inputKeys.contains(kCIInputScaleKey)
        
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSaviongWithError error: Error?, contextInfo: UnsafeRawPointer) {
     
        let title: String
        let message: String
        if let error = error {
            
            title = "Save error."
            message = error.localizedDescription
        } else {
            
            title = "Saved!"
            message = "Your altered image has been saved to your photos."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(ac, animated: true)
    }
    
    //MARK: - UIImagePickerControllerDelegate implementation
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        self.dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        intensity.setValue(0, animated: true)
        scale.setValue(0, animated: true)
        
        self.setFilter(filterName: "CISepiaTone")
//        applyProcessing()
        
        //fade in
        self.imageView.alpha = 0
        UIView.animate(withDuration: 1, delay: 0) {
            
            self.imageView.alpha = 1
        }
        
    }

    //MARK: - IBActions
    @IBAction func changeFilter(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        let closure = { alert in
            
            self.setFilter(action: alert)
            sender.titleLabel?.text = alert.title
        }
        
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: closure))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if let image = imageView.image {
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSaviongWithError:contextInfo:)), nil)
        } else {
            
            let ac = UIAlertController(title: "No image selected", message: "Please first select an image from your gallery", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            self.present(ac, animated: true)
        }
        
        
    }
    
    @IBAction func sliderChange(_ sender: Any) {
        
        applyProcessing()
    }
    
}

