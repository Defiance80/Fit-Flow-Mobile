import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    // secure overlay and its constraints
    private var secureView: UIView?
    private var secureViewConstraints: [NSLayoutConstraint] = []

    // Observers tokens
    private var screenshotObserver: NSObjectProtocol?
    private var screenCaptureObserver: NSObjectProtocol?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()

        // Register plugins
        GeneratedPluginRegistrant.register(with: self)

        // Setup screenshot + screen recording detection on main thread
        DispatchQueue.main.async { [weak self] in
            self?.setupScreenshotDetection()
            self?.setupScreenRecordingDetection()
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Screenshot detection
    private func setupScreenshotDetection() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        let screenshotChannel = FlutterMethodChannel(
            name: "screenshot_detector",
            binaryMessenger: controller.binaryMessenger
        )

        // Use main queue for UI-safe handling
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            screenshotChannel.invokeMethod("onScreenshotTaken", arguments: nil)
            // Optionally add overlay here if you want to block immediately:
            // self.addSecureViewIfNeeded()
        }
    }

    // MARK: - Screen recording detection
    private func setupScreenRecordingDetection() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        let recordingChannel = FlutterMethodChannel(
            name: "screen_recording_detector",
            binaryMessenger: controller.binaryMessenger
        )

        // Initial state: notify Flutter of current capture state
        let initialCaptured = UIScreen.main.isCaptured
        recordingChannel.invokeMethod(initialCaptured ? "onScreenRecordingDetected" : "onScreenRecordingStopped", arguments: nil)
        if initialCaptured {
            addSecureViewIfNeeded()
        }

        // Use the system notification for capture changes
        screenCaptureObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let self = self else { return }
            let isCaptured = UIScreen.main.isCaptured
            if isCaptured {
                self.addSecureViewIfNeeded()
                recordingChannel.invokeMethod("onScreenRecordingDetected", arguments: nil)
            } else {
                self.removeSecureViewIfNeeded()
                recordingChannel.invokeMethod("onScreenRecordingStopped", arguments: nil)
            }
        }
    }

    // MARK: - Secure overlay (safe)
    private func addSecureViewIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let window = self.window else { return }
            // If already present, do nothing
            if self.secureView != nil { return }

            let overlay = UIView()
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.backgroundColor = .black
            overlay.isUserInteractionEnabled = false
            overlay.accessibilityElementsHidden = true

            window.addSubview(overlay)

            // Constrain to window's safe area / bounds
            let constraints = [
                overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: window.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)

            self.secureView = overlay
            self.secureViewConstraints = constraints
        }
    }

    private func removeSecureViewIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let overlay = self.secureView else { return }

            // Deactivate constraints cleanly
            if !self.secureViewConstraints.isEmpty {
                NSLayoutConstraint.deactivate(self.secureViewConstraints)
                self.secureViewConstraints.removeAll()
            }

            overlay.removeFromSuperview()
            self.secureView = nil
        }
    }

    // MARK: - Clean up on termination / background if needed
    override func applicationWillTerminate(_ application: UIApplication) {
        super.applicationWillTerminate(application)
        cleanupObservers()
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        // Optionally remove overlay when backgrounding to avoid layout work during scene transitions
        removeSecureViewIfNeeded()
    }

    private func cleanupObservers() {
        if let obs = screenshotObserver {
            NotificationCenter.default.removeObserver(obs)
            screenshotObserver = nil
        }
        if let obs = screenCaptureObserver {
            NotificationCenter.default.removeObserver(obs)
            screenCaptureObserver = nil
        }
    }
}
