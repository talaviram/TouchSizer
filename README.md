TouchSizer
----------

A touchbar utility to add macOS _traffic-lights_ (Close, Minimize, Fullscreen) buttons.

This isn't complete so it still can fail/throw exceptions.
Also, some apps (like Adobe Photoshop, uses customized elements so the accessibility api would fail on them)

In order to control windows, It uses [AXSwift](https://github.com/tmandry/AXSwift) as a backend for macOS Accessibility API.

(So it needed to be enabled from System Preferences Privacy)

__Building:__

1. Make sure you have cocoapods.
2. Run `pod install`.
3. Open `TouchSizer.xcworkspace`.
4. build...
