import SwiftUI

struct PantryInventoryListView: View {
    @ObservedObject var pantryVM: PantryViewModel
    @State private var newIngredientName: String = ""
    @State private var showingAddAlert: Bool = false
    
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
                    showingAddAlert = true
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
        .alert("Add New Ingredient", isPresented: $showingAddAlert) {
            TextField("e.g. Butter, Milk, Garlic", text: $newIngredientName)
            Button("Add") {
                if !newIngredientName.isEmpty {
                    pantryVM.addIngredient(newIngredientName)
                    newIngredientName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newIngredientName = ""
            }
        } message: {
            Text("Enter the name of the ingredient to save to your pantry.")
        }
    }
}

#Preview {
    NavigationStack {
        PantryInventoryListView(pantryVM: PantryViewModel())
    }
}
