/// TSTOOLS:  Description... 9/19/16.
import Foundation

@available(iOS 8.0, *)
public extension NSDate {
    
    @available(iOS 8.0, *)
    public func toString(withFormat targetFormat : String,
                 andTimezone timezone : NSTimeZone = NSTimeZone.defaultTimeZone()) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.stringFromDate(self)
    }
    
    @available(iOS 8.0, *)
    public class func fromString(dateString : String,
                          withFormat targetFormat: String,
                         andTimezone timezone : NSTimeZone = NSTimeZone.defaultTimeZone()) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.dateFromString(dateString)
    }
    
    @available(iOS 8.0, *)
    public func dateWithComponents(dateComponents: NSCalendarUnit) -> NSDate {
        let comps = NSCalendar.currentCalendar().components(dateComponents, fromDate: self)
        return NSCalendar.currentCalendar().dateFromComponents(comps)!
    }
    
    /// Returns date with date components only.
    @available(iOS 8.0, *)
    public var onlyDate : NSDate {
        return self.dateWithComponents([.Year, .Month, .Day])
    }
    
    /// Returns date with time components only.
    @available(iOS 8.0, *)
    public var onlyTime : NSDate {
        return self.dateWithComponents([.Hour, .Minute, .Second])
    }
    
    /// Returns date with date components only including nanoseconds.
    @available(iOS 8.0, *)
    public var preciseTime : NSDate {
        return self.dateWithComponents([.Hour, .Minute, .Second, .Nanosecond])
    }
}

@available(iOS 8.0, *)
public extension String {
    
    @available(iOS 8.0, *)
    @available(*, deprecated, message="Use NSDate's convertFromString method instead.")
    public func toDate(withFormat targetFormat : String,
                  timezone : NSTimeZone = NSTimeZone.defaultTimeZone()) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = targetFormat
        formatter.timeZone = timezone
        return formatter.dateFromString(self)
    }
    
    @available(iOS 8.0, *)
    public func reformatDate(stringDate : String,
                      withFormat sourceFormat : String,
                     andTimezone sourceTimezone: NSTimeZone = NSTimeZone.defaultTimeZone(),
                        toFormat targetFormat: String,
                     andTimezone targetTimezone : NSTimeZone = NSTimeZone.defaultTimeZone()) -> String? {
        if let date = NSDate.fromString(stringDate, withFormat: sourceFormat, andTimezone: sourceTimezone) {
            return date.toString(withFormat: targetFormat, andTimezone: targetTimezone)
        }
        return nil
        
    }
}

public enum TSDateComponents {
    case Days(Int), Months(Int), Years(Int)
    case Hours(Int), Minutes(Int), Seconds(Int), Nanoseconds(Int)
}

/// Subtracts given components from the date and returns resulting date.
@available(iOS 8.0, *)
public func -(date : NSDate, dateComponents: [TSDateComponents]) -> NSDate? {
    let comps = NSDateComponents()
    for dateComponent in dateComponents {
        switch dateComponent {
        case .Days(let days):
            comps.day = (days > 0 ? -days : days)
        case .Months(let months):
            comps.month = (months > 0 ? -months : months)
        case .Years(let years):
            comps.year = (years > 0 ? -years : years)
        case .Hours(let hours):
            comps.hour = (hours > 0 ? -hours : hours)
        case .Minutes(let mins):
            comps.minute = (mins > 0 ? -mins : mins)
        case .Seconds(let secs):
            comps.second = (secs > 0 ? -secs : secs)
        case .Nanoseconds(let nsecs):
            comps.nanosecond = (nsecs > 0 ? -nsecs : nsecs)
        }
    }
    return NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: date, options: [])
}

/// Adds given components to the date and returns resulting date.
@available(iOS 8.0, *)
public func +(date : NSDate, dateComponents: [TSDateComponents]) -> NSDate? {
    let comps = NSDateComponents()
    for dateComponent in dateComponents {
        switch dateComponent {
        case .Days(let days):
            comps.day = days
        case .Months(let months):
            comps.month = months
        case .Years(let years):
            comps.year = years
        case .Hours(let hours):
            comps.hour = hours
        case .Minutes(let mins):
            comps.minute = mins
        case .Seconds(let secs):
            comps.second = secs
        case .Nanoseconds(let nsecs):
            comps.nanosecond = nsecs
        }
    }
    return NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: date, options: [])
}

/// Subtracts given component from the date and returns resulting date.
@available(iOS 8.0, *)
public func -(date : NSDate, dateComponent: TSDateComponents) -> NSDate? {
    return date - [dateComponent]
}

/// Adds given component to the date and returns resulting date.
@available(iOS 8.0, *)
public func +(date : NSDate, dateComponent: TSDateComponents) -> NSDate? {
    return date + [dateComponent]
}

/// Checks whether the first date is greater than the second date by comparing all date components
@available(iOS 8.0, *)
public func >(date1 : NSDate, date2 : NSDate) -> Bool {
    return date1.compare(date2) == .OrderedDescending
}

/// Checks whether the first date is greater than or equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func >=(date1 : NSDate, date2 : NSDate) -> Bool {
    let res = date1.compare(date2)
    return res == .OrderedDescending || res == .OrderedSame
}

/// Checks whether the first date is less than the second date by comparing all date components
@available(iOS 8.0, *)
public func <(date1 : NSDate, date2 : NSDate) -> Bool {
    return date1.compare(date2) == .OrderedAscending
}

/// Checks whether the first date is less than or equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func <=(date1 : NSDate, date2 : NSDate) -> Bool {
    let res = date1.compare(date2)
    return res == .OrderedAscending || res == .OrderedSame
}

/// Checks whether the first date is equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func ==(date1 : NSDate, date2 : NSDate) -> Bool {
    return date1.compare(date2) == .OrderedSame
}

/// Checks whether the first date is not equal to the second date by comparing all date components
@available(iOS 8.0, *)
public func !=(date1 : NSDate, date2 : NSDate) -> Bool {
    return date1.compare(date2) != .OrderedSame
}

/// Finds minimum of two dates by comparing all date components
public func min(x : NSDate, y: NSDate) -> NSDate {
    return (x < y ? x : y)
}

/// Finds maximum of two dates by comparing all date components
public func max(x : NSDate, y: NSDate) -> NSDate {
    return (x > y ? x : y)
}
/// Finds minimum of two dates by comparing only date components (e.g. Year, Month, Day)
public func minDate(x : NSDate, y: NSDate) -> NSDate {
    return (x <! y ? x : y)
}

/// Finds maximum of two dates by comparing only date components (e.g. Year, Month, Day)
public func maxDate(x : NSDate, y: NSDate) -> NSDate {
    return (x >! y ? x : y)
}

/// Date comparison operators to compare with .Day granularity
infix operator >! { associativity left precedence 130}
infix operator >=! {associativity left precedence 130}
infix operator <! {associativity left precedence 130}
infix operator <=! {associativity left precedence 130}
infix operator ==! {associativity left precedence 130}
infix operator !=! {associativity left precedence 130}

private func compareDates(date1 : NSDate, date2 : NSDate, granularity : NSCalendarUnit) -> NSComparisonResult {
    return NSCalendar.currentCalendar().compareDate(date1, toDate: date2, toUnitGranularity: granularity)
}

/// Checks whether the first date is greater than the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func >!(date1 : NSDate, date2 : NSDate) -> Bool {
    return compareDates(date1, date2: date2, granularity: .Day) == .OrderedDescending
}

/// Checks whether the first date is greater than or equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func >=!(date1 : NSDate, date2 : NSDate) -> Bool {
    let res = compareDates(date1, date2: date2, granularity: .Day)
    return res == .OrderedDescending || res == .OrderedSame
}

/// Checks whether the first date is less than the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func <!(date1 : NSDate, date2 : NSDate) -> Bool {
    return compareDates(date1, date2: date2, granularity: .Day) == .OrderedAscending
}

/// Checks whether the first date is less than or equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func <=!(date1 : NSDate, date2 : NSDate) -> Bool {
    let res = compareDates(date1, date2: date2, granularity: .Day)
    return res == .OrderedAscending || res == .OrderedSame
}

/// Checks whether the first date is equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func ==!(date1 : NSDate, date2 : NSDate) -> Bool {
    return compareDates(date1, date2: date2, granularity: .Day) == .OrderedSame
}

/// Checks whether the first date is not equal to the second date by comparing only their date components (e.g. Year, Month, Day)
@available(iOS 8.0, *)
public func !=!(date1 : NSDate, date2 : NSDate) -> Bool {
    return compareDates(date1, date2: date2, granularity: .Day) != .OrderedSame
}



