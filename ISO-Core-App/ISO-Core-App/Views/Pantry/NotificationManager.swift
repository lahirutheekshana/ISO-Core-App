import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
  
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification Authorization Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func scheduleExpiryNotification(for item: PantryItem) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Expiry Alert: \(item.name)"
        content.body = "\(item.name) කල් ඉකුත් වීමට තව දවස් \(item.expiryAlertDays) යි තියෙන්නේ!"
        content.sound = .default
        
        let calendar = Calendar.current
        if let notifyDate = calendar.date(byAdding: .day, value: -item.expiryAlertDays, to: item.expiryDate) {
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification Schedule Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
