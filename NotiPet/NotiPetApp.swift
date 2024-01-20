import SwiftUI

@main
struct NotiPetApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    NotificationHandler.shared.askPermisson()
                }
        }
    }
}
