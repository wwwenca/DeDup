//
//  FileTree.swift
//  DeDup
// 

import Cocoa

class FileTree: NSObject {
    let name: String
    var children = [NSObject]()
    let bannedHashes : [String] = ["d41d8cd98f00b204e9800998ecf8427e"]
    
    private var _items = 0
    private var _duplicates = 0

    init(name: String){
        self.name = name;
    }
    
    func addChild(localPath: String, fileHash: String, fullPath: String)
    {
        if (localPath.contains("/"))
        {
            let parts = localPath.split(separator: "/", maxSplits: 1)
            let name = String(parts[0])
            let restOfLocalPath = String(parts[1])
            let childFileTree: FileTree
            if let i = self.children.index(
                where: {
                    if let childFileTree = $0 as? FileTree {
                        return childFileTree.name == name
                    }
                    else
                    {
                        return false
                    }
            }
                )
            {
                childFileTree = self.children[i] as! FileTree
            }
            else
            {
                childFileTree = FileTree(name: name)
                self.children.append(childFileTree)
            }

            childFileTree.addChild(localPath: restOfLocalPath, fileHash: fileHash, fullPath: fullPath)
        }
        else
        {
            let item = FileTreeItem(name: localPath, fileHash: fileHash, fullPath: fullPath)
            self.children.append(item)
        }        
    }
    
    func updateHashes( hashes: inout [String: [String]])
    {
        for child in self.children
        {
            if let childFileTree = child as? FileTree {
                childFileTree.updateHashes(hashes: &hashes)
            }
            if let childFileTreeItem = child as? FileTreeItem {
                if hashes.keys.contains(childFileTreeItem.fileHash)
                {
                    hashes[childFileTreeItem.fileHash]!.append(childFileTreeItem.fullPath)
                }
                else
                {
                    hashes[childFileTreeItem.fileHash] = [childFileTreeItem.fullPath]
                }
            }
        }
    }
    
    class func loadFrom(url: URL) -> FileTree
    {
        let fileTree = FileTree(name: url.lastPathComponent)
        
        if let sr = StreamReader(path: url.path) {
            while let line = sr.nextLine() {
                let line2: String
                
                // remove leading slashes from hash
                if (line.starts(with: "\\"))
                {
                    line2 = String(line.dropFirst())
                }
                else
                {
                    line2 = line;
                }
                
                let fileHash = String(line2.prefix(32))
                
                // skip banned hashes
                if (fileTree.bannedHashes.contains(fileHash))
                {
                    continue
                }
                
                let filePath = String(("/"+line2.dropFirst(34)).replacingOccurrences(of: "//", with: "/"))
                
                let relativeFilePath = String(filePath.dropFirst())
                
                fileTree.addChild(localPath: relativeFilePath, fileHash: fileHash, fullPath: filePath)
                
            }
            sr.close()
        }
        return fileTree;
    }
}


extension FileTree: DuplicatesHandling
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
        _duplicates = 0
        _items = 0
        for child in self.children as! [DuplicatesHandling]
        {
            child.refreshDuplicates(hashes: hashes, filter: filter)
            _items += child.items
            _duplicates += child.duplicates
        }
    }
    
}
