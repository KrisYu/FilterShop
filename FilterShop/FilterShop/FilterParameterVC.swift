//
//  FilterParameterVC.swift
//  FilterShop
//
//  Created by XueYu on 9/18/17.
//  Copyright © 2017 XueYu. All rights reserved.
//

import Cocoa

// Display the filter Parameters in tableView
class FilterParameterVC: NSViewController {
    
    @IBOutlet weak var filterParametersTableView: NSTableView!
    var filter: CIFilter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterParametersTableView.delegate = self
        filterParametersTableView.dataSource = self
    }
    
    override func viewDidAppear() {
        guard let window = self.view.window,
            let filter = filter
            else { return }
        
        window.title = filter.name
    }
    
}


extension FilterParameterVC : NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filter?.inputKeys.count ?? 0
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as? NSTableCellView,
            let key = filter?.inputKeys[row],
            let paraDict = filter?.attributes[key] as? [String: Any]
            else { return nil }
        
        let colId = tableColumn?.identifier ?? NSUserInterfaceItemIdentifier(rawValue: "")
        var viewText = ""
        
        switch colId.rawValue {
        case "name":
            viewText = key
        case "description":
            viewText = paraDict[kCIAttributeDescription] as? String ?? "No Description"
        case "attributeName":
            viewText = paraDict[kCIAttributeClass] as? String ?? "No AttributeName"
        case "attributeType":
            viewText = paraDict[kCIAttributeType] as? String ?? "No AttributeType"
        case "defaultValue":
            viewText = String(describing:paraDict[kCIAttributeDefault])
        case "minValue":
            viewText = String(describing: paraDict[kCIAttributeSliderMin])
        case "maxValue":
            viewText = String(describing: paraDict[kCIAttributeSliderMax])
        default:
            break
        }
        
        view.textField?.stringValue = viewText

        return view

    }
    
}
