/// TSTOOLS:  Description... 9/19/16.
import Foundation

@available(iOS 8.0, *)
public extension Date {
    
    @available(iOS 8.0, *)
    public func toString(withFormat targetFormat : String,
                 andTimezone timezone : TimeZone = TimeZone.current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.string(from: self)
    }
    
    @available(iOS 8.0, *)
    public static func fromString(_ dateString : String,
                          withFormat targetFormat: String,
                         andTimezone timezone : TimeZone = TimeZone.current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.date(from: dateString)
    }
    
    @available(iOS 8.0, *)
    public func dateWithComponents(_ dateComponents: NSCalendar.Unit) -> Date {
        let comps = (Calendar.current as NSCalendar).components(dateComponents, from: self)
        return Calendar.current.date(from: comps)!
    }
    
    /// Returns date with date components only.
    @available(iOS 8.0, *)
    public var onlyDate : Date {
        return self.dateWithComponents([.year, .month, .day])
    }
    
    /// Returns date with time components only.
    @available(iOS 8.0, *)
    public var onlyTime : Date {
        return self.dateWithComponents([.hour, .minute, .second])
    }
    
    /// Returns date with date components only including nanoseconds.
    @available(iOS 8.0, *)
    public var preciseTime : Date {
        return self.dateWithComponents([.hour, .minute, .second, .nanosecond])
    }
}

@available(iOS 8.0, *)
public extension String {
    
    @available(iOS 8.0, *)
    @available(*, deprecated, message: "Use NSDate's convertFromString method instead.")
    public func toDate(withFormat targetFormat : String,
                  timezone : TimeZone = TimeZone.current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.date(from: self)
    }
    
    @available(iOS 8.0, *)
    public func reformatDate(_ stringDate : String,
                      withFormat sourceFormat : String,
                     andTimezone sourceTimezone: TimeZone = TimeZone.current,
                        toFormat targetFormat: String,
                     andTimezone targetTimezone : TimeZone = TimeZone.current) -> String? {
        if let date = Date.fromString(stringDate, withFormat: sourceFormat, andTimezone: sourceTimezone) {
            return date.toString(withFormat: targetFormat, andTimezone: targetTimezone)
        }
        return nil
        
    }
}

public enum TSDateComponents {
    case days(Int), months(Int), years(Int)
    case hours(Int), minutes(Int), seconds(Int), nanoseconds(Int)
}

/// Subtracts given components from the date and returns resulting date.
@available(iOS 8.0, *)
public func -(date : Date, dateComponents: [TSDateComponents]) -> Date? {
    var comps = DateComponents()
    for dateComponent in dateComponents {
        switch dateComponent {
        case .days(let days):
            comps.day = (days > 0 ? -days : days)
        case .months(let months):
            comps.month = (months > 0 ? -months : months)
        case .years(let years):
            comps.year = (years > 0 ? -years : years)
        case .hours(let hours):
            comps.hour = (hours > 0 ? -hours : hours)
        case .minutes(let mins):
            comps.minute = (mins > 0 ? -mins : mins)
        case .seconds(let secs):
            comps.second = (secs > 0 ? -secs : secs)
        case .nanoseconds(let nsecs):
            comps.nanosecond = (nsecs > 0 ? -nsecs : nsecs)
        }
    }
    return (Calendar.current as NSCalendar).date(byAdding: comps, to: date, options: [])
}

/// Adds given components to the date and returns resulting date.
@available(iOS 8.0, *)
public func +(date : Date, dateComponents: [TSDateComponents]) -> Date? {
    var comps = DateComponents()
    for dateComponent in dateComponents {
        switch dateComponent {
        case .days(let days):
            comps.day = days
        case .months(let months):
            comps.month = months
        case .years(let years):
            comps.year = years
        case .hours(let hours):
            comps.hour = hours
        case .minutes(let mins):
            comps.minute = mins
        case .seconds(let secs):
            comps.second = secs
        case .nanoseconds(let nsecs):
            comps.nanosecond = nsecs
        }
    }
    return (Calendar.current as NSCalendar).date(byAdding: comps, to: date, options: [])
}

/// Subtracts given component from the date and returns resulting date.
@available(iOS 8.0, *)
public func -(date : Date, dateComponent: TSDateComponents) -> Date? {
    return date - [dateComponent]
}

/// Adds given component to the date and returns resulting date.
@available(iOS 8.0, *)
public func +(date : Date, dateComponent: TSDateComponents) -> Date? {
    return date + [dateComponent]
}

/// Checks whether the first date is greater than or equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func >=(date1 : Date, date2 : Date) -> Bool {
    let res = date1.compare(date2)
    return res == .orderedDescending || res == .orderedSame
}

/// Checks whether the first date is less than or equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func <=(date1 : Date, date2 : Date) -> Bool {
    let res = date1.compare(date2)
    return res == .orderedAscending || res == .orderedSame
}

/// Checks whether the first date is equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func ==(date1 : Date, date2 : Date) -> Bool {
    return date1.compare(date2) == .orderedSame
}

/// Checks whether the first date is not equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func !=(date1 : Date, date2 : Date) -> Bool {
    return date1.compare(date2) != .orderedSame
}

/// Finds minimum of two dates by comparing all date components
public func min(_ x : Date, y: Date) -> Date {
    return (x < y ? x : y)
}

/// Finds maximum of two dates by comparing all date components
public func max(_ x : Date, y: Date) -> Date {
    return (x > y ? x : y)
}
/// Finds minimum of two dates by comparing only date components (e.g. Year, Month, Day)
public func minDate(_ x : Date, y: Date) -> Date {
    return (x <! y ? x : y)
}

/// Finds maximum of two dates by comparing only date components (e.g. Year, Month, Day)
public func maxDate(_ x : Date, y: Date) -> Date {
    return (x >! y ? x : y)
}

/// Date comparison operators to compare with .Day granularity
infix operator >! { associativity left precedence 130}
infix operator >=! {associativity left precedence 130}
infix operator <! {associativity left precedence 130}
infix operator <=! {associativity left precedence 130}
infix operator ==! {associativity left precedence 130}
infix operator !=! {associativity left precedence 130}

private func compareDates(_ date1 : Date, date2 : Date, granularity : NSCalendar.Unit) -> ComparisonResult {
    return (Calendar.current as NSCalendar).compare(date1, to: date2, toUnitGranularity: granularity)
}

/// Checks whether the first date is greater than the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func >!(date1 : Date, date2 : Date) -> Bool {
    return compareDates(date1, date2: date2, granularity: .day) == .orderedDescending
}

/// Checks whether the first date is greater than or equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func >=!(date1 : Date, date2 : Date) -> Bool {
    let res = compareDates(date1, date2: date2, granularity: .day)
    return res == .orderedDescending || res == .orderedSame
}

/// Checks whether the first date is less than the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func <!(date1 : Date, date2 : Date) -> Bool {
    return compareDates(date1, date2: date2, granularity: .day) == .orderedAscending
}

/// Checks whether the first date is less than or equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func <=!(date1 : Date, date2 : Date) -> Bool {
    let res = compareDates(date1, date2: date2, granularity: .day)
    return res == .orderedAscending || res == .orderedSame
}

/// Checks whether the first date is equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func ==!(date1 : Date, date2 : Date) -> Bool {
    return compareDates(date1, date2: date2, granularity: .day) == .orderedSame
}

/// Checks whether the first date is not equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func !=!(date1 : Date, date2 : Date) -> Bool {
    return compareDates(date1, date2: date2, granularity: .day) != .orderedSame
}



