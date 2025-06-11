import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        var container = NSPersistentContainer(name: "BookExpert")
        
        // Create the model if it doesn't exist
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "SavedImage"
        entity.managedObjectClassName = "SavedImage"
        
        // Add attributes
        let imageDataAttr = NSAttributeDescription()
        imageDataAttr.name = "imageData"
        imageDataAttr.attributeType = .binaryDataAttributeType
        entity.properties.append(imageDataAttr)
        
        let creationDateAttr = NSAttributeDescription()
        creationDateAttr.name = "creationDate"
        creationDateAttr.attributeType = .dateAttributeType
        entity.properties.append(creationDateAttr)
        
        // Add entity to model
        model.entities = [entity]
        
        container = NSPersistentContainer(name: "BookExpert", managedObjectModel: model)
        
        do {
             container.loadPersistentStores { description, error in
                if let error = error {
                    print("CoreData Error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to load persistent stores: \(error.localizedDescription)")
        }
        
        return container
    }()
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    func createContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

}
