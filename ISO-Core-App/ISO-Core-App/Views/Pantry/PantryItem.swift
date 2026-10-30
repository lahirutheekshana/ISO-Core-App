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
        let today = calendar.startOfDay(for: Date())
        let expiryDay = calendar.startOfDay(for: expiryDate)

        guard let alertDay = calendar.date(byAdding: .day, value: -expiryAlertDays, to: expiryDay) else {
            return false
        }

        return today >= alertDay && today <= expiryDay
    }
}
