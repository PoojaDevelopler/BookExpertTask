import Foundation
import SwiftUI
import PhotosUI
import CoreData
import UserNotifications

@MainActor
class ImageHandlerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var savedImages: [UIImage] = []
    private let permissionManager = PermissionManager.shared
    private let container: NSPersistentContainer
    private let notificationManager = NotificationManager.shared

    init() {
        container = CoreDataStack.shared.persistentContainer
        
        // Load saved images on initialization
        loadSavedImages()
        
        // Create the SavedImage entity if it doesn't exist
        createSavedImageEntity()
    }
    
    private func createSavedImageEntity() {
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SavedImage", in: context)
        if entity == nil {
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
            let model = context.persistentStoreCoordinator?.managedObjectModel
            model?.entities.append(entity)
            
            do {
                try context.save()
            } catch {
                print("Error creating entity: \(error.localizedDescription)")
            }
        }
    }
    
    func loadSavedImages() {
        do {
            let context = container.viewContext
            let request = NSFetchRequest<SavedImage>(entityName: "SavedImage")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedImage.creationDate, ascending: false)]
            
            let savedImages = try context.fetch(request)
            self.savedImages = savedImages.compactMap { savedImage in
                if let imageData = savedImage.imageData,
                   let uiImage = UIImage(data: imageData) {
                    return uiImage
                }
                return nil
            }
        } catch {
            print("Error loading saved images: \(error.localizedDescription)")
            self.savedImages = []
        }
    }
    
    
    @Published var isCameraEnabled = true
    
    func saveCurrentImage() {
        guard let image = selectedImage else { return }
        
        isLoading = true
        
        // Resize the image before saving
        if let resizedImage = resizeImage(image) {
            do {
                // Create background context for saving
                let context = CoreDataStack.shared.createContext()
                
                // Create a new SavedImage entity
                let newImage = NSEntityDescription.insertNewObject(forEntityName: "SavedImage", into: context) as! SavedImage
                newImage.imageData = resizedImage.jpegData(compressionQuality: 0.8)
                newImage.creationDate = Date()
                
                try context.save()
                
                // Update main context
                try container.viewContext.save()
                
                // Reload images on main thread
                DispatchQueue.main.async {
                    self.loadSavedImages()
                    self.isLoading = false
                }
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                self.error = error
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func deleteImage(at index: Int) {
        guard index >= 0 && index < savedImages.count else { return }
        
        let imageToDelete = savedImages[index]
        
        let request: NSFetchRequest<SavedImage> = SavedImage.fetchRequest()
        
        do {
            let results = try container.viewContext.fetch(request)
            
            for savedImage in results {
                if let data = savedImage.imageData,
                   let uiImage = UIImage(data: data),
                   uiImage.pngData() == imageToDelete.pngData() {
                    container.viewContext.delete(savedImage)
                    try container.viewContext.save()
                    break
                }
            }
            
            savedImages.remove(at: index)
            notificationManager.sendDeleteNotification(title: "Image Deleted", msgBody: "An image has been removed from your saved list.")
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
            self.error = error
        }
    }
    
 
    
    // MARK: - Camera Access
    func requestCameraAccess() async throws -> Bool {
        return try await permissionManager.requestCameraPermission()
    }
    
    func checkCameraPermission() -> AVAuthorizationStatus {
        return permissionManager.checkCameraPermission()
    }
    
    // MARK: - Photo Library Access
    
    func requestPhotoLibraryAccess() async throws -> Bool {
        return try await permissionManager.requestPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        return permissionManager.checkPhotoLibraryPermission()
    }
    
    // MARK: - Image Processing
    
    func processSelectedImage(_ image: UIImage) {
        // Resize image if needed
        if let resizedImage = resizeImage(image) {
            self.selectedImage = resizedImage
        } else {
            self.selectedImage = image
        }
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1024) -> UIImage? {
        let originalSize = image.size
        let aspectRatio = originalSize.width / originalSize.height
        
        var newSize: CGSize
        if originalSize.width > originalSize.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
   
}
