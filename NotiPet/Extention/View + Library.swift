//import Foundation
//import SwiftUI
//
//extension View: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func PhotoAuth() -> Bool {
//        // 포토 라이브러리 접근 권한
//        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
//        
//        var isAuth = false
//        
//        switch authorizationStatus {
//        case .authorized: return true // 사용자가 앱에 사진 라이브러리에 대한 액세스 권한을 명시 적으로 부여했습니다.
//        case .denied: break // 사용자가 사진 라이브러리에 대한 앱 액세스를 명시 적으로 거부했습니다.
//        case .limited: break // ?
//        case .notDetermined: // 사진 라이브러리 액세스에는 명시적인 사용자 권한이 필요하지만 사용자가 아직 이러한 권한을 부여하거나 거부하지 않았습니다
//            PHPhotoLibrary.requestAuthorization { (state) in
//                if state == .authorized {
//                    isAuth = true
//                }
//            }
//            return isAuth
//        case .restricted: break // 앱이 사진 라이브러리에 액세스 할 수있는 권한이 없으며 사용자는 이러한 권한을 부여 할 수 없습니다.
//        default: break
//        }
//        
//        return false;
//    }
//}
