import SwiftUI

struct AnniversaryAddDatePicker: View {
    @State var selectedDate: Date = Date()
    @Binding var anniDate: String
    
    var currentDate = Date()
    
    var body: some View {
        DatePicker("", 
                   selection: $selectedDate,
                   in: currentDate...,
                   displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .onChange(of: selectedDate) { oldValue, newValue in
            anniDate = newValue.convertDate()
        }
        .onAppear {
            anniDate = selectedDate.convertDate()
        }
    }
}
