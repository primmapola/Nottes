//
//  Note+CoreDataProperties.swift
//  Nottes
//
//  Created by Grigory Don on 10.11.2023.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var isComplete: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var timeOfDay: Int16
    @NSManaged public var title: String?
    @NSManaged public var folder: Folder?

}

extension Note : Identifiable {

}
