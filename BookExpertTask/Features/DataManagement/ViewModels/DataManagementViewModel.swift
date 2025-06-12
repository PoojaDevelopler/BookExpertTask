import Foundation
import CoreData

@MainActor
class DataManagementViewModel: ObservableObject {
    @Published var items: [APIObjectEntity] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText = ""
    
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    private let notificationManager = NotificationManager.shared
    
    var filteredItems: [APIObjectEntity] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { item in
            item.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    init() {
        loadItems()
    }
    
    enum ValidationError: LocalizedError {
        case emptyName
        case emptyData
        
        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Name cannot be empty."
            case .emptyData:
                return "Data must contain at least one key-value pair."
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadItems() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // First, try to load from Core Data
                items = coreDataManager.fetchAllAPIObjects()
                
                // Then, fetch from API and update Core Data
                let apiItems = try await networkManager.fetchObjects()
                
                // Update Core Data with new items
                for item in apiItems {
                    if let id = item["id"] as? String,
                       let name = item["name"] as? String {
                        coreDataManager.saveAPIObject(id: id, name: name, data: item)
                    }
                }
                
                // Reload items from Core Data
                items = coreDataManager.fetchAllAPIObjects()
                
            } catch {
                self.error = error
            }
            
            isLoading = false
        }
    }
    
    // MARK: - CRUD Operations
    
    func createItem(name: String, data: [String: Any]) {
        isLoading = true
        error = nil

        // ✅ Input validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.error = ValidationError.emptyName
            isLoading = false
            return
        }
        
        guard !data.isEmpty else {
            self.error = ValidationError.emptyData
            isLoading = false
            return
        }

        Task {
            do {
                let newItem = try await networkManager.createObject(["name": name, "data": data])
                if let id = newItem["id"] as? String {
                    coreDataManager.saveAPIObject(id: id, name: name, data: newItem)
                    items = coreDataManager.fetchAllAPIObjects()
                }
            } catch {
                self.error = error
            }

            isLoading = false
        }
    }
    
    func updateItem(_ item: APIObjectEntity, name: String, data: [String: Any]) {
        guard let id = item.id else { return }

        isLoading = true
        error = nil

        // ✅ Input validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.error = ValidationError.emptyName
            isLoading = false
            return
        }

        guard !data.isEmpty else {
            self.error = ValidationError.emptyData
            isLoading = false
            return
        }

        Task {
            do {
                let updatedItem = try await networkManager.updateObject(id: id, object: ["name": name, "data": data])
                coreDataManager.updateAPIObject(id: id, name: name, data: updatedItem)
                items = coreDataManager.fetchAllAPIObjects()
            } catch {
                self.error = error
            }

            isLoading = false
        }
    }
    
    func deleteItem(_ item: APIObjectEntity) {
        guard let id = item.id else { return }
        notificationManager.sendDeleteNotification(title: "Item Deleted", msgBody: "\(item.name ?? "Item") has been deleted from your list.")

        isLoading = true
        error = nil
        
        Task {
            do {
                try await networkManager.deleteObject(id: id)
                coreDataManager.deleteAPIObject(id: id)
                items = coreDataManager.fetchAllAPIObjects()
                
                // notification for deleted item
                notificationManager.sendDeleteNotification(title: "Item Deleted", msgBody: "\(item.name ?? "Item") has been deleted from your list.")
            } catch {
                self.error = error
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Search
    
    func clearSearch() {
        searchText = ""
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: Error) {
        self.error = error
    }
    
    func clearError() {
        self.error = nil
    }
} 
