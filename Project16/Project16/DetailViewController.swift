//
//  DetailViewController.swift
//  Project16
//
//  Created by Guillermo Suarez on 7/4/24.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    public var capital: Capital!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = capital.title
        
        if let url = URL(string: capital.website) {
            
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
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
