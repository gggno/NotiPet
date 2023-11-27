import SwiftUI

struct MainView: View {
    @AppStorage("onboarding") var onboarding: Bool = true
        
        var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
            NotiView()
                .tabItem {
                    Label("알림", systemImage: "bell.fill")
                }
            MyPageView()
                .tabItem {
                    Label("마이페이지", systemImage: "person.fill")
                }
        }
        .fullScreenCover(isPresented: $onboarding) {
            OnboardingTabView(onboarding: $onboarding)
        }
    }
}

//#Preview {
//    MainView()
//}
