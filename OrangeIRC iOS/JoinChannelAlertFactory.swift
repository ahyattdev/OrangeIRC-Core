//
//  JoinChannelAlertFactory.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/5/17.
//
//

import UIKit
import OrangeIRCCore

struct JoinChannelAlertFactory {
    
    static func make(server: Server) -> UIAlertController {
        let alert = UIAlertController(title: localized("JOIN_CHANNEL"), message: "JOIN_CHANNEL_DESCRIPTION", preferredStyle: .alert)
        
        var channelField: UITextField!
        
        let cancel = UIAlertAction(title: localized("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let join = UIAlertAction(title: localized("JOIN"), style: .default, handler: { action in
            if let text = channelField.text {
                server.join(channel: text)
            }
        })
        alert.addAction(join)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("CHANNEL_NAME")
            _ = ActionDisabler(action: join, textField: textField)
            
            channelField = textField
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("CHANNEL_KEY")
            
        })
        
        return alert
    }
}
