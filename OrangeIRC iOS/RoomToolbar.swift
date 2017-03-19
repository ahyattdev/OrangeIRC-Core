//
//  RoomToolbar.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 3/12/17.
//
//

import UIKit
import OrangeIRCCore

class RoomToolbar : UIToolbar {
    
    let room: Room
    
    init(room: Room) {
        self.room = room
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
