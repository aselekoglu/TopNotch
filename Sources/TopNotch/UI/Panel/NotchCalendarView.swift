import SwiftUI

/// A clean, beautiful mock Calendar Widget for the left column of the expanded panel.
/// Shows month name, week timeline with the current day highlighted, and upcoming events.
struct NotchCalendarView: View {
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(monthName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(yearString)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.44))
                }
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 4)
            
            // Week timeline
            HStack(spacing: 4) {
                ForEach(0..<7) { index in
                    let dateInfo = getDayInfo(for: index)
                    VStack(spacing: 4) {
                        Text(dateInfo.name)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.38))
                        
                        Text(dateInfo.number)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(dateInfo.isToday ? .white : .white.opacity(0.8))
                            .frame(width: 20, height: 20)
                            .background(dateInfo.isToday ? Color.blue : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.045))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            
            // Event rows
            VStack(alignment: .leading, spacing: 6) {
                eventRow(time: "10:00 AM", title: "SwiftUI Coding")
                eventRow(time: "02:30 PM", title: "TopNotch Sync")
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.white.opacity(0.055))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }
    
    private func eventRow(time: String, title: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(width: 3, height: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                Text(time)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.44))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private struct DayInfo {
        let name: String
        let number: String
        let isToday: Bool
    }
    
    private func getDayInfo(for index: Int) -> DayInfo {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon...
        
        // Align so index 0 is Sunday, 1 is Monday etc.
        // Find Sunday of the current week:
        let daysToSubtract = weekday - 1
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return DayInfo(name: "?", number: "?", isToday: false)
        }
        
        guard let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
            return DayInfo(name: "?", number: "?", isToday: false)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let name = String(formatter.string(from: targetDate).prefix(1)) // "S", "M", "T"...
        let number = "\(calendar.component(.day, from: targetDate))"
        let isToday = calendar.isDate(targetDate, inSameDayAs: today)
        
        return DayInfo(name: name, number: number, isToday: isToday)
    }
}
