//
//  ImageAttachment.swift
//  CDbT
//
//  Created by Qiao Zhang on 2/8/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit
import CoreData

class ImageAttachment: Attachment {
  @NSManaged var image: UIImage?
  @NSManaged var width: Float
  @NSManaged var height: Float
  @NSManaged var caption: String
}
