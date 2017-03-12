//
//  Utilities.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 2/25/17.
//
//

import Foundation

internal func localized(_ string: String) -> String {
    for framework in Bundle.allFrameworks {
        if let id = framework.bundleIdentifier {
            if id == "io.github.ahyattdev.OrangeIRCCore" {
                return NSLocalizedString(string, tableName: "Localizations", bundle: framework, value: "", comment: "")
            }
        }
    }
    print("OrangeIRCCore: Failed to find localized string")
    return string
}
