import Foundation

extension String {
    
    // 2018년 05월 09일 -> 2038일 로 변환하는 함수
    func dayConvertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let targetDate = dateFormatter.date(from: self)!
        
        // 현재 날짜 얻어오기
        let currentDate = Date()

        // 날짜 차이 계산
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: targetDate, to: currentDate)

        // 차이 출력
        if let daysDifference = components.day {
            return "\(abs(daysDifference)+1)"
        } else {
            return ""
        }
    }

}
