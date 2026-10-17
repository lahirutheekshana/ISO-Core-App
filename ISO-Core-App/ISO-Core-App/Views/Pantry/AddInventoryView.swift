import SwiftUI

struct AddInventoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: String = "Vegetables"
    @State private var storageLocation: String = "Fridge"
    @State private var quantity: Int = 1
    @State private var unit: String = "pcs"
    @State private var expiryAlertDays: Int = 1
    @State private var expiryDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var expiryReminder: Bool = true
    @State private var notes: String = ""
    
    let categories = ["Vegetables", "Dairy", "Fruits", "Meat", "Spices", "Grains"]
    let locations = ["Fridge", "Pantry", "Freezer"]
    let units = ["pcs", "kg", "g", "l", "ml", "pack"]
    
    var onSave: (PantryItem) -> Void
    
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
            .navigationTitle("Add Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = PantryItem(
                            name: name,
                            category: category,
                            storageLocation: storageLocation,
                            quantity: quantity,
                            unit: unit,
                            expiryDate: expiryDate,
                            expiryAlertDays: expiryAlertDays,
                            notes: notes.isEmpty ? nil : notes
                        )
                        
                        if expiryReminder {
                            NotificationManager.shared.scheduleExpiryNotification(for: newItem)
                        }
                        
                        onSave(newItem)
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

