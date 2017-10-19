//
//  BackgroundProcess.swift
//  DeDup
//

import Foundation

infix operator ~>

//private let queue = DispatchQueue.global()

func ~> (
    bg: @escaping () -> (),
    fg: @escaping () -> ())
{
    DispatchQueue.global(qos: .userInitiated).async {
        bg()
        // Bounce back to the main thread to update the UI
        DispatchQueue.main.async {
            fg()
        }
    }
}


