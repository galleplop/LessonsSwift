//
//  ViewController.swift
//  ChallengePr1-3
//
//  Created by Guillermo Suarez on 24/4/23.
//

import UIKit

class ViewController: UITableViewController {
    
    var countries : [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let fm = FileManager.default
        let path = Bundle.main.bundlePath

        print(path)
        let items = try! fm.contentsOfDirectory(atPath: path)

        print(items)
        
        for item in items {
            
            if item.hasSuffix("@2x.png") {
                
                countries += [item.replacingOccurrences(of: "@2x.png", with: "")]
            }
        }
        
        countries.sort(by:<)
        
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellView = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        
        let lblView = cellView.contentView.viewWithTag(1) as! UILabel
        let imgView = cellView.contentView.viewWithTag(2) as! UIImageView
        
        lblView.text = countries[indexPath.row].prefix(1).uppercased() + countries[indexPath.row].dropFirst()

        imgView.image = UIImage(named: countries[indexPath.row])
        return cellView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailSegue"{
            
            let detailVC = segue.destination as? DatailViewController
            
            let row = sender as! UITableViewCell
            let index = tableView.indexPath(for: row)
            
            detailVC?.strCountry = countries[index!.row]
        }
        
    }

}

