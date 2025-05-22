# DigeHealth Researcher Builds

The update builds for the researcher facing application for Dige Health.

### Releasing an update

Setup:
1. Generate the Sparkle keys [digehealth/macos/Pods/Sparkle/bin/generate_keys]

Steps:
1. Generate a notarized build of the DigeHealth Reseacher app
2. Run the bin/release.sh script that is taking care of releasing the update via Sparkle or manually do the steps 3 - 8
```
    ./bin/release.sh {DIGEHEALTH_RESEARCHER_APP_PATH}
```
3. Create a zip of the .app file
```
    zip -r --symlinks "DigeHealth Reseacher.app"
```
4. Codesign the zip archive with the Sparkle's bin/sign_update script [digehealth/macos/Pods/Sparkle/bin/sign_update]
5. Generate the appcase.xml file with the Sparkle's bin/generate_appcast [digehealth/macos/Pods/Sparkle/bin/generate_appcast]
6. Push on the main branch in the repo 