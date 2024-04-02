//
//  ViewController.swift
//  Project1
//
//  Created by Guillermo Suarez on 17/4/23.
//

import UIKit
import StoreKit

class ViewController: UITableViewController {

    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.performSelector(inBackground: #selector(loadPictures), with: nil)
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recomendApp))
    }
    
    @objc func loadPictures() {
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                
//                print("picture to load " + item)
                pictures.append(item)
                
            }
        }
        
        pictures.sort(by: <)
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.reloadData()
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @objc func recomendApp() {
        if #available(iOS 10.3, *) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pictures.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pictureName", for: indexPath)
        
        
        cell.textLabel?.text = pictures[indexPath.row]
        
        let defaults = UserDefaults.standard
        
        let viewCounts = defaults.integer(forKey: "\(pictures[indexPath.row])-viewCounts")
        cell.detailTextLabel?.text = "#Views: \(viewCounts)"
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            let nameImage = pictures[indexPath.row]
            
            vc.selectedImage = nameImage
            
            let defaults = UserDefaults.standard
            
            var viewCounts = defaults.integer(forKey: "\(nameImage)-viewCounts")
            viewCounts += 1
            defaults.set(viewCounts, forKey: "\(nameImage)-viewCounts")
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

