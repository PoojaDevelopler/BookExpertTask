import Foundation
import CoreData

@objc(SavedImage)
public class SavedImage: NSManagedObject {
    @NSManaged public var imageData: Data?
    @NSManaged public var creationDate: Date?
    
    public class func fetchRequest() -> NSFetchRequest<SavedImage> {
        return NSFetchRequest<SavedImage>(entityName: "SavedImage")
    }
}
