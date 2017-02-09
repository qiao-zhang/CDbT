//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  CDbT
//
//  Created by Qiao Zhang on 2/8/17.
//  Copyright © 2017 Qiao Zhang. All rights reserved.
//

import UIKit
import CoreData

let errorDomain = "Migration"

class AttachmentToImageAttachmentMigrationPolicyV3toV4:
    NSEntityMigrationPolicy {
  
  override func createDestinationInstances(
      forSource sInstance: NSManagedObject,
      `in` mapping: NSEntityMapping,
      manager: NSMigrationManager) throws {
    
    let description = NSEntityDescription.entity(
        forEntityName: "ImageAttachment",
        in: manager.destinationContext)
    let newImageAttachment = ImageAttachment(
        entity: description!,
        insertInto: manager.destinationContext)
    
    func traversePropertyMappings(
        block: (NSPropertyMapping, String) -> ()) throws {
      if let attributeMappings = mapping.attributeMappings {
        for propertyMapping in attributeMappings {
          if let destinationName = propertyMapping.name {
            block(propertyMapping, destinationName)
          } else {
            let message = "Attribute destination not configured properly"
            let userInfo = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
          }
        }
      } else {
        let message = "No Attribute Mappings found!"
        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
        throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
      }
    }
    
    try traversePropertyMappings {
      propertyMapping, destinationName in
      if let valueExpression = propertyMapping.valueExpression {
        let context: NSMutableDictionary = ["source": sInstance]
        guard let destinationValue = valueExpression.expressionValue(
            with: sInstance, context: context) else { return }
        newImageAttachment.setValue(destinationValue, forKey: destinationName)
      }
    }
    
    if let image = sInstance.value(forKey: "image") as? UIImage {
      newImageAttachment.setValue(image.size.width, forKey: "width")
      newImageAttachment.setValue(image.size.height, forKey: "height")
    }
    
    let body = sInstance.value(forKeyPath: "note.body") as? NSString ?? ""
    newImageAttachment.setValue(body.substring(to: 80), forKey: "caption")
    
    manager.associate(sourceInstance: sInstance,
                      withDestinationInstance: newImageAttachment,
                      for: mapping)
  }
}
