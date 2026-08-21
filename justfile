project    := "MiniMint.xcodeproj"
scheme     := "MiniMint"
bundle_id  := "ca.minimint.MiniMint"
simulator  := "iPhone 17"
os         := "26.5"
derived    := ".build/DerivedData"

destination := "platform=iOS Simulator,name=" + simulator + ",OS=" + os

# List available recipes.
default:
    @just --list

# Build the app for the simulator.
build:
    xcodebuild -project {{project}} -scheme {{scheme}} \
        -destination '{{destination}}' \
        -derivedDataPath {{derived}} build

# Run unit + UI tests on the simulator.
test:
    xcodebuild -project {{project}} -scheme {{scheme}} \
        -destination '{{destination}}' test

# Remove build artifacts.
clean:
    xcodebuild -project {{project}} -scheme {{scheme}} clean
    rm -rf {{derived}}

# Boot the simulator and open the Simulator app.
boot:
    xcrun simctl boot "{{simulator}}" || true
    open -a Simulator

# Build, install, and launch the app on the booted simulator.
run: boot build
    xcrun simctl install booted \
        "{{derived}}/Build/Products/Debug-iphonesimulator/{{scheme}}.app"
    xcrun simctl launch booted {{bundle_id}}

# Uninstall the app from the booted simulator.
uninstall:
    xcrun simctl uninstall booted {{bundle_id}}

# Build, run, and rebuild on source changes.
dev: run
    fswatch -o -e '\.build' MiniMint/ | xargs -n1 -I{} just run
