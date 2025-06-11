import SwiftUI
import PhotosUI

struct ImageHandlerView: View {
    @ObservedObject var viewModel: ImageHandlerViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showTopIcon = true
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: Constants.UI.defaultSpacing * 2) {
                ScrollView {
                    showSavedImage()
                }
                Spacer()
                HStack(spacing: Constants.UI.defaultSpacing) {
                    cameraButton
                    photoLibraryButton
                }
                .padding(.vertical)
            }
            .onChange(of: viewModel.selectedImage) { newImage in
                if newImage != nil {
                    Task {
                         viewModel.saveCurrentImage()
                        withAnimation {
                            showToast = true
                            toastMessage = "Image saved successfully"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showToast = false
                        }
                    }
                }
                
                
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.large)
            
            //  the toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            viewModel.saveCurrentImage()
                            withAnimation {
                                showToast = true
                                toastMessage = "Image saved successfully"
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                }
                            }
                        }
                    }) {
                        //                        Image(systemName: "checkmark.circle.fill")
                        //                            .font(.system(size: 24))
                        //                            .foregroundColor(.blue)
                    }
                }
            }
            
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage, sourceType: sourceType)
            }
            .sheet(isPresented: $showCamera) {
                if viewModel.isCameraEnabled {
                    CameraView(image: $viewModel.selectedImage)
                }
            }
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    PermissionManager.shared.openSettings()
                }
            } message: {
                Text(permissionAlertMessage)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .overlay(
                Group {
                    if showToast {
                        VStack {
                            Spacer()
                            Text(toastMessage)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .transition(.slide)
                    }
                }
            )
        }
    }

    private func showSavedImage() -> some View {
        Group {
            if !viewModel.savedImages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Previous Images")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(Array(viewModel.savedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 3 - 15,
                                           height: UIScreen.main.bounds.width / 3 - 15)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                                
                                // 🔴 Delete icon
                                Button(action: {
                                    viewModel.deleteImage(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: -5, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                Text("No saved images yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var cameraButton: some View {
        Button {
            Task {
                do {
                    if try await viewModel.requestCameraAccess() {
                        showCamera = true
                    } else {
                        permissionAlertMessage = "Camera access is required to take photos."
                        showPermissionAlert = true
                    }
                } catch {
                    viewModel.error = error
                }
            }
        } label: {
            HStack {
                Image(systemName: "camera")
                Text("Take Photo")
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.defaultButtonHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.defaultCornerRadius)
        }
    }
    
    private var photoLibraryButton: some View {
        Button {
            Task {
                do {
                    if try await viewModel.requestPhotoLibraryAccess() {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    } else {
                        permissionAlertMessage = "Photo library access is required to select photos."
                        showPermissionAlert = true
                    }
                } catch {
                    viewModel.error = error
                }
            }
        } label: {
            HStack {
                Image(systemName: "photo.on.rectangle")
                Text("Choose Photo")
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.defaultButtonHeight)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.defaultCornerRadius)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ImageHandlerView(viewModel: ImageHandlerViewModel())
}
