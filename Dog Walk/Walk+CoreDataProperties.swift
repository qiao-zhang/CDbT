//
//  Walk+CoreDataProperties.swift
//  CDbT
//
//  Created by Qiao Zhang on 1/24/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import Foundation
import CoreData


extension Walk {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
    return NSFetchRequest<Walk>(entityName: "Walk");
  }

  @NSManaged public var date: NSDate?
  @NSManaged public var dog: Dog?

}
