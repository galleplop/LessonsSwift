//
//  ViewController.swift
//  Project15
//
//  Created by Guillermo Suarez on 6/4/24.
//

import UIKit

class ViewController: UIViewController {

    var imagaView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagaView = UIImageView(image: UIImage(named: "penguin"))
        imagaView.center = self.view.center
        view.addSubview(imagaView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        
        sender.isHidden = true
        
//        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            switch self.currentAnimation {
                
            case 0:
                
                self.imagaView.transform = CGAffineTransform(scaleX: 2, y: 2)
                break
            case 1:
                
                self.imagaView.transform = CGAffineTransform.identity
                break
            case 2:
                
                self.imagaView.transform = CGAffineTransform(translationX: -256, y: -256)
                break
            case 3:
                
                self.imagaView.transform = CGAffineTransform.identity
                break
            case 4:
                
                self.imagaView.transform = CGAffineTransform(rotationAngle: .pi)
                break
            case 5:
                
                self.imagaView.transform = CGAffineTransform.identity
                break
            case 6:
                
                self.imagaView.alpha = 0.1
                self.imagaView.backgroundColor = .green
                break
            case 7:
                
                self.imagaView.alpha = 1
                self.imagaView.backgroundColor = .clear
                break
            default:
                break
            }
        }) { finish in
            
            sender.isHidden = false
        }
        
        currentAnimation += 1
        
        if currentAnimation > 7 {
            
            currentAnimation = 0
        }
        
    }
    
}

