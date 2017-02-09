//
// Created by Qiao Zhang on 2/9/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import UIKit
import CoreData

class Attachment: NSManagedObject {
  @NSManaged var dateCreated: Date
  @NSManaged var image: UIImage?
  @NSManaged var note: Note
}
