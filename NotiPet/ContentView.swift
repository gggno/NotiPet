////
////  ContentView.swift
////  NotiPet
////
////  Created by 정근호 on 11/14/23.
////
//
//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    @State var selectedDate = Date()
//
//        static let formatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.setLocalizedDateFormatFromTemplate("yyMMddhhmm")
//            return formatter
//        }()
//
//        var body: some View {
//            VStack {
//                Text("Selected date: \(selectedDate, formatter: Self.formatter)")
//                Button("Show action sheet") {
//                    self.showDatePickerAlert()
//                }
//            }
//        }
//
//        func showDatePickerAlert() {
//            let alertVC = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
//            let datePicker: UIDatePicker = UIDatePicker()
//            alertVC.view.addSubview(datePicker)
//
//            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                self.selectedDate = datePicker.date
//            }
//            alertVC.addAction(okAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//            alertVC.addAction(cancelAction)
//
//            if let viewController = UIApplication.shared.windows.first?.rootViewController {
//                viewController.present(alertVC, animated: true, completion: nil)
//            }
//        }
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
//
//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
