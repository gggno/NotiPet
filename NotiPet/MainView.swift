import SwiftUI

struct MainView: View {
    @AppStorage("onboarding") var onboarding: Bool = true
    
    var body: some View {
        Text("메인 뷰")
            .fullScreenCover(isPresented: $onboarding) {
                OnboardingTabView(onboarding: $onboarding)
            }
    }
}

#Preview {
    MainView()
}
