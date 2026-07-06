import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var purchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                NWTheme.backdrop.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(NWTheme.amberBright)
                        .padding(.top, 40)

                    Text("Nightwin Pro")
                        .font(NWTheme.titleFont)
                        .foregroundStyle(NWTheme.ink)

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow("infinity", "Keep unlimited nightly wins")
                        featureRow("sparkles", "Full constellation view")
                        featureRow("heart.fill", "Support future updates")
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    Button {
                        purchasing = true
                        Task {
                            await purchases.purchase()
                            purchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        HStack {
                            if purchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(purchases.product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Pro")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(NWTheme.amber)
                        .foregroundStyle(NWTheme.backdrop)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .disabled(purchasing || purchases.product == nil)
                    .padding(.horizontal, 24)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .buttonStyle(.plain)
                    .font(.footnote)
                    .foregroundStyle(NWTheme.inkFaded)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .buttonStyle(.plain)
                        .foregroundStyle(NWTheme.ink)
                }
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(NWTheme.amberBright)
                .frame(width: 24)
            Text(text)
                .foregroundStyle(NWTheme.ink)
        }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
