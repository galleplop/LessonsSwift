//
//  ViewController.swift
//  project2
//
//  Created by Guillermo Suarez on 18/4/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var btn1: UIButton!
    @IBOutlet var btn2: UIButton!
    @IBOutlet var btn3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questions = 0
    
    fileprivate func buttonStyle(button: UIButton) {
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading th( view.
        
        countries += ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
        
        buttonStyle(button: btn1)
        buttonStyle(button: btn2)
        buttonStyle(button: btn3)
        
        askQuestion()
        
    }

    @IBAction func donePresed(_ sender: Any) {
        
        let alert = UIAlertController(title: title, message: "Your final score is \(score)/\(questions)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset Game", style: .default, handler: resetGame))
        
        present(alert, animated: true)
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        
        questions += 1
        countries.shuffle()
//        print(countries)
        correctAnswer = Int.random(in: 0...2)
        
        btn1.setImage(UIImage(named: countries[0].lowercased()), for: .normal)
        btn2.setImage(UIImage(named: countries[1].lowercased()), for: .normal)
        btn3.setImage(UIImage(named: countries[2].lowercased()), for: .normal)
        
        title = countries[correctAnswer] + " | Score: \(score)"
    }
    
    func resetGame(action: UIAlertAction! = nil) {
        
        score = 0
        questions = 0
        
        askQuestion()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            
            let defaults = UserDefaults.standard
            var highestScore = defaults.integer(forKey: "score")
            
            if score > highestScore {
                
                title += ", new record!"
                
                defaults.set(score, forKey: "score")
            }
            
        } else {
            title = "Wrong this is \(countries[sender.tag])"
            score -= 1
        }
        
        let alert:UIAlertController
        
        if (questions%10 == 0) {
            
            alert = UIAlertController(title: title, message: "Your final score is \(score)/\(questions)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            alert.addAction(UIAlertAction(title: "Reset Game", style: .default, handler: resetGame))
        } else {
            
            alert = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        }
        
        
        
        present(alert, animated: true)
        
        
    }
}


