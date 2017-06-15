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
        let alert = UIAlertController(title: localized("JOIN_CHANNEL"), message: localized("JOIN_CHANNEL_DESCRIPTION"), preferredStyle: .alert)
        
        var channelField: UITextField!
        
        var actionDisabler: ActionDisabler?
        
        let cancel = UIAlertAction(title: localized("CANCEL"), style: .cancel, handler: { action in
            actionDisabler = nil
        })
        alert.addAction(cancel)
        
        let join = UIAlertAction(title: localized("JOIN"), style: .default, handler: { action in
            if let text = channelField.text {
                server.join(channel: text)
            }
            actionDisabler = nil
        })
        alert.addAction(join)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("CHANNEL_NAME")
            
            // Just so the warning goes away. Yes, it is for a good reason
            if actionDisabler == nil {
                actionDisabler = ActionDisabler(action: join, textField: textField)
            }
            
            textField.returnKeyType = .next
            
            channelField = textField
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("CHANNEL_KEY")
            textField.returnKeyType = .join
        })
        
        return alert
    }
}
