import SwiftUI
import Combine
import RealmSwift

class MyPageViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var petProfileUIImage: UIImage?
    @Published var petName: String = ""
    @Published var species: String = ""
    @Published var birthDate: String = Date().convertDate()
    @Published var weight: String = ""
    @Published var sex: String = ""
    
    @Published var anniversaryDatas: [AnniversaryData] = []
    
    @Published var anniContent: String = ""
    @Published var anniContentMessage: String = ""
    @Published var anniDate: String = ""
    
    @Published var showBirthdayAlert = false
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("MyPageViewModel init() called")
        
        getInfoFromDB()
        
        // 펫정보 변경 시 감지 후 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDatas(_:)), name: NSNotification.Name("PetInfosData"), object: nil)
        // 추가된 기념일 데이터 받기
        NotificationCenter.default.addObserver(self, selector: #selector(anniDatasRecieved(_:)), name: NSNotification.Name("anniDatas"), object: nil)
    }
    
    // 로컬 DB에서 가져와 화면에 데이터 뿌려주기
    func getInfoFromDB() {
        print("MyPageViewModel - getInfoFromDB() called")
        if let data = realm.objects(PetInfo.self).first {
            print("getInfoFromDB() - 로컬디비에 정보가 있다.")
            if let imageData = data.petProfileImageData {
                petProfileUIImage = UIImage(data: imageData)!
            }
            petName = data.petName
            species = data.species
            birthDate = data.birthDate
            weight = data.weight
            sex = data.sex
            
            anniversaryDatas = filterdDayDatas(anniDatas: Array(data.anniversaryDatas)).sorted {
                if let number1 = Int($0.dDay.components(separatedBy: "-").last ?? ""),
                   let number2 = Int($1.dDay.components(separatedBy: "-").last ?? "") {
                    if number1 != number2 {
                        return number1 < number2
                    }
                } else {
                    return $0.dDay > $1.dDay
                }
                
                return $0.content < $1.content
            }
        }
    }
    
    // 펫정보 변경 시 감지 후 업데이트
    @objc func recievedDatas(_ notification: NSNotification) {
        print("MyPageViewModel - recievedDatas() called")
        if let userInfo = notification.userInfo,
           let petName = userInfo["petName"] as? String,
           let species = userInfo["species"] as? String,
           let birthDate = userInfo["birthDate"] as? String,
           let weight = userInfo["weight"] as? String,
           let sex = userInfo["sex"] as? String,
           let anniversaryDatas = userInfo["anniversaryDatas"] as? [AnniversaryData] {
            
            if let petProfileImage = userInfo["petProfileUIImage"] as? UIImage {
                self.petProfileUIImage = petProfileImage
            } else {
                self.petProfileUIImage = nil
            }
            self.petName = petName
            self.species = species
            self.birthDate = birthDate
            self.weight = weight
            self.sex = sex
            
            self.anniversaryDatas = anniversaryDatas.sorted {
                if let number1 = Int($0.dDay.components(separatedBy: "-").last ?? ""),
                   let number2 = Int($1.dDay.components(separatedBy: "-").last ?? "") {
                    if number1 != number2 {
                        return number1 < number2
                    }
                } else {
                    return $0.dDay > $1.dDay
                }
                
                return $0.content < $1.content
            }
        }
    }
    
    // 추가된 기념일 데이터 받기
    @objc func anniDatasRecieved(_ notification: NSNotification) {
        print("MyPageViewModel - anniDatasRecieved() called")
        if let userInfo = notification.userInfo,
           let anniversaryDatas = userInfo["anniversaryDatas"] as? [AnniversaryData] {
            
            self.anniversaryDatas = anniversaryDatas.sorted {
                if let number1 = Int($0.dDay.components(separatedBy: "-").last ?? ""),
                   let number2 = Int($1.dDay.components(separatedBy: "-").last ?? "") {
                    if number1 != number2 {
                        return number1 < number2
                    }
                } else {
                    return $0.dDay > $1.dDay
                }
                
                return $0.content < $1.content
            }
        }
    }
    
    // 기념일 삭제하기(옆으로 슬라이드 해서 삭제할 때 이용)
    func deleteRow(indexSet: IndexSet) {
        try! realm.write {
            for index in indexSet {
                let deletedIdentifier = anniversaryDatas[index].identifier
                if anniversaryDatas[index].content != "생일" {
                    realm.delete(anniversaryDatas[index])
                    anniversaryDatas.remove(atOffsets: indexSet)
                    
                    // 로컬 푸시 알림 해제
                    NotificationHandler.shared.removeRegisteredNotification(identifiers: [deletedIdentifier])
                } else {
                    showBirthdayAlert = true
                }
            }
        }
    }
    
    // 기념일 날짜 업데이트, 지나면 삭제하기
    func filterdDayDatas(anniDatas: [AnniversaryData]) -> [AnniversaryData] {
        print("MyPageViewModel - filterdDayDatas() called")
        var filterDatas: [AnniversaryData] = []
        
        for item in anniDatas {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            guard let targetDate = dateFormatter.date(from: item.dueDate)?.onlyDate else {
                print("targetDate Error")
                return []
            }
            
            // 현재 날짜 얻어오기
            let currentDate = Date().onlyDate
            
            // 날짜 차이 계산
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: targetDate, to: currentDate)
            
            // 차이 출력
            if let daysDifference = components.day {
                if daysDifference < 0 {         // 일반적인 디데이 계산
                    let copiedItem = AnniversaryData(
                        identifier: item.identifier,
                        dDay: "D\(daysDifference)",
                        content: item.content,
                        dueDate: item.dueDate
                    )
                    // 로컬 푸시 알림 등록
                    NotificationHandler.shared.anniversaryNotification(identifier: copiedItem.identifier, dateString: copiedItem.dueDate, title: "기념일 알림", body: copiedItem.content)
                    
                    filterDatas.append(copiedItem)
                    
                } else if daysDifference == 0 { // 오늘이 디데이일 때
                    let copiedItem = AnniversaryData(
                        identifier: item.identifier,
                        dDay: "D-Day",
                        content: item.content,
                        dueDate: item.dueDate
                    )
                    filterDatas.append(copiedItem)
                    
                } else {                        // 디데이가 지났을 때
                    if item.content == "생일" {
                        let copiedItem = AnniversaryData(
                            identifier: item.identifier,
                            dDay: PetInfoViewModel.calculateBirthdayDday(birthdate: birthDate),
                            content: "생일",
                            dueDate: PetInfoViewModel.calculateBirthdayYear(birthdate: birthDate)
                        )
                        // 로컬 푸시 알림 재등록
                        NotificationHandler.shared.anniversaryNotification(identifier: copiedItem.identifier, dateString: copiedItem.dueDate, title: "기념일 알림", body: copiedItem.content)
                        
                        filterDatas.append(copiedItem)
                        
                    } else {
                        try! realm.write {
                            realm.delete(item)
                        }
                    }
                }
            }
        }
        
        if let data = realm.objects(PetInfo.self).first {
            print("날짜 업데이트로 인한 기념일 로컬 DB 갱신")
            try! realm.write {
                data.anniversaryDatas.removeAll()
                data.anniversaryDatas.append(objectsIn: filterDatas)
            }
        }
        
        return filterDatas
    }
    
}
