import Foundation

/// Whether in-app developer tooling should be shown: only in the simulator or a
/// TestFlight (sandbox receipt) build, never in a shipped App Store build.
var isDeveloperToolingAvailable: Bool {
  #if targetEnvironment(simulator)
  return true
  #else
  return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  #endif
}
