//
//  ViewController.swift
//  Project7
//
//  Created by Guillermo Suarez on 28/3/24.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    
                    print("error web \(error.localizedDescription)")
                    self.showError()
                    
                    return
                }
                
                if let data = data {
                    
                    self.parse(json: data)
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("no data recibed")
                    self.showError()
                }
                
            }
            
            task.resume()
        } else {
            
            showError()
        }
    }
    
    func parse(json: Data) {
        
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            
            petitions = jsonPetitions.results
        }
    }

    func showError() {
        
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }

    //MARK: -
    //MARK: TableView Delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let rowPetition = petitions[indexPath.row]
        
        cell.textLabel?.text = rowPetition.title
        cell.detailTextLabel?.text = rowPetition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

