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
    /// When false, no local expiry notification is scheduled for this item.
    var expiryReminderEnabled: Bool = true

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
