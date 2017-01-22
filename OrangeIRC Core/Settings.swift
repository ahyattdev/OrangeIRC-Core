//
//  Settings.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/21/17.
//
//

import Foundation

public class Settings {
    
    fileprivate struct Keys {
        
        private init() { }
        
        static let AutoReconnect = "AutoReconnect"
        
    }
    
    public static let shared = Settings()
    private init() { }
    
    var autoReconnect = UserDefaults.standard.bool(forKey: Keys.AutoReconnect) {
        didSet {
            UserDefaults.standard.set(autoReconnect, forKey: Keys.AutoReconnect)
        }
    }
    
}
