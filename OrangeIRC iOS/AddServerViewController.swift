//
//  AddServerViewController.swift
//  OrangeIRC
//
//  Created by Andrew Hyatt on 7/5/16.
//
//

import UIKit
import OrangeIRCCore

class AddServerViewController : UITableViewController {
    
    let CELL_IDENTIFIER = "TextFieldCell"
    
    override  func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
