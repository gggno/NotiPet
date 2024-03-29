import SwiftUI
import Combine
import RealmSwift

class NotiViewModel: ObservableObject {
    
    @Published var identifier: [String] = []
    @Published var content: String = ""
    @Published var memo: String = ""
    @Published var notiDate: Date = Date()
    @Published var daysString: String = ""
    @Published var repeatTypeDisplayName: String = ""
    @Published var notiUIImage: UIImage? = nil
    
    @Published var notiDatas: [NotiData] = []
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("NotiViewModel init() called")
        getNotiInfoFromDB()
        
        // 추가한 알림 데이터 받기
        NotificationCenter.default.addObserver(self, selector: #selector(recievedNotiData(_:)), name: NSNotification.Name("notiData"), object: nil)
        
        // 기존 알림 데이터 수정하기
        NotificationCenter.default.addObserver(self, selector: #selector(modifyDeleteNotiData(_:)), name: NSNotification.Name("modifyDataIdentifer"), object: nil)
    }
    
    func getNotiInfoFromDB() {
        print("NotiViewModel - getNotiInfoFromDB() called")
        if let data = realm.objects(PetInfo.self).first?.notiDatas {
            print("getNotiInfoFromDB() - 로컬디비에 정보가 있다.")
            
            notiDatas = filteredDatas(notiDatas: Array(data)).sorted{$0.notiDate < $1.notiDate}
        }
    }
    
    // 날짜 업데이트
    func filteredDatas(notiDatas: [NotiData]) -> [NotiData] {
        print("NotiViewModel - filteredDatas() called")
        var filterDatas: [NotiData] = []
        let currentDate = Date()
        var addDate = Date()
        
        for item in notiDatas {
            switch item.repeatTypeDisplayName {
            case RepeatType.everyday.displayName:
                print("everyday")
                if item.notiDate.onlyDate < currentDate.onlyDate { // 알림 날짜가 지났으면
                    
                    let day = Calendar.current.dateComponents([.day], from: item.notiDate.onlyDate, to: currentDate.onlyDate.onlyDate).day ?? 0
                    
                    let addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: Calendar.current.date(byAdding: .day, value: day, to: item.notiDate) ?? Date(),
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    
                    filterDatas.append(addData)
                    
                } else {
                    filterDatas.append(item)
                }
            case RepeatType.everyweak.displayName:
                print("everyweek")
                
                let currentWeekday = Calendar.current.dateComponents([.weekday], from: currentDate.onlyDate).weekday ?? 0
                
                if item.notiDate.onlyDate < currentDate.onlyDate {
                    var addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: item.notiDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    
                    if let nextWeekday = item.weekDays.first(where: {$0 >= currentWeekday}) {    // 이번주에 남아있는 요일이 있을 때
                        print("이번주에 남아있는 요일이 있는 경우")
                        
                        let filterDate = Calendar.current.date(byAdding: .weekday, value: nextWeekday-currentWeekday, to: currentDate) ?? Date()
                        
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: filterDate)
                        var newDateComponents = calendar.dateComponents(in: calendar.timeZone, from: item.notiDate)
                        newDateComponents.year = components.year
                        newDateComponents.month = components.month
                        newDateComponents.day = components.day
                        
                        addData.notiDate = calendar.date(from: newDateComponents) ?? Date()
                        
                    } else {    // 이번주에 남아있는 요일이 없고 다음주로 넘어가야 할때
                        print("다음주로 넘어가야 하는 경우")
                        
                        let filterDate = Calendar.current.date(byAdding: .weekday, value: item.weekDays[0]+1, to: currentDate) ?? Date()
                        
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: filterDate)
                        var newDateComponents = calendar.dateComponents(in: calendar.timeZone, from: item.notiDate)
                        newDateComponents.year = components.year
                        newDateComponents.month = components.month
                        newDateComponents.day = components.day
                        
                        addData.notiDate = calendar.date(from: newDateComponents) ?? Date()
                    }
                    
                    filterDatas.append(addData)
                } else {
                    print("정한 날이 아직 안 왔을 때")
                    var addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: item.notiDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    let itemWeekday = Calendar.current.dateComponents([.weekday], from: item.notiDate).weekday ?? 0
                    
                    if let nextWeekday = item.weekDays.first(where: {$0 >= itemWeekday}) {    // 그 주에 남아있는 요일이 있을 때
                        print("이번주에 남아있는 요일이 있는 경우")
                        
                        let filterDate = Calendar.current.date(byAdding: .weekday, value: nextWeekday-itemWeekday, to: item.notiDate) ?? Date()
                        
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: filterDate)
                        var newDateComponents = calendar.dateComponents(in: calendar.timeZone, from: item.notiDate)
                        newDateComponents.year = components.year
                        newDateComponents.month = components.month
                        newDateComponents.day = components.day
                        
                        addData.notiDate = calendar.date(from: newDateComponents) ?? Date()
                        
                    } else {    // 그 주에 남아있는 요일이 없고 다음주로 넘어가야 할때
                        print("다음주로 넘어가야 하는 경우")
                        
                        let filterDate = Calendar.current.date(byAdding: .weekday, value: item.weekDays[0]+1, to: item.notiDate) ?? Date()
                        
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: filterDate)
                        var newDateComponents = calendar.dateComponents(in: calendar.timeZone, from: item.notiDate)
                        newDateComponents.year = components.year
                        newDateComponents.month = components.month
                        newDateComponents.day = components.day
                        
                        addData.notiDate = calendar.date(from: newDateComponents) ?? Date()
                    }
                    
                    filterDatas.append(addData)
                }
                
            case RepeatType.everymonth.displayName:
                print("everymonth")
                if item.notiDate.onlyDate < currentDate.onlyDate {
                    let itemDay = Calendar.current.dateComponents([.day], from: item.notiDate.onlyDate).day ?? 0
                    let currentDay = Calendar.current.dateComponents([.day], from: currentDate.onlyDate).day ?? 0
                    let itemComponent = Calendar.current.dateComponents([.year, .month, .day], from: item.notiDate.onlyDate)
                    let currentComponent = Calendar.current.dateComponents([.year, .month, .day], from: currentDate.onlyDate)
                    let differMonth = Calendar.current.dateComponents([.month], from: item.notiDate.onlyDate, to: currentDate.onlyDate.onlyDate).month ?? 0
                    
                    if differMonth >= 12 {   // 1년 이상이면
                        addDate = Calendar.current.date(byAdding: .year, value: differMonth/12, to: item.notiDate) ?? Date()
                        addDate = Calendar.current.date(byAdding: .month, value: differMonth%12+1, to: addDate) ?? Date()
                    } else if itemComponent == currentComponent { // 오늘이면 그냥 통과
                        addDate = item.notiDate
                    } else { // 오늘 이후면 다음달로
                        addDate = Calendar.current.date(byAdding: .month, value: differMonth+1, to: item.notiDate) ?? Date()
                    }
                    
                    let addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: addDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    filterDatas.append(addData)
                    
                } else {
                    filterDatas.append(item)
                }
            case RepeatType.everythreemonths.displayName:
                print("everythreemonths")
                
                var month: [Int] = [Calendar.current.component(.month, from: item.notiDate.onlyDate)]
                for _ in 0..<3 {
                    if ((month.last ?? 1) + 3) > 12 {
                        month.append(((month.last ?? 1) + 3) % 12)
                    } else {
                        month.append(((month.last ?? 1) + 3))
                    }
                }
                
                if item.notiDate.onlyDate < currentDate.onlyDate {
                    let calendar = Calendar.current
                    let itemComponent = calendar.dateComponents([.year, .month, .day], from: item.notiDate.onlyDate)
                    let currentComponent = calendar.dateComponents([.year, .month, .day], from: currentDate.onlyDate)
                    
                    let addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: addDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    
                    if let nextMonth = month.first(where: {$0 > currentComponent.month ?? 0}) { // 현재 해(current)에 남은게 있는 경우
                        print("현재 해(current)에 남은 달이 있는 경우")
                        
                        // month[0], [1], [2]의 달인데 해당하는 날이 아직 오지 않았을때
                        if month.contains(currentComponent.month ?? 0) && itemComponent.day ?? 0 >= currentComponent.day ?? 0 {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                            addDate = calendar.date(byAdding: .month, value: (currentComponent.month ?? 0)-((itemComponent.month ?? 0)), to: addDate) ?? Date()
                        } else {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                            addDate = calendar.date(byAdding: .month, value: nextMonth-(itemComponent.month ?? 0), to: addDate) ?? Date()
                        }
                        
                        addData.notiDate = addDate
                        
                    } else {                                                    // 현재 해(current)에 남은 달이 없어서 다음 해로 가는 경우
                        print("현재 해(current)에 남은 달이 없어서 다음 해로 가는 경우")
                        // month[3](마지막)의 달인데 해당하는 날이 아직 오지 않았을때
                        if month.contains(currentComponent.month ?? 0) && itemComponent.day ?? 0 >= currentComponent.day ?? 0 {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                            addDate = calendar.date(byAdding: .month, value: (currentComponent.month ?? 0)-((itemComponent.month ?? 0)), to: addDate) ?? Date()
                        } else {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0)+1, to: item.notiDate) ?? Date()
                            
                            var components = calendar.dateComponents(in: calendar.timeZone, from: addDate)
                            components.month = month[0]
                            addDate = calendar.date(from: components) ?? Date()
                            
                        }
                        
                        addData.notiDate = addDate
                    }
                    
                    filterDatas.append(addData)
                    
                } else {
                    filterDatas.append(item)
                }
                
            case RepeatType.everysixmonths.displayName:
                print("everysixmonths")
                
                var month: [Int] = [Calendar.current.component(.month, from: item.notiDate.onlyDate)]
                if ((month.last ?? 1) + 6) > 12 {
                    month.append(((month.last ?? 1) + 6) % 12)
                } else {
                    month.append(((month.last ?? 1) + 6))
                }
                
                if item.notiDate.onlyDate < currentDate.onlyDate {
                    let calendar = Calendar.current
                    let itemComponent = calendar.dateComponents([.year, .month, .day], from: item.notiDate.onlyDate)
                    let currentComponent = calendar.dateComponents([.year, .month, .day], from: currentDate.onlyDate)
                    
                    let addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: addDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    
                    if let nextMonth = month.first(where: {$0 > currentComponent.month ?? 0}) { // 현재 해(current)에 남은게 있는 경우
                        print("현재 해(current)에 남은 달이 있는 경우")
                        
                        // month[0]의 달인데 해당하는 날이 아직 오지 않았을때
                        if month.contains(currentComponent.month ?? 0) && itemComponent.day ?? 0 >= currentComponent.day ?? 0 {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                        } else {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                            addDate = calendar.date(byAdding: .month, value: nextMonth-(itemComponent.month ?? 0), to: addDate) ?? Date()
                        }
                        
                        addData.notiDate = addDate
                        
                    } else {                                                    // 현재 해(current)에 남은 달이 없어서 다음 해로 가는 경우
                        print("현재 해(current)에 남은 달이 없어서 다음 해로 가는 경우")
                        // month[1](마지막)의 달인데 해당하는 날이 아직 오지 않았을때
                        if month.contains(currentComponent.month ?? 0) && itemComponent.day ?? 0 >= currentComponent.day ?? 0 {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0), to: item.notiDate) ?? Date()
                            addDate = calendar.date(byAdding: .month, value: (currentComponent.month ?? 0)-((itemComponent.month ?? 0)), to: addDate) ?? Date()
                        } else {
                            addDate = calendar.date(byAdding: .year, value: (currentComponent.year ?? 0)-(itemComponent.year ?? 0)+1, to: item.notiDate) ?? Date()
                            
                            var components = calendar.dateComponents(in: calendar.timeZone, from: addDate)
                            components.month = month[0]
                            addDate = calendar.date(from: components) ?? Date()
                            
                        }
                        
                        addData.notiDate = addDate
                    }
                    
                    filterDatas.append(addData)
                } else {
                    filterDatas.append(item)
                }
                
            case RepeatType.everyYear.displayName:
                print("everyYear")
                if item.notiDate < currentDate {
                    let calendar = Calendar.current
                    let itemYear = calendar.dateComponents([.year], from: item.notiDate.onlyDate).year ?? 0
                    let currentYear = calendar.dateComponents([.year], from: currentDate.onlyDate).year ?? 0
                    let itemComponent = calendar.dateComponents([.month, .day], from: item.notiDate.onlyDate)
                    let currentComponent = calendar.dateComponents([.month, .day], from: currentDate.onlyDate)
                    let differ = calendar.dateComponents([.year], from: item.notiDate.onlyDate, to: currentDate.onlyDate)
                    
                    if itemYear < currentYear {
                        
                        if differ.year ?? 0 > 0 {           // 1년 이상 차이 날 때
                            if itemComponent == currentComponent { // 같은 달, 일 일때
                                addDate = calendar.date(byAdding: .year, value: differ.year ?? 0, to: item.notiDate) ?? Date()
                            } else {
                                addDate = calendar.date(byAdding: .year, value: (differ.year ?? 0) + 1, to: item.notiDate) ?? Date()
                            }
                        } else {
                            addDate = calendar.date(byAdding: .year, value: 1, to: item.notiDate) ?? Date()
                        }
                        
                    } else if itemYear == currentYear {     // 같은 해 일때
                        if itemComponent == currentComponent { // 같은 달, 일 일때
                            addDate = calendar.date(byAdding: .year, value: differ.year ?? 0, to: item.notiDate) ?? Date()
                        } else { // 다른 날 일때
                            addDate = calendar.date(byAdding: .year, value: 1, to: item.notiDate) ?? Date()
                        }
                    }
                    
                    let addData = NotiData(
                        identifier: item.identifier,
                        content: item.content,
                        memo: item.memo,
                        notiDate: addDate,
                        weekDays: item.weekDays,
                        daysString: item.daysString,
                        repeatTypeDisplayName: item.repeatTypeDisplayName,
                        notiUIImageData: item.notiUIImageData
                    )
                    filterDatas.append(addData)
                    
                } else {
                    filterDatas.append(item)
                }
            default:
                print("default")
                if item.notiDate.onlyDate.onlyDate >= currentDate.onlyDate.onlyDate {
                    filterDatas.append(item)
                }
            }
        }
        
        // 로컬 디비에 notiDatas를 필터 데이터로 갱신
        if let data = realm.objects(PetInfo.self).first {
            try! realm.write {
                data.notiDatas.removeAll()
                data.notiDatas.append(objectsIn: filterDatas)
            }
        }
        
        return filterDatas
    }
    
    // 추가한 알림 데이터 받기
    @objc func recievedNotiData(_ notification: NSNotification) {
        print("NotiViewModel - recievedNotiData() called")
        
        if let userInfo = notification.userInfo,
           let notiData = userInfo["notiDatas"] as? NotiData {
            
            notiDatas.append(notiData)
            notiDatas = filteredDatas(notiDatas: notiDatas).sorted { $0.notiDate < $1.notiDate }
        }
    }
    
    // 기존 알림 데이터 수정하기
    @objc func modifyDeleteNotiData(_ notification: NSNotification) {
        print("NotiViewModel - modifyDeleteNotiData() called")
        
        if let userInfo = notification.userInfo,
           let identiferFirst = userInfo["identiferFirst"] as? String,
           let modifyData = userInfo["modifyData"] as? NotiData {
            if let modifyIndex = notiDatas.firstIndex(where: { $0.identifier.first == identiferFirst }) {
                notiDatas[modifyIndex] = modifyData
            }
            
            notiDatas = filteredDatas(notiDatas: notiDatas).sorted { $0.notiDate < $1.notiDate }
        }
    }
    
    // 알림 삭제하기
    func deleteNotiData(notiData: NotiData) {
        print("NotiViewModel - deleteNotiData() called")
       
        if let deleteIndex = notiDatas.firstIndex(of: notiData),
           let data = realm.objects(PetInfo.self).first {
            let deleteNotiData = notiDatas[deleteIndex]
            
            notiDatas.remove(at: deleteIndex)
            
            try! realm.write {
                data.notiDatas.remove(at: deleteIndex)
            }
                
            NotificationHandler.shared.removeRegisteredNotification(identifiers: Array(notiData.identifier))
            
            NotificationCenter.default.post(name: NSNotification.Name("DeleteNotiData"), object: nil, userInfo: ["deleteNotiData": deleteNotiData])
        }
    }
    
}
