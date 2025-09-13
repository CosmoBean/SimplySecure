# SimplySecure - macOS Security Scanner

A ninja-themed macOS desktop application that performs security scans and gamifies the process of securing your MacBook.

## Features

- **Security Scanning**: Checks OS updates, FileVault encryption, and Safari security settings
- **Gamification**: Earn XP and level up as a ninja while fixing security issues
- **Ninja Theme**: Dark/light mode support with ninja-themed UI
- **Real-time Results**: Instant feedback on security status with actionable fixes

## Requirements

- macOS Ventura (13.0) or later
- Xcode 14.0 or later
- Admin privileges for some security checks

## Setup Instructions

1. **Open in Xcode**:
   ```bash
   open SimplySecure.xcodeproj
   ```

2. **Configure Project**:
   - Set deployment target to macOS 13.0+
   - Ensure "Hardened Runtime" is enabled in Build Settings
   - Add "Allow Execution of JIT-compiled Code" entitlement if needed

3. **Build and Run**:
   - Press `Cmd + R` to build and run
   - The app will appear in a single window

## Security Checks

### OS Updates (40 points)
- Uses `softwareupdate --list` to check for pending updates
- Provides option to run `softwareupdate -i -a` for updates

### FileVault Encryption (30 points)
- Uses `fdesetup status` to verify encryption is enabled
- Guides users to System Settings for manual configuration

### Safari Security (20 points)
- Checks Safari's privacy settings and update status
- Provides instructions for enabling tracking protection

## Gamification System

### Ninja Levels
- **Novice Ninja** (Level 1): 0-199 XP
- **Apprentice Ninja** (Level 2): 200-399 XP  
- **Master Ninja** (Level 3): 400+ XP

### XP Rewards
- Complete each security check: Earn full points
- Fix failed checks: Earn XP and level up
- Progress tracking with visual progress bars

## Project Structure

```
SimplySecure/
├── SimplySecure/
│   ├── SimplySecureApp.swift      # Main app entry point
│   ├── ContentView.swift          # Main UI with dashboard
│   ├── SecurityScanner.swift      # Security scan logic
│   ├── NinjaGameModel.swift       # Gamification system
│   ├── Assets.xcassets           # App icons and assets
│   ├── Info.plist                # App configuration
│   └── SimplySecure.entitlements  # App permissions
├── SimplySecure.xcodeproj        # Xcode project file
└── README.md                     # This file
```

## Usage

1. **Launch the app** - Dashboard shows current ninja level and XP
2. **Run Security Scan** - Click the red "Run Security Scan" button
3. **Review Results** - See your security score and mission list
4. **Fix Issues** - Click "Fix" on failed missions for instructions
5. **Earn XP** - Complete fixes to level up your ninja status

## Technical Details

- **SwiftUI**: Modern declarative UI framework
- **Process**: Native macOS shell command execution
- **UserDefaults**: Persistent game data storage
- **Async/Await**: Non-blocking security scans

## Permissions

The app may request admin privileges for:
- Running `softwareupdate` commands
- Checking FileVault status with `fdesetup`
- Accessing Safari preferences

## Troubleshooting

### Scan Failures
- Ensure you have admin privileges
- Check that Terminal commands work manually
- Some checks may fail in sandboxed environments

### Build Issues
- Verify macOS deployment target is 13.0+
- Check that all Swift files are included in target
- Ensure proper code signing if distributing

## Demo Mode

For hackathon demos:
1. Show the initial scan results
2. Demonstrate fixing a security issue
3. Show XP gain and level progression
4. Highlight the ninja-themed UI

## Future Enhancements

- Network security scans
- Additional browser support
- Leaderboards and achievements
- Custom ninja avatars
- Automated fix execution

---

**Built for HackCMU 2025** 🥷
