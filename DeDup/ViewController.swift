//
//  ViewController.swift
//  DeDup
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var filterTextField: NSTextField!
    
    @IBAction func refreshButton(_ sender: Any) {
        self.refreshOutlineView()
    }
    
    var helpWindowController: NSWindowController? = nil

    @IBAction func showHelp(_ sender: Any?) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        self.helpWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "HelpWindowController")) as? NSWindowController
        self.helpWindowController?.showWindow(self)
    }

    @IBAction func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                {
                    let fileTree = FileTree.loadFrom(url: panel.url!)
                    self.fileTrees.append(fileTree)
                    fileTree.updateHashes(hashes: &self.hashes)
                }
                    ~>
                {
                    self.refreshOutlineView()
                }
            }
        }
    }
    
    var fileTrees = [FileTree]()
    var hashes: [String: [String]] = [:]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func refreshOutlineView()
    {
        for f in self.fileTrees
        {
            f.refreshDuplicates(hashes: self.hashes, filter: self.filterTextField.stringValue)
        }
        self.outlineView.reloadData()
    }



}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let fileTree = item as? FileTree {
            return fileTree.children.count
        }

        return fileTrees.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let fileTree = item as? FileTree {
            return fileTree.children[index]
        }
        
        return fileTrees[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let fileTree = item as? FileTree {
            return fileTree.children.count > 0
        }
        
        return false
    }
}

extension ViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?

        if let fileTree = item as? FileTree {
            if (tableColumn?.identifier)!.rawValue == "HashColumn" {
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HashCell"), owner: self) as? NSTableCellView
                
                if let textField = view?.textField {
                    textField.stringValue = ""
                    textField.sizeToFit()
                }
            } else {
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileTreeCell"), owner: self) as? NSTableCellView
                
                if let textField = view?.textField {
                    textField.stringValue = fileTree.name
                    let color = (fileTree.items == fileTree.duplicates) ? NSColor(red: 0, green: 1, blue: 0, alpha: 0.5) : NSColor(hue: 0.65, saturation: CGFloat(fileTree.duplicates)/CGFloat(fileTree.items), brightness: 1, alpha: 0.5)
                    textField.backgroundColor = color
                    textField.sizeToFit()
                }
            }
        }
        else if let fileTreeItem = item as? FileTreeItem {
            if (tableColumn?.identifier)!.rawValue == "HashColumn" {
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HashCell"), owner: self) as? NSTableCellView
                
                if let textField = view?.textField {
                    textField.stringValue = fileTreeItem.fileHash
                    textField.sizeToFit()
                }
            } else {
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileTreeItemCell"), owner: self) as? NSTableCellView
                if let textField = view?.textField {
                    textField.stringValue = fileTreeItem.name
                        textField.backgroundColor = (fileTreeItem.duplicates > 0) ? NSColor(red: 0, green: 1, blue: 0, alpha: 0.5) : NSColor.clear
                    textField.sizeToFit()
                }
            }
        }

        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow
        if let fileTreeItem = outlineView.item(atRow: selectedIndex) as? FileTreeItem {
            let fileHash = fileTreeItem.fileHash
            textView.textStorage?.mutableString.setString(fileHash + "\n")
            for file in hashes[fileHash]!
            {
                textView.textStorage?.append(NSAttributedString(string: file + "\n"))
            }
        }
    }
    
}

