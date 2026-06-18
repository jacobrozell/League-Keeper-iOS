import SwiftUI

/// Attendance view - record who is present and weekly settings.
struct AttendanceView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var viewModel: AttendanceViewModel
    /// When true, shows a banner that attendance is already confirmed for this week.
    var showsConfirmedBanner: Bool = false
    /// One-time coach mark for first-week attendance (tournament detail).
    var showsCoachMark: Bool = false
    var onDismissCoachMark: (() -> Void)? = nil
    /// When non-nil, called after confirming attendance.
    /// Parameters: already confirmed this week, tables were cleared and need reseating.
    var onConfirm: ((Bool, Bool) -> Void)? = nil
    
    var body: some View {
        List {
            if showsCoachMark {
                Section {
                    CoachMarkBanner(
                        title: "Start each week here",
                        message: "Mark who's here, then tap Confirm Attendance to unlock round scoring.",
                        onDismiss: { onDismissCoachMark?() }
                    )
                }
            }

            if showsConfirmedBanner, viewModel.isAttendanceConfirmed {
                Section {
                    Label {
                        Text("Attendance confirmed for Week \(viewModel.currentWeek). Update toggles and confirm again to change who's here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppConstants.AccessibleColors.activeStatus)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Attendance confirmed for week \(viewModel.currentWeek). Update toggles and confirm again to change.")
                }
            }

            Section("This Week") {
                LabeledToggle(
                    title: "Count achievements this week",
                    isOn: $viewModel.achievementsOnThisWeek
                )
            }
            
            Section {
                if AdaptiveLayout.usesTwoColumnPlayerGrid(horizontalSizeClass: horizontalSizeClass) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(viewModel.players, id: \.id) { player in
                            attendancePlayerRow(player)
                        }
                    }
                } else {
                    ForEach(viewModel.players, id: \.id) { player in
                        attendancePlayerRow(player)
                    }
                }

                addPlayerRow
            } header: {
                HStack {
                    Text("Players")
                    Spacer()
                    Text(viewModel.presentCountLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    if !viewModel.canConfirmAttendance {
                        Text("Mark at least one player present to continue.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let hint = viewModel.podLayoutHint {
                        Text(hint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Button("Mark all") {
                            viewModel.markAllPresent()
                        }
                        .accessibilityIdentifier("attendanceMarkAll")
                        Spacer()
                        Button("Clear all") {
                            viewModel.markAllAbsent()
                        }
                        .accessibilityIdentifier("attendanceClearAll")
                    }
                    .font(.subheadline)
                }
            }
        }
        .listStyle(.insetGrouped)
        .adaptiveContentWidth()
        .navigationTitle("Attendance – Week \(viewModel.currentWeek)")
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                PrimaryActionButton(
                    title: "Confirm Attendance",
                    action: {
                        let wasUpdate = viewModel.isAttendanceConfirmed
                        viewModel.confirmAttendance()
                        AppHaptics.success()
                        onDismissCoachMark?()
                        onConfirm?(wasUpdate, viewModel.lastConfirmClearedTables)
                    },
                    isDisabled: !viewModel.canConfirmAttendance,
                    disabledAccessibilityHint: "Mark at least one player present to continue."
                )
                .accessibilityIdentifier("Confirm Attendance")
                .padding()
            }
            .background(.bar)
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    @ViewBuilder
    private func attendancePlayerRow(_ player: Player) -> some View {
        PlayerRow(
            name: viewModel.displayName(for: player),
            mode: .toggleable(isOn: Binding(
                get: { viewModel.isPresent(player.id) },
                set: { _ in viewModel.togglePresence(for: player.id) }
            ))
        )
    }

    @ViewBuilder
    private var addPlayerRow: some View {
        HStack {
            TextField("Add player this week", text: $viewModel.newPlayerName)
                .textContentType(.name)
                .submitLabel(.done)
                .accessibilityLabel("Add player this week")
                .accessibilityIdentifier("attendanceAddPlayerField")
                .onSubmit {
                    viewModel.addWeeklyPlayer()
                }
            
            Button("Add") {
                viewModel.addWeeklyPlayer()
            }
            .accessibilityLabel("Add player")
            .accessibilityIdentifier("attendanceAddPlayerButton")
            .disabled(viewModel.newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
    }
}

#Preview {
    NavigationStack {
        AttendanceView(
            viewModel: AttendanceViewModel(context: PreviewContainer.shared.mainContext),
            onConfirm: nil
        )
    }
}
