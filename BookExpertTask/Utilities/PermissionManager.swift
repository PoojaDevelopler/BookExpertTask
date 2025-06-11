import AVFoundation
import Photos
import UIKit

enum PermissionError: Error {
    case denied
    case restricted
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .denied:
            return "Permission denied. Please enable access in Settings."
        case .restricted:
            return "Permission restricted. This device does not allow access."
        case .unknown:
            return "Unknown permission error occurred."
        }
    }
}

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    // MARK: - Camera Permission
    
    func requestCameraPermission() async throws -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return  await AVCaptureDevice.requestAccess(for: .video)
        case .denied:
            throw PermissionError.denied
        case .restricted:
            throw PermissionError.restricted
        @unknown default:
            throw PermissionError.unknown
        }
    }
    
    func checkCameraPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    // MARK: - Photo Library Permission
    
    func requestPhotoLibraryPermission() async throws -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return  await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        case .denied:
            throw PermissionError.denied
        case .restricted:
            throw PermissionError.restricted
        @unknown default:
            throw PermissionError.unknown
        }
    }
    
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    // MARK: - Settings
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
} 
