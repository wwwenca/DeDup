//
//  HandleDupicatesProtocol.swift
//  DeDup
//

import Foundation

protocol DuplicatesHandling {
    var items: Int { get }
    var duplicates: Int { get }
    
    func refreshDuplicates(hashes: [String: [String]], filter: String)
}
