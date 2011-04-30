@echo off
cd "D:\Work\Dev\Eclipse\com.hexagonstar.tetragon/pub"
echo Creating IPA file (ipa-app-store). This will take a few minutes ...
"C:/Program Files (x86)/Java/jre/bin/java.exe" -jar "C:/Users/sascha/Applications/FlexSDK/4.5.0/lib/adt.jar" -package -target ipa-app-store -storetype pkcs12 -keystore "D:/Work/Dev/Eclipse/.metadata/.user/ios_certificate.p12" -storepass redSapphire17 -provisioning-profile "D:/Work/Dev/Eclipse/.metadata/.user/ios.mobileprovision" "D:\Work\Dev\Eclipse\com.hexagonstar.tetragon/pub/tetragon_100" "D:\Work\Dev\Eclipse\com.hexagonstar.tetragon/pub/tetragon_100_ios.tmp"
echo Done!
del "tetragon_100_ios.tmp" /Q
del "tetragon_100_ios_create.bat" /Q
