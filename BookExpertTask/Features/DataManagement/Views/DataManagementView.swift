import SwiftUI
import Foundation

struct DataManagementView: View {
    @StateObject private var viewModel = DataManagementViewModel()
    @State private var showingAddSheet = false
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
            .onDelete(perform: deleteItems)
        }
        .refreshable {
            viewModel.loadItems()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = viewModel.filteredItems[index]
            viewModel.deleteItem(item)
        }
    }
    
    private func itemRow(_ item: APIObjectEntity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(item.name ?? "Unnamed Item")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Created date (if any)
                    if let createdAt = item.createdAt {
                        Text("Created: \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Action menu
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
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 2)
        .padding(.vertical, 2)
    }
}


struct ItemFormView: View {
    enum Mode {
        case add
        case edit(APIObjectEntity)

        var title: String {
            switch self {
            case .add: return "Add Item"
            case .edit: return "Edit Item"
            }
        }
    }

    let mode: Mode
    let onSave: (String, [String: Any]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var itemID: String? = nil
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var color: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    init(mode: Mode, onSave: @escaping (String, [String: Any]) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let item) = mode {
            _itemID = State(initialValue: item.id)
            _name = State(initialValue: item.name ?? "")
            if let data = item.data {
                _price = State(initialValue: "\(data["price"] ?? "")")
                _color = State(initialValue: "\(data["color"] ?? "")")
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // Section: Item Info (Top-level)
                Section(header: Text("Item Info")) {
                    if let itemID = itemID {
                        HStack {
                            Text("ID")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(itemID)
                                .font(.subheadline)
                        }
                    }

                    TextField("Name", text: $name)
                }

                // Section: Data
                Section(header: Text("Item Data")) {
                    HStack {
                        Text("Price")
                            .frame(width: 80, alignment: .leading)
                        TextField("Enter price", text: $price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Color")
                            .frame(width: 80, alignment: .leading)
                        TextField("Enter color", text: $color)
                            .textFieldStyle(.roundedBorder)
                    }
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
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name cannot be empty"
            showingError = true
            return
        }

        var dataDict: [String: Any] = [:]

        if let priceValue = Double(price) {
            dataDict["price"] = priceValue
        } else if !price.isEmpty {
            dataDict["price"] = price
        }

        if !color.trimmingCharacters(in: .whitespaces).isEmpty {
            dataDict["color"] = color
        }

        onSave(name, dataDict)
        dismiss()
    }
}

#Preview {
    ItemFormView(mode: .add) { _, _ in }
}

#Preview {
    DataManagementView()
} 
