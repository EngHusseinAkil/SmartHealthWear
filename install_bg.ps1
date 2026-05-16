$src = "C:\Users\User\.gemini\antigravity\brain\ac3dfc32-0832-444a-8116-1d36b7b82f78\health_bg_1777407245362.png"
$dst = "C:\Users\User\Desktop\project\HealthMonitor\HealthMonitor\app\src\main\res\drawable\bg_app.png"
$old = "C:\Users\User\Desktop\project\HealthMonitor\HealthMonitor\app\src\main\res\drawable\bg_app.xml"

Copy-Item $src -Destination $dst -Force
if (Test-Path $old) { Remove-Item $old -Force }

Write-Host "SUCCESS! bg_app.png is installed and bg_app.xml removed."
Write-Host "Now rebuild your app in Android Studio."
Read-Host "Press Enter to close"
