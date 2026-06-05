import Foundation

extension DateFormatter {
    static let momentDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    static let momentShort: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}

extension Date {
    var momentFormatted: String {
        DateFormatter.momentDate.string(from: self)
    }

    var momentShortFormatted: String {
        DateFormatter.momentShort.string(from: self)
    }
}
