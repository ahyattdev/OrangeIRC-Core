//
//  Message.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/2/16.
//
//

import Foundation

let SPACE = " "
let SLASH = "/"
let COLON = ":"
let EXCLAMATION_MARK = "!"
let AT_SYMBOL = "@"

struct Message {
    
    enum MessageParseError: ErrorProtocol {
        case InvalidPrefix
        case InvalidMessage
    }
    
    struct Prefix {
        
        var prefix: String
        var servername: String?
        var nickname: String?
        var user: String?
        var host: String?
        
        init(_ string: String) throws {
            prefix = string
            if prefix[prefix.startIndex] == Character(COLON) {
                prefix.remove(at: prefix.startIndex)
            } else {
                throw MessageParseError.InvalidPrefix
            }
            if prefix.contains(EXCLAMATION_MARK) && prefix.contains(AT_SYMBOL) {
                // Full version of the prefix
                
                // TODO: Parse the full prefix
            } else {
                // Server name version only
                servername = prefix
            }
//            let slashComponents = string.components(separatedBy: SLASH)
//            let colonComponents = slashComponents[1].components(separatedBy: COLON)
//            let exclamComponents = colonComponents[1].components(separatedBy: EXCLAMATION_MARK)
//            let atComponents = exclamComponents[1].components(separatedBy: AT_SYMBOL)
//            servername = slashComponents[0]
//            nickname = colonComponents[0]
//            user = exclamComponents[0]
//            host = atComponents[1]
        }
        
    }
    
    var message: String
    var prefix: Prefix?
    var command: String
    var target: String?
    var parameters: String
    
    init(_ string: String) throws {
        message = string.replacingOccurrences(of: "\r\n", with: "")
        let components = message.components(separatedBy: SPACE)
        if components.count < 2 {
            throw MessageParseError.InvalidMessage
        }
        
        try prefix = Prefix(components[0])
        command = components[1]
        
        var cutString = message
        cutString.remove(at: string.startIndex)
        
        //if cutString.contains(COLON) {
            // There are parameters
        //} else {
            // There are no parameters
        //}
        
        let colonComponents = cutString.components(separatedBy: COLON)
        let prefixAndCommand = colonComponents[0].components(separatedBy: " ")
        if prefixAndCommand.count == 3 {
            // Just prefix and command
            command = prefixAndCommand[1]
        } else if prefixAndCommand.count == 4 {
            // Prefix, command, and target
            command = prefixAndCommand[1]
            target = prefixAndCommand[2]
        } else {
            throw MessageParseError.InvalidMessage
        }
        
        let parameterStartIndex = message.range(of: colonComponents[0])?.upperBound
        parameters = string.substring(from: parameterStartIndex!)
        
        // Remove the colon
        parameters.remove(at: parameters.startIndex)
    }
    
}
