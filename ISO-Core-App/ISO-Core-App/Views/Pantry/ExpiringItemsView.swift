import SwiftUI

struct ExpiringItemsView: View {
    @ObservedObject var pantryVM: PantryViewModel

    private var expiringItems: [PantryItem] {
        pantryVM.pantryItems.filter { $0.isExpiringSoon }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if expiringItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.8))
                    Text("No Expiring Ingredients")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("All stored pantry items are fresh!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    Section(header: Text("Items Expiring Soon (\(expiringItems.count))")) {
                        ForEach(expiringItems) { item in
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.body)
                                        .fontWeight(.semibold)

                                    HStack(spacing: 6) {
                                        Text("Expires: \(item.expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.red)

                                        Text("• \(item.quantity) \(item.unit)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Button {
                                    withAnimation {
                                        pantryVM.removeIngredient(item.name)
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
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Expiring Soon")
        .navigationBarTitleDisplayMode(.inline)
    }
}
