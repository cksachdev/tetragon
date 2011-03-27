@echo off
cd "@path_pub@"
echo Creating IPA file (@target@). This will take a few minutes ...
"@java_32bit@" -jar "@air_developertool@" -package -target @target@ -storetype pkcs12 -keystore "@air_ios_certificate_path@" -storepass @air_ios_certificate_password@ -provisioning-profile "@air_ios_provprofile_path@" "@path_pub@/@app_publishname@_ios" "@path_pub@/@app_publishname@_ios.tmp"
del "@app_publishname@_ios.tmp" /Q
echo Done!
