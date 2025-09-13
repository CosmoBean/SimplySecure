build:
	xcodebuild -project SimplySecure.xcodeproj -scheme SimplySecure -configuration Debug build
run: build
	open /Users/sridatta.bandreddi/Library/Developer/Xcode/DerivedData/SimplySecure-fuklfyarwyekmvdxuwtmjiqveytk/Build/Products/Debug/SimplySecure.app
log:
	log stream --predicate 'process == "SimplySecure"' --level debug | grep "🥷"