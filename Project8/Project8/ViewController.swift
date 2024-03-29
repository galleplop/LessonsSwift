//
//  ViewController.swift
//  Project8
//
//  Created by Guillermo Suarez on 29/3/24.
//

import UIKit

class ViewController: UIViewController {

    var cluesLabel: UILabel!
    var answersLabels: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0
    var level = 1
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        cluesLabel.textAlignment = .left
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        answersLabels = UILabel()
        answersLabels.translatesAutoresizingMaskIntoConstraints = false
        answersLabels.font = UIFont.systemFont(ofSize: 24)
        answersLabels.text = "ANSWERS"
        answersLabels.numberOfLines = 0
        answersLabels.textAlignment = .right
        answersLabels.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabels)
        
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonView = UIView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonView)
        
        NSLayoutConstraint.activate([
           scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
           scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
           
           cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
           cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
           cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
           
           answersLabels.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
           answersLabels.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
           answersLabels.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
           answersLabels.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
           
           currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
           currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
           
           submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
           submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
           submit.heightAnchor.constraint(equalToConstant: 44),
           
           clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
           clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
           clear.heightAnchor.constraint(equalToConstant: 44),
           
           buttonView.widthAnchor.constraint(equalToConstant: 750),
           buttonView.heightAnchor.constraint(equalToConstant: 320),
           buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           buttonView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
           buttonView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
        
//        cluesLabel.backgroundColor = .red
//        answersLabels.backgroundColor = .blue
//        buttonView.backgroundColor = .green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loadLevel()
    }


    @objc func letterTapped(_ sender: UIButton) {
        
        
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        
        
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        
        
    }
    
    func loadLevel() {
        
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
                
            }
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabels.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterButtons.shuffle()
        
        if letterButtons.count == letterBits.count {
            
            for i in 0..<letterButtons.count {
                
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
}

