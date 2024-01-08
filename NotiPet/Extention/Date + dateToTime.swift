import Foundation

extension Date {
    func dateToTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h시 m분"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: self)
    }
}
