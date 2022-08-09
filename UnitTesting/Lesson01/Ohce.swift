//
//  Ohce.swift
//  UnitTesting
//
//  Created by Andris Laduzans on 04/08/2022.
//

import Foundation

struct Ohce {
    var user: OhceUser? = nil
    
    mutating func input(_ input: String) -> String {
        if isGreetingInput(input) {
            storeUserName(input)
        }
        
        return "¡Buenos días \(user?.id ?? "")!"
    }
    
    private func isGreetingInput(_ input: String) -> Bool {
        let words = input.components(separatedBy: [" "])
        return words.count >= 2 && words[0] == "ohce"
    }
    
    mutating private func storeUserName(_ input: String) -> Void {
        let words = input.components(separatedBy: [" "])
        self.user = OhceUser(id: words[1])
    }
}

struct OhceUser {
    var id: String;
}
