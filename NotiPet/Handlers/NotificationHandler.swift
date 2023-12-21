import Foundation
import UserNotifications

class NotificationHandler {
    static let shered = NotificationHandler() // 싱글톤으로 설정
    
    // 알림 허용 요청 보내기
    func askPermisson() {
        print("NotificationHandler - askPermisson() called")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge,]) { success, error in
            if let error = error {
                print("NotificationHandler - 알림 요청 에러: \(error.localizedDescription)")
                return
            } else {
                print("NotificationHandler - 알림 요청 허용")
            }
        }
    }
    
    // 기념일 알림 등록
    func anniversaryNotification(identifier: String, dateString: String, title: String, body: String) {
        print("NotificationHandler - anniversaryNotification() called")
        
        // DateFormatter를 사용하여 문자열로부터 Date로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        if let anniversaryDate = dateFormatter.date(from: dateString) {
            // UNUserNotificationCenter 인스턴스 가져오기
            let center = UNUserNotificationCenter.current()
            
            // 알림 내용 설정
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            
            // 알림이 울리게 설정 (선택 사항)
            content.sound = UNNotificationSound.default
            
            // 알림 요청 생성
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: anniversaryDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // 알림 요청 등록
            center.add(request) { error in
                if let error = error {
                    print("로컬 푸시 등록 실패: \(error.localizedDescription)")
                } else {
                    print("로컬 푸시 등록 성공: \(request)")
                }
            }
        } else {
            print("날짜 형식이 잘못되었습니다.")
        }
    }
    
    // 등록된 로컬 푸시 삭제
    func removeRegisteredNotification(identifiers: String) {
        print("NotificationHandler - removeRegisteredNotification() called")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifiers])
    }
    
    // 등록된 로컬 푸시 목록 보기
    func checkRegisteredNotification() {
        print("NotificationHandler - checkRegisteredNotification() called")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("----------")
                print("Identifier: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                print("trigger: \(request.trigger)")
                print("----------")
            }
        }
    }
    
}
