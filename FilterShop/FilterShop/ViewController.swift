//
//  ViewController.swift
//  FilterShop
//
//  Created by Xue Yu on 9/17/17.
//  Copyright © 2017 XueYu. All rights reserved.
//

import Cocoa
import Quartz

/// Main View Controller.
/// - avaliableFiltersTableView : tableview to list all avaliable Filters.
/// - chosenFiltersTableView : tableview to list all chosen Filters.
/// - mediaView : display the media(image).
/// - avaliableFilters : dataSource of avaliableFiltersTableView.
/// - chosenFilters : dataSource of chosenFiltersTableView, and applied on mediaView.
/// - curFilter : Current choosed Filter
/// - saveOptions : Use IKSaveOptions from Quartz to better save the image.
class ViewController: NSViewController {

    @IBOutlet weak var avaliableFiltersTableView: NSTableView!
    @IBOutlet weak var chosenFiltersTableView: NSTableView!
    @IBOutlet weak var mediaView: MediaDisplayView!
    
    let avaliableFilters = CoreImageFilters.avaliableFilters()
    var curFilter: CIFilter?
    var chosenFilters = [CIFilter](){
        didSet {
            mediaView.apply(filters: chosenFilters)
        }
    }
    
    var saveOptions = IKSaveOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avaliableFiltersTableView.dataSource = self
        avaliableFiltersTableView.delegate = self
        chosenFiltersTableView.dataSource = self
        chosenFiltersTableView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /**
     add avaliable Filter to chosen Filter
    */
    @IBAction func addFilterTouched(_ sender: NSButton) {
        let idx = avaliableFiltersTableView.row(for: sender)
        let chosenFilterName = avaliableFilters[idx]
       
        guard let chosenFilter = CIFilter.init(name: chosenFilterName) else { return }
        
        chosenFiltersTableView.beginUpdates()
        chosenFilters.append(chosenFilter)
        chosenFiltersTableView.insertRows(at: IndexSet(integer: chosenFilters.count - 1), withAnimation: .effectFade)
        chosenFiltersTableView.endUpdates()
        
    }
    
    
    /**
     remove chosen Filter from chosen Filters
     */
    @IBAction func deleteFilterTouched(_ sender: NSButton) {
        let idx = chosenFiltersTableView.row(for: sender)
        
        chosenFiltersTableView.beginUpdates()
        chosenFilters.remove(at: idx)
        chosenFiltersTableView.removeRows(at: IndexSet(integer: idx), withAnimation: .effectFade)
        chosenFiltersTableView.endUpdates()
        
        curFilter = nil
        
    }
    
    /**
     show filter parameters about the touched filter
    */
    @IBAction func infoButtonTouched(_ sender: NSButton) {
        performSegue(withIdentifier: "filterParameter", sender: sender)
    }
    
    
    /**
     prepare for segue
    */
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let segueId = segue.identifier ?? "UnknownSegue"
        if segueId == "filterParameter"  {
            let destinationvc = segue.destinationController as? FilterParameterVC
            let idx = chosenFiltersTableView.row(for: sender as! NSView)
            curFilter = chosenFilters[idx]
            
            destinationvc?.filter = curFilter
        }
        
    }
    
    
    /**
     For Menu Item Open Image
    */
    @IBAction func openImage(_ sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes =  ["jpg","png","pdf","pct", "bmp", "tiff"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        
        guard let window = self.view.window else { return }
        openPanel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                if let url = openPanel.url {
                    self.mediaView.imageUrl = url
                }
                else {
                    let alert = NSAlert()
                    alert.messageText = "You can also drop image in gray area."
                    alert.runModal()
                }
            }
        }
    }
    
    // Help Menu Item
    @IBAction func helpMenuItemTouched(_ sender: NSMenuItem) {
        let url = URL(string: "https://github.com/KrisYu/FilterShop")!
        NSWorkspace.shared.open(url)
    }
    
    
    /**
     For Menu Item Save Image
    */
    @IBAction func saveAs(_ sender: AnyObject){
        let savePanel = NSSavePanel()
        saveOptions = IKSaveOptions(imageProperties: [:], imageUTType: kUTTypePNG as String)
        saveOptions.addAccessoryView(to: savePanel)
        
        guard let window = self.view.window, let _ = mediaView.ciimage else { return }
        savePanel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.savePanelDidEnd(sheet: savePanel, returnCode: result.rawValue)
            }
        }
    }
    
    func savePanelDidEnd (sheet: NSSavePanel, returnCode: NSInteger) {
        if returnCode == NSApplication.ModalResponse.OK.rawValue {
            guard let newUTType = saveOptions.imageUTType as CFString?,
                let url = sheet.url as CFURL?,
                let cgimage = mediaView.export(filters: chosenFilters),
                let dest = CGImageDestinationCreateWithURL(url, newUTType, 1, nil)
                else { return }
            CGImageDestinationAddImage(dest, cgimage, nil)

            if CGImageDestinationFinalize(dest) {
                print(dest)
            } else {
                print("*** saveImageToPath - no image")
            }
        }
    }


}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == avaliableFiltersTableView {
            return avaliableFilters.count
        } else {
            return chosenFilters.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == avaliableFiltersTableView {
            let filterName = avaliableFilters[row]
            
            // cell display Category and Filter in a different way
            if filterName.hasPrefix("CICategory") {
                guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let text = CIFilter.localizedName(forCategory: filterName)
                cell.textField?.stringValue = text
                return cell
            } else {
                guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FilterCell"), owner: self) as? NSTableCellView,
                    let text = CIFilter.localizedName(forFilterName: filterName) else {
                        return nil
                }
                cell.textField?.stringValue = text
                return cell
            }
        } else {
            
            let filterName = chosenFilters[row].name
            
            guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "chosenFilterCell"), owner: self) as? NSTableCellView else { return nil }
            
            // display the filter name in readable way
            cell.textField?.stringValue = CIFilter.localizedName(forFilterName: filterName) ?? "Unknown Filter"

            return cell
        }

    }
    
    
    /// Avoid row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}

