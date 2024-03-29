//
//  DetailViewController.swift
//  Project7
//
//  Created by Guillermo Suarez on 28/3/24.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        
        webView = WKWebView()
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Título de tu página</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    font-size: 100%;
                    line-height: 1.6;
                    margin: 0;
                    padding: 0;
                }
                .container {
                    width: 90%;
                    max-width: 600px; /* Establece un ancho máximo para que el texto no se extienda demasiado en pantallas grandes */
                    margin: 1 auto;
                    padding: 20px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>\(detailItem.title)</h1>
                <p>\(detailItem.body)</p>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
        
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
