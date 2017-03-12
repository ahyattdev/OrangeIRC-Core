//
//  Utilities.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/12/17.
//
//

import Foundation

internal func localized(_ string: String) -> String {
    return NSLocalizedString(string, tableName: "Localizations", bundle: Bundle.main, value: "", comment: "")
}
