import Foundation

extension Date {
    // 2023년 11월 17일의 문자열 형태로 날짜 변환 함수
    func convertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        return dateFormatter.string(from: self)
    }
    
    var onlyDate: Date {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: component) ?? Date()
    }
    
    var onlyIntDay: Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0
    }
    
    // 2024.01.16(화)
    func convertDatePlusDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: self)
    }
    
}
