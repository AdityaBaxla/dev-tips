## installing Flutter and Andoid to run without android studio

need
flutter sdk
android sdk cli tools
java (dont knw )

android sdk needs to have folders inside /latest otherwise it wont run. try going into $tool/bin and run sdkmanager to check what its saying.

add flutter path, android, androidsdk, androidstudio sdk, .. bin. to path

```setx JAVA_HOME “C:\Android\openjdk”
setx ANDROID_HOME “C:\Android”
setx path “%path%;”C:\Android\cmdline-tools;C:\Android\cmdline-tools\tools;C:\Android\cmdline-tools\tools\bin;C:\Android\flutter\bin”`
```

setx to set path variables from cmd.

`$flutter doctor`
check what needs to be installed

install sdk from sdkmanager

````sdkmanager “system-images;android-28;default;x86_64”
sdkmanager “platform-tools”
sdkmanager "build-tools;28.0.3"
sdkmanager "platforms;android-28"
sdkmanager emulator```

attach flutter to android sdk
`flutter config --android-sdk C:\Android\`
````
