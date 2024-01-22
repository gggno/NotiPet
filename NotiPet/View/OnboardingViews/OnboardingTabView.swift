import SwiftUI

struct OnboardingTabView: View {
    @Binding var onboarding: Bool
    
    var body: some View {
        TabView {
            OnboardingFirstView()
            OnboardingSecondView()
            OnboardingThirdView()
            PetInfoView(isPresented: $onboarding)
        }
        .tint(Color("PeachColor"))
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

