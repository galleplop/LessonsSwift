//
//  ViewController.swift
//  Project5
//
//  Created by Guillermo Suarez on 30/12/23.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promperForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if (allWords.isEmpty) {
           
           allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        
        if let currentWord = defaults.string(forKey: "currentWord") {
            
            title = currentWord
            usedWords = defaults.array(forKey: "usedWords") as? [String] ?? []
            
        } else {
            
            startGame()
        }
    }
    
    @objc func startGame() {
        
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        self.save()
        tableView.reloadData()
    }
    
    func save() {
        
        guard let currentWord = title else { return }
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(currentWord, forKey: "currentWord")
        defaults.setValue(usedWords, forKey: "usedWords")
    }
    
    @objc func promperForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] alertAction in
            
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    fileprivate func showErrorMessage(_ errorTitle: String, _ errorMessage: String) {
        
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func submit(_ textSubmit: String) {
        
        let lowerAnswer = textSubmit.lowercased()
        
        let errorTitle : String
        let errorMessage : String
        
        if !isTooShort(word: lowerAnswer) {
            if !isStartWord(word: lowerAnswer) {
                if isPossible(word: lowerAnswer){
                    if isOriginal(word: lowerAnswer) {
                        if isReal(word: lowerAnswer) {
                            
                            usedWords.insert(lowerAnswer, at: 0)
                            self.save()
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        } else {
                            
                            errorTitle = "Word not recognized"
                            errorMessage = "You can't just make them up, you know!"
                        }
                    } else {
                        
                        errorTitle = "Word already used"
                        errorMessage = "Be more original!"
                    }
                } else {
                    
                    errorTitle = "Word not posible"
                    errorMessage = "You can't spell that word from \(title!.lowercased())."
                }
            } else {
                
                errorTitle = "Word is the start word"
                errorMessage = "Be more creative"
            }
        } else {
            
            errorTitle = "Word is too short"
            errorMessage = "Word needs to be greater than 2 letters"
        }
        
        
        
        showErrorMessage(errorTitle, errorMessage)
    }
    
    func isTooShort(word: String) -> Bool {
        
        return word.count < 3
    }
    
    func isStartWord(word: String) -> Bool {
        
        guard let tempWord = title?.lowercased() else {return false}
        
        return tempWord.hasPrefix(word)
    }
    
    func isPossible(word: String) -> Bool {
        
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            
            if let position = tempWord.firstIndex(of: letter) {
                
                tempWord.remove(at: position)
            } else {
                
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    //MARK: - UITableViewController implementation
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
}

