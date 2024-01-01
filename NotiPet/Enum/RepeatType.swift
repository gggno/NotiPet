import Foundation

enum RepeatType: CaseIterable {
    case none
    case everyday
    case everyweak
    case everymonth
    case everythreemonths
    case everysixmonths
    case everyYear
    
    var displayName: String {
        switch self {
        case .none:
            return "안 함"
        case .everyday:
            return "매일"
        case .everyweak:
            return "매주"
        case .everymonth:
            return "매월"
        case .everythreemonths:
            return "3개월마다"
        case .everysixmonths:
            return "6개월마다"
        case .everyYear:
            return "매년"
        }
    }
}
