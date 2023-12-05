import Foundation

extension String {
    
    func dayConvertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let targetDate = dateFormatter.date(from: self)!
        
        // 현재 날짜를 얻어옵니다.
        let currentDate = Date()

        // 날짜 차이를 계산합니다.
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: targetDate, to: currentDate)

        // 차이를 출력합니다.
        if let daysDifference = components.day {
            return "\(abs(daysDifference)+1)"
        } else {
            return ""
        }
    }

}
