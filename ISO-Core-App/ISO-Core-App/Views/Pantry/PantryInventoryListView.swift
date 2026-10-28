import SwiftUI

struct PantryInventoryListView: View {
    @ObservedObject var pantryVM: PantryViewModel
    

    @State private var showingAddInventorySheet: Bool = false
    
    // Edit / Update States
    @State private var itemToEdit: String? = nil
    @State private var updatedIngredientName: String = ""
    @State private var showingUpdateAlert: Bool = false
    
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
                                    itemToEdit = ingredient
                                    updatedIngredientName = ingredient
                                    showingUpdateAlert = true
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
        // Add Sheet Modal (AddInventoryView)
        .sheet(isPresented: $showingAddInventorySheet) {
            AddInventoryView { newItem in
                pantryVM.addIngredient(newItem.name)
            }
        }
        // Update Alert Modal
        .alert("Update Ingredient", isPresented: $showingUpdateAlert) {
            TextField("Ingredient Name", text: $updatedIngredientName)
            Button("Save") {
                if let oldItem = itemToEdit,
                   !updatedIngredientName.trimmingCharacters(in: .whitespaces).isEmpty {
                    
                    pantryVM.updateIngredient(oldItem: oldItem, newItem: updatedIngredientName)
                    
                    itemToEdit = nil
                    updatedIngredientName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                itemToEdit = nil
                updatedIngredientName = ""
            }
        } message: {
            Text("Edit the name of the selected pantry item.")
        }
    }
}

#Preview {
    NavigationStack {
        PantryInventoryListView(pantryVM: PantryViewModel())
    }
}
