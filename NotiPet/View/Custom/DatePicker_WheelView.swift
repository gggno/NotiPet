import SwiftUI

struct DatePicker_WheelView: View {
    @State var date = Date()
    @Binding var isDatePickerPresented: Bool
    @Binding var birthDate: String
    var currentDate = Date()
    
    var body: some View {
        DatePicker("", selection: $date, in: ...currentDate,
                   displayedComponents: .date)
        .datePickerStyle(WheelDatePickerStyle())
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        Button(action: {
            birthDate = date.convertDate()
            isDatePickerPresented.toggle()
        }, label: {
            Text("선택완료")
        })
        .border(.blue)
    }
}

//#Preview {
//    DatePicker_WheelView()
//}
