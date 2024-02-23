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

flutter run
first time takes time to use android phone as device. need to turn on usb install, give all permissions, etc.

note: flutter is just java but 40 years younger, means less weirdites and less legacy to worry about. still strongly typed but less verbose.

scaffold: skeleteon widget that keeps everything together
container : flexible widet that can do a lot of things , set height and width

shortcut : stl -> compontent with stateless widget

assets have to be manually loaded in pubspec.yaml
assets:
	- assets 

routing problem, changed homepage to snakecase to fix the issue, main.dart also changed to add routers but did not help

use serve to run production code from react/vite

### prettier config
add prettier extention
need .prettierrc and .prettierignore files in project
add all .gitignore to .prettierignore and src files
goo to > open user settings as json . add `"editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,`
prettier dev dependencies : $npm i -D eslint prettier eslint-config-prettier eslint-plugin-react
    
