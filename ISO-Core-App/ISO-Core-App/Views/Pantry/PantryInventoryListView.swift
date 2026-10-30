import SwiftUI

struct PantryInventoryListView: View {
    @ObservedObject var pantryVM: PantryViewModel
    
    @State private var showingAddInventorySheet: Bool = false
    
    // Edit / Update States
    @State private var itemToEdit: PantryItem? = nil
    
    private var pantryShareText: String {
        if pantryVM.fridgeIngredients.isEmpty {
            return "My Pantry is currently empty!"
        }
        let itemsList = pantryVM.fridgeIngredients.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        return "🛒 My Pantry Items List:\n\n\(itemsList)\n\nShared via SmartChef App"
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if pantryVM.fridgeIngredients.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "basket")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Your Pantry is Empty")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap '+' to add ingredients to your pantry.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
                List {
                    Section(header: Text("Stored Ingredients (\(pantryVM.fridgeIngredients.count))")) {
                        ForEach(pantryVM.fridgeIngredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.orange)
                                
                                Text(ingredient)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                // 1. Update (Edit) Button
                                Button {
                                    itemToEdit = pantryVM.pantryItem(named: ingredient) ?? PantryItem(
                                        name: ingredient,
                                        category: "Vegetables",
                                        storageLocation: "Fridge",
                                        quantity: 1,
                                        unit: "pcs",
                                        expiryDate: Date().addingTimeInterval(86400 * 7),
                                        expiryAlertDays: 1,
                                        notes: nil
                                    )
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.borderless)
                                
                                // 2. Delete Button
                                Button {
                                    withAnimation {
                                        pantryVM.removeIngredient(ingredient)
                                    }
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let itemToRemove = pantryVM.fridgeIngredients[index]
                                pantryVM.removeIngredient(itemToRemove)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("My Pantry Items")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    // 1. Share Icon (Family Members ge List Share madalu)
                    if !pantryVM.fridgeIngredients.isEmpty {
                        ShareLink(item: pantryShareText) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Circle())
                        }
                    }
                    
                    // 2. Plus (+) Icon (Add Inventory Sheet open madalu)
                    Button {
                        showingAddInventorySheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(8)
                            .background(Color.orange.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
            }
        }
        // Add Sheet Modal (AddInventoryView)
        .sheet(isPresented: $showingAddInventorySheet) {
            AddInventoryView { newItem in
                pantryVM.addPantryItem(newItem)
            }
        }
        // Edit Sheet Modal (same form, Edit Inventory title)
        .sheet(item: $itemToEdit) { existingItem in
            AddInventoryView(existingItem: existingItem) { updatedItem in
                pantryVM.updatePantryItem(oldName: existingItem.name, updatedItem: updatedItem)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PantryInventoryListView(pantryVM: PantryViewModel())
    }
}
