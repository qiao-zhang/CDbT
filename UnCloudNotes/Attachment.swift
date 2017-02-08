//
//  Attachment.swift
//  CDbT
//
//  Created by Qiao Zhang on 2/8/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit
import CoreData

class Attachment: NSManagedObject {
  @NSManaged var dateCreated: Date
  @NSManaged var note: Note?
}
