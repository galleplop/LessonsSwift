//
//  Person.swift
//  Project10
//
//  Created by Guillermo Suarez on 30/3/24.
//

import UIKit

class Person: NSObject, NSCoding {
    

    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: "name") as? String,
                let image = coder.decodeObject(forKey: "image") as? String else {
            return nil
        }
        
        self.init(name: name, image: image)
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(name, forKey: "name")
        coder.encode(image, forKey: "image")
    }
}
