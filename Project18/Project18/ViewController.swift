//
//  ViewController.swift
//  Project18
//
//  Created by Guillermo Suarez on 11/4/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("1-", terminator: "")
        print(2, 3, 4, 5, separator: "-")
        
        assert(1 == 1, "Math failure!")
        
        for i in 1...100 {
            
            print("Got number \(i)")
        }
    }


}

