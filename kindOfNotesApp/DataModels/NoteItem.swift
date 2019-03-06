//
//  NoteItem.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 22/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import Foundation
import UIKit


class NoteItem: NSObject, Codable {
    var noteTitle = ""
    var noteText = ""
    var noteImages = [String]()
    var isLoced = false
    var password = ""
}
