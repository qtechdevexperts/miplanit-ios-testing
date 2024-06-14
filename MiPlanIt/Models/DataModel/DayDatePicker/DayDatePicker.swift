import UIKit

protocol DayDatePickerDelegate: AnyObject {
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date)
}

class DayDatePicker : UIPickerView{
    var dateCollection = [Date]()
    var dayDatePickerDelegate: DayDatePickerDelegate?
    
    func selectedDate(date: Date? = nil)->Int{
        var row = 0
        for index in dateCollection.indices{
            let compareDate = date ?? Date()
            if Calendar.current.compare(compareDate, to: dateCollection[index], toGranularity: .day) == .orderedSame{
                row = index
            }
        }
        return row
    }
    
    
    func setUpData() {
        self.dateCollection = buildDateCollection()
    }
    
    func buildDateCollection()-> [Date]{
        dateCollection.append(contentsOf: Date.previousYear())
        dateCollection.append(contentsOf: Date.nextYears(20))
        return dateCollection
    }
}

// MARK - UIPickerViewDelegate
extension DayDatePicker : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let date = formatDate(date: self.dateCollection[row])
//        NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        self.dayDatePickerDelegate?.dayDatePicker(self, selectedDate: self.dateCollection[row])
        
    }
    func formatDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK - UIPickerViewDataSource
extension DayDatePicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateCollection.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let label = formatDatePicker(date: dateCollection[row])
        return label
    }
    
    
    func formatDatePicker(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE,   MMM   d,   yyyy"
        return dateFormatter.string(from: date)
    }
    
}

// MARK - Observer Notification Init
extension Notification.Name{
    static var dateChanged : Notification.Name{
        return .init("dateChanged")
    }
    
}

// MARK - Date extension
extension Date {
    static func nextYears(_ limit: Int = 1) -> [Date]{
        return Date.next(numberOfDays: 365 * limit, from: Date())
    }
    
    static func previousYear()-> [Date]{
        return Date.next(numberOfDays: 365, from: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    }
    
    static func next(numberOfDays: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}
