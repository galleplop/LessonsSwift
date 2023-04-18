//
//  DetailViewController.swift
//  Project1
//
//  Created by Guillermo Suarez on 17/4/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let imageToLoad = selectedImage {
            
            imgView.image = UIImage(named: imageToLoad)
            
            title = imageToLoad
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
