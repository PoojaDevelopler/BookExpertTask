import SwiftUI
import Foundation

struct DataManagementView: View {
    @StateObject private var viewModel = DataManagementViewModel()
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var selectedItem: APIObjectEntity?
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: APIObjectEntity?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else {
                    listView
                }
            }
            .navigationTitle("Data Management")
            .searchable(text: $viewModel.searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.loadItems()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ItemFormView(mode: .add) { name, data in
                    viewModel.createItem(name: name, data: data)
                }
            }
            .sheet(item: $selectedItem) { item in
                ItemFormView(mode: .edit(item)) { name, data in
                    viewModel.updateItem(item, name: name, data: data)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .alert("Delete Item", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        viewModel.deleteItem(item)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this item?")
            }
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.filteredItems, id: \.id) { item in
                itemRow(item)
            }
        }
        .refreshable {
            viewModel.loadItems()
        }
    }
    
    private func itemRow(_ item: APIObjectEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
                Text(item.name ?? "Unnamed Item")
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let createdAt = item.createdAt {
                    Text("Created: \(createdAt.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button {
                    selectedItem = item
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    itemToDelete = item
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, Constants.UI.defaultSpacing)
    }
}

struct ItemFormView: View {
    enum Mode {
        case add
        case edit(APIObjectEntity)
        
        var title: String {
            switch self {
            case .add:
                return "Add Item"
            case .edit:
                return "Edit Item"
            }
        }
    }
    
    let mode: Mode
    let onSave: (String, [String: Any]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var data: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(mode: Mode, onSave: @escaping (String, [String: Any]) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .edit(let item) = mode {
            _name = State(initialValue: item.name ?? "")
            if let itemData = item.data,
               let jsonData = try? JSONSerialization.data(withJSONObject: itemData),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                _data = State(initialValue: jsonString)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextEditor(text: $data)
                        .frame(height: 200)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveItem() {
        guard !name.isEmpty else {
            errorMessage = "Name cannot be empty"
            showingError = true
            return
        }
        
        var jsonData: [String: Any] = [:]
        
        if !data.isEmpty {
            do {
                if let data = data.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    jsonData = json
                } else {
                    errorMessage = "Invalid JSON data"
                    showingError = true
                    return
                }
            } catch {
                errorMessage = "Error parsing JSON: \(error.localizedDescription)"
                showingError = true
                return
            }
        }
        
        onSave(name, jsonData)
        dismiss()
    }
}

#Preview {
    ItemFormView(mode: .add) { _, _ in }
}

#Preview {
    DataManagementView()
} 
