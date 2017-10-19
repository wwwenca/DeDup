//
//  FileTreeItem.swift
//  DeDup
//

import Cocoa

class FileTreeItem: NSObject {
    let name: String
    let fullPath: String
    let fileHash: String
    
    private let _items = 1
    private var _duplicates = 0

    
    init(name: String, fileHash: String, fullPath:String)
    {
        self.name = name
        self.fileHash = fileHash
        self.fullPath = fullPath
    }
    
}


extension FileTreeItem: DuplicatesHandling
{
    
    var items: Int {
        get {
            return _items
        }
    }
    
    var duplicates: Int {
        get {
            return _duplicates
        }
    }
    
    func refreshDuplicates(hashes: [String: [String]], filter: String)
    {
        self._duplicates = 0
        let files = hashes[self.fileHash]!
        if (files.count > 1)
        {
            if filter.isEmpty
            {
                self._duplicates = 1
            }
            else
            {
                for file in files
                {
                    if file.contains(filter)
                    {
                        self._duplicates = 1
                        break
                    }
                }
            }
        }
    }

}
