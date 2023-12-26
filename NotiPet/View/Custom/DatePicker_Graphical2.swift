import SwiftUI

struct DatePicker_Graphical2: View {
    @State var selectedDate: Date = Date()
    @Binding var notiDate: Date
   
    
    var currentDate = Date()
    
    var body: some View {
        DatePicker("",
                   selection: $selectedDate,
                   in: currentDate...,
                   displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .onChange(of: selectedDate) { oldValue, newValue in
            notiDate = selectedDate
        }
        .onAppear {
            notiDate = selectedDate
        }
    }
}

#Preview {
    DatePicker_Graphical2(notiDate: .constant(Date()))
    
}
