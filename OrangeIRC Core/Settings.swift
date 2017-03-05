//
//  Settings.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/21/17.
//
//

import Foundation

open class Settings {
    
    fileprivate struct Keys {
        
        private init() { }
        
        static let AutoReconnect = "AutoReconnect"
        
    }
    
    open static let shared = Settings()
    private init() { }
    
    var autoReconnect = UserDefaults.standard.bool(forKey: Keys.AutoReconnect) {
        didSet {
            UserDefaults.standard.set(autoReconnect, forKey: Keys.AutoReconnect)
        }
    }
    
}
