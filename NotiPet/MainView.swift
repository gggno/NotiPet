import SwiftUI

struct MainView: View {
    @AppStorage("onboarding") var onboarding: Bool = true
        
        var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .background(Color("BlueColor"))
            
            NotiView()
                .tabItem {
                    Label("알림", systemImage: "bell.fill")
                }
                .background(Color("BlueColor"))
            
            MyPageView()
                .tabItem {
                    Label("마이페이지", systemImage: "person.fill")
                }
                .background(Color("BlueColor"))
        }
        .tint(Color("PeachColor"))
        .fullScreenCover(isPresented: $onboarding) {
            OnboardingTabView(onboarding: $onboarding)
        }
    }
}
