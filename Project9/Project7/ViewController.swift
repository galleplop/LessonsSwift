//
//  ViewController.swift
//  Project7
//
//  Created by Guillermo Suarez on 28/3/24.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    var isFiltered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        let cleanBtn = UIBarButtonItem(title: "Clean", style: .plain, target: self, action: #selector(cleanButton))
        let filterBtn = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButton))
        
        navigationItem.leftBarButtonItems = [filterBtn, cleanBtn]
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            
            if let data = try? Data(contentsOf: url){
                
                self.parse(json: data)
                return
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    func parse(json: Data) {
        
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            
            petitions = jsonPetitions.results
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    @objc func showError() {
        
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    @objc func showCredits() {
        
        let ac = UIAlertController(title: "Credits", message: "The People API of the Whitehouse website", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    @objc func cleanButton() {
        
        isFiltered = false
        filteredPetitions = []
        self.tableView.reloadData()
    }
    
    @objc func filterButton() {
        
        let ac = UIAlertController(title: "Enter filter text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] alertAction in
            
            guard let filter = ac?.textFields?[0].text else {return}
            self?.filterPetition(text:filter.lowercased())
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func filterPetition(text: String) {
        
        filteredPetitions = petitions.filter{ $0.title.lowercased().contains(text) || $0.body.lowercased().contains(text) }
        
        isFiltered = true
        
        self.tableView.reloadData()
    }

    //MARK: -
    //MARK: TableView Delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return isFiltered ? filteredPetitions.count:petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let rowPetition = isFiltered ? filteredPetitions[indexPath.row]:petitions[indexPath.row]
        
        cell.textLabel?.text = rowPetition.title
        cell.detailTextLabel?.text = rowPetition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = isFiltered ? filteredPetitions[indexPath.row]:petitions[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

