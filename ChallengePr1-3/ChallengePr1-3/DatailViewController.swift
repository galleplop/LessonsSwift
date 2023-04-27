//
//  DatailViewController.swift
//  ChallengePr1-3
//
//  Created by Guillermo Suarez on 26/4/23.
//

import UIKit

class DatailViewController: UIViewController {

    var strCountry : String = ""
    
    @IBOutlet var imgFlag: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if !strCountry.isEmpty {
            
            imgFlag.image = UIImage(named: strCountry)
        }
        
        
    }

}
