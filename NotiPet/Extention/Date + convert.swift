import Foundation

extension Date {
    // 2023년 11월 17일의 형태로 날짜 변환 함수
    func convertDate() -> String {
        // print(Realm.Configuration.defaultConfiguration.fileURL!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        return dateFormatter.string(from: self)
    }
}
