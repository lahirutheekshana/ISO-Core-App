import SwiftUI

struct AddInventoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var category: String
    @State private var storageLocation: String
    @State private var quantity: Int
    @State private var unit: String
    @State private var expiryAlertDays: Int
    @State private var expiryDate: Date
    @State private var expiryReminder: Bool
    @State private var notes: String
    
    private let existingItem: PantryItem?
    
    let categories = ["Vegetables", "Dairy", "Fruits", "Meat", "Spices", "Grains"]
    let locations = ["Fridge", "Pantry", "Freezer"]
    let units = ["pcs", "kg", "g", "l", "ml", "pack"]
    
    var onSave: (PantryItem) -> Void
    
    private var isEditing: Bool {
        existingItem != nil
    }
    
    private var navigationTitleText: String {
        isEditing ? "Edit Inventory" : "Add Inventory"
    }
    
    init(existingItem: PantryItem? = nil, onSave: @escaping (PantryItem) -> Void) {
        self.existingItem = existingItem
        self.onSave = onSave
        
        _name = State(initialValue: existingItem?.name ?? "")
        _category = State(initialValue: existingItem?.category ?? "Vegetables")
        _storageLocation = State(initialValue: existingItem?.storageLocation ?? "Fridge")
        _quantity = State(initialValue: existingItem?.quantity ?? 1)
        _unit = State(initialValue: existingItem?.unit ?? "pcs")
        _expiryAlertDays = State(initialValue: existingItem?.expiryAlertDays ?? 1)
        _expiryDate = State(initialValue: existingItem?.expiryDate ?? Date().addingTimeInterval(86400 * 7))
        _expiryReminder = State(initialValue: existingItem?.expiryReminderEnabled ?? true)
        _notes = State(initialValue: existingItem?.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("GENERAL INFO")) {
                    TextField("Ingredient Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    
                    Picker("Storage Location", selection: $storageLocation) {
                        ForEach(locations, id: \.self) { Text($0) }
                    }
                }
                
                Section(header: Text("QUANTITY & EXPIRY")) {
                    Stepper(value: $quantity, in: 1...99) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity) \(unit)").bold()
                        }
                    }
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    
                    Stepper(value: $expiryAlertDays, in: 1...14) {
                        HStack {
                            Text("Expiry Alert Days")
                            Spacer()
                            Text("\(expiryAlertDays) day(s)").bold()
                        }
                    }
                }
                
                Section(header: Text("EXPIRY DATE")) {
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    
                    Toggle("Expiry Reminder", isOn: $expiryReminder)
                }
                
                Section(header: Text("NOTES")) {
                    TextField("Optional notes...", text: $notes)
                }
            }
            .navigationTitle(navigationTitleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let savedItem = PantryItem(
                            id: existingItem?.id ?? UUID().uuidString,
                            name: name,
                            category: category,
                            storageLocation: storageLocation,
                            quantity: quantity,
                            unit: unit,
                            expiryDate: expiryDate,
                            expiryAlertDays: expiryAlertDays,
                            notes: notes.isEmpty ? nil : notes,
                            expiryReminderEnabled: expiryReminder
                        )
                        
                        onSave(savedItem)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                NotificationManager.shared.requestAuthorization()
            }
        }
    }
}
