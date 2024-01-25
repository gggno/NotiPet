import Foundation

extension Date {
    // 2023년 11월 17일의 문자열 형태로 날짜 변환 함수
    func convertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        return dateFormatter.string(from: self)
    }
    
    // 년, 월, 일의 Date 타입으로 반환하는 클로저
    var onlyDate: Date {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: component) ?? Date()
    }
    
    // 일을 Int 타입으로 반환하는 클로저
    var onlyIntDay: Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0
    }
    
    // 시간, 분을 String 타입으로 반환하는 함수
    func onlyTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.string(from: self)
    }
    
    // 2024.01.16(화)
    func convertDatePlusDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: self)
    }
    
}
