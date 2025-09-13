build:
	xcodebuild -project SimplySecure.xcodeproj -scheme SimplySecure -configuration Debug build
run: kill build
	open /Users/sridatta.bandreddi/Library/Developer/Xcode/DerivedData/SimplySecure-fuklfyarwyekmvdxuwtmjiqveytk/Build/Products/Debug/SimplySecure.app
log:
	log stream --predicate 'process == "SimplySecure"' --level debug | grep "🥷"
kill:
	@echo "Killing SimplySecure app if running..."
	@pkill -x SimplySecure || true
