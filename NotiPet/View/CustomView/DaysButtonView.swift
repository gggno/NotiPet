import SwiftUI

struct DaysButtonView: View {
    @Binding var selectedDays: Set<Days>
    
    var body: some View {
        HStack {
            ForEach(Days.allCases, id: \.self) { day in
                Text(day.displayName)
                    .frame(width: 35, height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .foregroundColor(selectedDays.contains(day) ? .white : .secondary)
                    .background(selectedDays.contains(day) ? Color("PeachColor") : Color.gray)
                    .cornerRadius(5)
                    .onTapGesture {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

//#Preview {
//    DaysButtonView(repeatType: <#Binding<String>#>)
//}
