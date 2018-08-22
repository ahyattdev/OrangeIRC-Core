//
//  Settings.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 1/21/17.
//
//

import Foundation

/// IRC server settings that apply to all serves
open class Settings {
    
    fileprivate struct Keys {
        
        private init() { }
        
        static let AutoReconnect = "AutoReconnect"
        
    }
    
    /// The global instance
    public static let shared = Settings()
    private init() { }
    
    /// Automatically reconnect when a connection to a server is lost
    public var autoReconnect: Bool {
        set {
            UserDefaults.standard.set(autoReconnect, forKey: Keys.AutoReconnect)
        }
        get {
            return UserDefaults.standard.bool(forKey: Keys.AutoReconnect)
        }
    }
    
}
