
import UserNotifications

func close() {
    NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
}
