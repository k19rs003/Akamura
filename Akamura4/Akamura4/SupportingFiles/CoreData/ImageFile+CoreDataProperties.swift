//
//  ImageFile+CoreDataProperties.swift
//  Akamura4-Swift
//
//  Created by Yota Tamai on 2021/12/11.
//
//

import Foundation
import CoreData


extension ImageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageFile> {
        return NSFetchRequest<ImageFile>(entityName: "ImageFile")
    }

    @NSManaged public var url: String?

}

extension ImageFile : Identifiable {

}
