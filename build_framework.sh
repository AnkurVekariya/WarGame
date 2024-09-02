# A shell script for creating an XCFramework for iOS.

# Starting from a clean slate
# Removing the build and output folders
rm -rf ./build &&\
rm -rf ./output &&\

# Cleaning the workspace cache
xcodebuild \
    clean \
    -workspace WarGame.xcworkspace \
    -scheme WarGameSDK

# Create an archive for iOS devices
xcodebuild \
    archive \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        -workspace WarGame.xcworkspace \
        -scheme WarGameSDK \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -archivePath build/WarGameSDK-iOS.xcarchive

# Create an archive for iOS simulators
xcodebuild \
    archive \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        -workspace WarGame.xcworkspace \
        -scheme WarGameSDK \
        -configuration Release \
        -destination "generic/platform=iOS Simulator" \
        -archivePath build/WarGameSDK-iOS_Simulator.xcarchive

# Convert the archives to .framework
# and package them both into one xcframework
xcodebuild \
    -create-xcframework \
    -archive build/WarGameSDK-iOS.xcarchive -framework WarGameSDK.framework \
    -archive build/WarGameSDK-iOS_Simulator.xcarchive -framework WarGameSDK.framework \
    -output output/WarGameSDK.xcframework &&\
    rm -rf build
