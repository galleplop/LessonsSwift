//
//  DatailViewController.swift
//  ChallengePr1-3
//
//  Created by Guillermo Suarez on 26/4/23.
//

import UIKit

class DatailViewController: UIViewController {

    var strCountry : String? = ""
    
    @IBOutlet var imgFlag: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let imageToLoad = strCountry {
            
            imgFlag.image = UIImage(named: imageToLoad)
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
    }
    
    @objc func shareTapped() {
        
        guard let image = imgFlag.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        if let imageToLoad = strCountry {
            
            let acView = UIActivityViewController(activityItems: [image, imageToLoad], applicationActivities: [])
            acView.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            
            present(acView, animated: true)
        }
        
    }

}
