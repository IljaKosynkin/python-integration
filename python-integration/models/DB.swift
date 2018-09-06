//
//  DB.swift
//  python-integration
//
//  Created by Ilja Kosynkin on 20/08/2018.
//  Copyright © 2018 Syllogismobile. All rights reserved.
//

import Foundation
import CoreData

@objc(DBWebcomic)
final class DBWebcomic: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var image: String?
    @NSManaged var desc: String?
    @NSManaged var date: Date?
}
