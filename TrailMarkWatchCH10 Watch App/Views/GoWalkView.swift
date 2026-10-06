import SwiftUI
import TrailMarkCH10Core

struct GoWalkView: View {
    @Environment(WatchModel.self) private var model

    var body: some View {
        List {
            Section {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    metricRow(
                        title: "Elapsed",
                        value: timeString(model.workout.elapsed),
                        symbol: "timer",
                        tint: .blue
                    )
                }

                metricRow(
                    title: "Heart Rate",
                    value: heartRateText,
                    symbol: "heart.fill",
                    tint: .red
                )

                metricRow(
                    title: "Energy",
                    value: "\(Int(model.workout.activeEnergy)) kcal",
                    symbol: "flame.fill",
                    tint: .orange
                )
            }

            Section {
                Button {
                    model.workout.isRunning ? model.workout.end() : model.workout.start()
                } label: {
                    Label(
                        model.workout.isRunning ? "Finish Walk" : "Start Walk",
                        systemImage: model.workout.isRunning ? "stop.circle.fill" : "play.circle.fill"
                    )
                    .foregroundStyle(model.workout.isRunning ? .red : .green)
                }

                if let workout = model.lastFinishedWorkout, !model.workout.isRunning {
                    Label("Saved \(workout.durationText)", systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Go Walk")
        .task {
            await model.workout.requestAuthorization()
        }
    }

    private var heartRateText: String {
        guard model.workout.heartRate > 0 else { return "-- bpm" }
        return "\(Int(model.workout.heartRate)) bpm"
    }

    private func metricRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .monospacedDigit()
            }
        }
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        GoWalkView()
            .environment(WatchModel())
    }
}
