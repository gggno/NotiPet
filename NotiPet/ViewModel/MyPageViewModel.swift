import SwiftUI
import Combine
import RealmSwift

class MyPageViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var petProfileUIImage: UIImage = UIImage(systemName: "pawprint.circle.fill")!
    @Published var petName: String = ""
    @Published var species: String = ""
    @Published var birthDate: String = Date().convertDate()
    @Published var weight: String = ""
    @Published var sex: String = ""
    
    @Published var anniversaryDatas: [AnniversaryData] = []
    
    @Published var anniContent: String = ""
    @Published var anniContentMessage: String = ""
    @Published var anniDate: String = ""
    
    var validAnniContentPublisher: AnyPublisher<Bool, Never> {
        $anniContent
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("MyPageViewModel init() called")
        
        getInfoFromDB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDatas(_:)), name: NSNotification.Name("PetInfosData"), object: nil)
        
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
            
            anniversaryDatas = Array(data.anniversaryDatas).sorted {
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
    
    // 데이터가 변경될 시 감지 후 업데이트
    @objc func recievedDatas(_ notification: NSNotification) {
        print("MyPageViewModel - recievedDatas() called")
        if let userInfo = notification.userInfo,
           let petProfileImage = userInfo["petProfileUIImage"] as? UIImage,
           let petName = userInfo["petName"] as? String,
           let species = userInfo["species"] as? String,
           let birthDate = userInfo["birthDate"] as? String,
           let weight = userInfo["weight"] as? String,
           let sex = userInfo["sex"] as? String,
           let anniversaryDatas = userInfo["anniversaryDatas"] as? [AnniversaryData] {
            self.petProfileUIImage = petProfileImage
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
            indexSet.forEach {
                realm.delete(self.anniversaryDatas[$0])
            }
        }
        
        anniversaryDatas.remove(atOffsets: indexSet)
    }
    
}
