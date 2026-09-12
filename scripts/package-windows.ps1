# Run from a Windows PowerShell terminal after `mvn -pl javafx-desktop clean package`.
# For a production installer, use a Windows JDK 21 and test the generated runtime image.
$jar="javafx-desktop\target\javafx-desktop-1.0.0.jar"
if (!(Test-Path $jar)) { Write-Error "Build the JavaFX module first."; exit 1 }
# JavaFX native dependencies should be assembled with the platform-specific Maven build.
jpackage --name EPMS-Payroll --input javafx-desktop\target --main-jar javafx-desktop-1.0.0.jar --main-class com.epms.desktop.MainApp --type exe --win-menu --win-shortcut
