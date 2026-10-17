import Foundation

struct PantryItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var category: String
    var storageLocation: String
    var quantity: Int
    var unit: String
    var expiryDate: Date
    var expiryAlertDays: Int
    var notes: String?

    var isExpiringSoon: Bool {
            let calendar = Calendar.current
            if let alertDate = calendar.date(byAdding: .day, value: -expiryAlertDays, to: expiryDate) {
                return Date() >= alertDate && Date() <= expiryDate
            }
            return false
        }
    }
