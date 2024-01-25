import Combine
import SwiftUI
import RealmSwift

class HomeViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    // 펫 정보
    @Published var petProfileUIImage: UIImage?
    @Published var petName: String = ""
    @Published var birthDate: String = ""
    @Published var sex: String = ""
    
    @Published var selectedDate: Date = Date()
    @Published var selectedNotiDatas: [NotiData] = []
    
    // 알림 정보
    @Published var notiDatas: [NotiData] = []
    
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        // 처음 켰을 때 로컬 DB에서 데이터 받아오기
        getInfoFromData()
        
        // selectedDate가 변경될 때 마다 selectedNotiDatas 업데이트
        $selectedDate
            .combineLatest($notiDatas)
            .sink { selectedDate, notiDatas in
                self.selectedNotiDatas = notiDatas.filter { notiData in
                    
                    let afterDays = selectedDate.onlyDate >= notiData.notiDate.onlyDate // 알림 날짜 이후인지
                    let compareIntDays = Array(notiData.weekDays).contains(selectedDate.onlyIntDay) // 매주일때 해당하는 요일인지
                    
                    switch notiData.repeatTypeDisplayName {
                    case RepeatType.everyday.displayName:
                        return afterDays
                        
                    case RepeatType.everyweak.displayName:
                        return afterDays && compareIntDays
                        
                    case RepeatType.everymonth.displayName:
                        return afterDays && self.compareDay(firstDate: selectedDate, secondDate: notiData.notiDate)
                        
                    case RepeatType.everythreemonths.displayName:
                        return afterDays && self.compareThreeMonth(firstDate: selectedDate, secondDate: notiData.notiDate)
                        
                    case RepeatType.everysixmonths.displayName:
                        return afterDays && self.compareSixMonth(firstDate: selectedDate, secondDate: notiData.notiDate)
                        
                    case RepeatType.everyYear.displayName:
                        return afterDays && self.compareYear(firstDate: selectedDate, secondDate: notiData.notiDate)
                    default:
                        return notiData.notiDate.convertDate() == selectedDate.convertDate()
                    }
                }

            }.store(in: &subscriptions)
        
        // 펫 정보 변경 시 데이터 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedPetInfoData(_:)), name: NSNotification.Name("PetInfosData"), object: nil)
        
        // 알림 정보 추가 시 데이터 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedNotiData(_:)), name: NSNotification.Name("notiData"), object: nil)
        
        // 알림 정보 수정 시 데이터 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedModifyData(_:)), name: NSNotification.Name("modifyDataIdentifer"), object: nil)
        
        // 알림 정보 삭제 시 데이터 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDeleteNotiData(_:)), name: NSNotification.Name("DeleteNotiData"), object: nil)
        
    }
    
    func getInfoFromData() {
        print("HomeViewModel - getInfoFromData() called")
        
        if let allData = realm.objects(PetInfo.self).first {
            // 펫 정보 받기
            if let imageData = allData.petProfileImageData {
                petProfileUIImage = UIImage(data: imageData)
            }
            petName = allData.petName
            birthDate = allData.birthDate
            sex = allData.sex
            
            // 알림 정보 받기
            notiDatas = filteredDatas(notiDatas: Array(allData.notiDatas)).sorted { $0.notiDate.onlyTime() < $1.notiDate.onlyTime() }
            print(allData.notiDatas)
        }
    }
    
    // 펫 정보 변경 시 데이터 받기
    @objc func recievedPetInfoData(_ notification: NSNotification) {
        print("HomeViewModel - recievedPetInfoData() called")
        
        if let userInfo = notification.userInfo,
           let petName = userInfo["petName"] as? String,
           let birthDate = userInfo["birthDate"] as? String,
           let sex = userInfo["sex"] as? String {

            if let petProfileImage = userInfo["petProfileUIImage"] as? UIImage {
                self.petProfileUIImage = petProfileImage
            } else {
                self.petProfileUIImage = nil
            }
            self.petName = petName
            self.birthDate = birthDate
            self.sex = sex
        }
    }
    
    // 추가한 알림 데이터 받기
    @objc func recievedNotiData(_ notification: NSNotification) {
        print("HomeViewModel - recievedNotiData() called")
        
        if let userInfo = notification.userInfo,
           let notiData = userInfo["notiDatas"] as? NotiData {
            
            notiDatas.append(notiData)
            notiDatas = filteredDatas(notiDatas: notiDatas).sorted { $0.notiDate < $1.notiDate }
        }
    }
    
    // 수정된 알림 데이터 받기
    @objc func recievedModifyData(_ notification: NSNotification) {
        print("HomeViewModel - recievedModifyData() called")
        
        if let userInfo = notification.userInfo,
           let identiferFirst = userInfo["identiferFirst"] as? String,
           let modifyData = userInfo["modifyData"] as? NotiData {
            if let modifyIndex = notiDatas.firstIndex(where: { $0.identifier.first == identiferFirst }) {
                notiDatas[modifyIndex] = modifyData
            }
            
            notiDatas = filteredDatas(notiDatas: notiDatas).sorted { $0.notiDate < $1.notiDate }
        }
    }
    
    // 삭제할 알림 데이터 받기
    @objc func recievedDeleteNotiData(_ notification: NSNotification) {
        print("HomeViewModel - recievedDeleteNotiData() called")
        
        if let userInfo = notification.userInfo,
           let deleteNotiData = userInfo["deleteNotiData"] as? NotiData {
            if let deleteIndex = notiDatas.firstIndex(where: { $0.identifier.first == deleteNotiData.identifier.first }) {
                notiDatas.remove(at: deleteIndex)
            }
        }
    }
    
    // 매달 day(일)이 같은지 비교
    func compareDay(firstDate: Date, secondDate: Date) -> Bool {
        print("HomeViewModel - compareDay() called")
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.day], from: firstDate)
        let components2 = calendar.dateComponents([.day], from: secondDate)
        
        return components1.day == components2.day
    }
    
    // 3달마다 day(일)이 같은지 비교
    func compareThreeMonth(firstDate: Date, secondDate: Date) -> Bool {
        print("HomeViewModel - compareThreeMonth() called")
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month, .day], from: firstDate)
        let components2 = calendar.dateComponents([.month, .day], from: secondDate)
        
        var month: [Int] = [components2.month ?? 0]
        for _ in 0..<3 {
            if ((month.last ?? 1) + 3) > 12 {
                month.append(((month.last ?? 1) + 3) % 12)
            } else {
                month.append(((month.last ?? 1) + 3))
            }
        }
        
        return month.contains(components1.month ?? 0) && components1.day == components2.day
    }
    
    // 6달마다 day(일)이 같은지 비교
    func compareSixMonth(firstDate: Date, secondDate: Date) -> Bool {
        print("HomeViewModel - compareSixMonth() called")
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month, .day], from: firstDate)
        let components2 = calendar.dateComponents([.month, .day], from: secondDate)
        
        var month: [Int] = [components2.month ?? 0]
        if ((month.last ?? 1) + 6) > 12 {
            month.append(((month.last ?? 1) + 6) % 12)
        } else {
            month.append(((month.last ?? 1) + 6))
        }
        
        return month.contains(components1.month ?? 0) && components1.day == components2.day
    }
    
    // 매년마다 month(월), day(일)이 같은지 비교
    func compareYear(firstDate: Date, secondDate: Date) -> Bool {
        print("HomeViewModel - compareYear() called")
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month, .day], from: firstDate)
        let components2 = calendar.dateComponents([.month, .day], from: secondDate)
        
        return components1.month == components2.month && components1.day == components2.day
    }
    
    
    // 날짜순으로 정렬
    func filteredDatas(notiDatas: [NotiData]) -> [NotiData] {
        print("HomeViewModel - filteredDatas() called")
        var filterDatas: [NotiData] = []
        let currentDate = Date()
        var addDate = Date()
        
        for item in notiDatas {
            
            switch item.repeatTypeDisplayName {
            case RepeatType.everyday.displayName:
                print("everyday")
                if item.notiDate.onlyDate < currentDate.onlyDate { // 알림 날짜가 지났으면
                    let day = (Calendar.current.dateComponents([.day], from: item.notiDate.onlyDate, to: currentDate.onlyDate).day ?? 0)
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
                let currentWeekday = Calendar.current.dateComponents([.weekday], from: currentDate).weekday ?? 0
                
                if item.notiDate.onlyDate < currentDate.onlyDate {
                    let addData = NotiData(
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
                    let addData = NotiData(
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
                    let itemComponent = Calendar.current.dateComponents([.year, .month, .day], from: item.notiDate.onlyDate)
                    let currentComponent = Calendar.current.dateComponents([.year, .month, .day], from: currentDate.onlyDate)
                    let differMonth = Calendar.current.dateComponents([.month], from: item.notiDate.onlyDate, to: currentDate.onlyDate).month ?? 0
                    
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
                if item.notiDate.onlyDate < currentDate.onlyDate {
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
                if item.notiDate.onlyDate >= currentDate.onlyDate {
                    filterDatas.append(item)
                }
            }
        }

        return filterDatas
    }
}
