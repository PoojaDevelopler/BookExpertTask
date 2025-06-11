import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookExpertTask")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - User Management
    
    func saveUser(userId: String, email: String, name: String) {
        let user = UserEntity(context: context)
        user.userId = userId
        user.email = email
        user.name = name
        user.createdAt = Date()
        
        saveContext()
    }
    
    func fetchUser(userId: String) -> UserEntity? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    // MARK: - Context Management
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - API Object Management
    
    func saveAPIObject(id: String, name: String, data: [String: Any]) {
        let object = APIObjectEntity(context: context)
        object.id = id
        object.name = name
        object.data = data
        object.createdAt = Date()
        
        saveContext()
    }
    
    func fetchAllAPIObjects() -> [APIObjectEntity] {
        let fetchRequest: NSFetchRequest<APIObjectEntity> = APIObjectEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching API objects: \(error)")
            return []
        }
    }
    
    func updateAPIObject(id: String, name: String, data: [String: Any]) {
        let fetchRequest: NSFetchRequest<APIObjectEntity> = APIObjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try context.fetch(fetchRequest)
            if let object = objects.first {
                object.name = name
                object.data = data
                object.updatedAt = Date()
                saveContext()
            }
        } catch {
            print("Error updating API object: \(error)")
        }
    }
    
    func deleteAPIObject(id: String) {
        let fetchRequest: NSFetchRequest<APIObjectEntity> = APIObjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try context.fetch(fetchRequest)
            if let object = objects.first {
                context.delete(object)
                saveContext()
            }
        } catch {
            print("Error deleting API object: \(error)")
        }
    }
} 