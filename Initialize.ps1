Start-Transcript "C:\Windows\Temp\WaitFor-Initialize.log" -Append

# Generate a random provider name just so NodeCache doesn't get in the way.  Save it in the registry

$suffix = Get-Random -Minimum 1 -Maximum 99999
$provider = "WaitFor$suffix"
New-Item -Path "HKLM:\Software\Oofhours"
Set-ItemProperty -Path "HKLM:\Software\Oofhours" -Name "PolicyProvider" -Value $provider
Remove-ItemProperty -Path "HKLM:\Software\Oofhours" -Name "Done" -ErrorAction SilentlyContinue

# Load the LocalMDM module

Install-PackageProvider NuGet -Force
Install-Module LocalMDM -Force

# Register the provider

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/$provider/InstallationState" -Cmd Replace -Format int -Data 1 
$result | Out-Host

# Specify the tracked resource types

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/$provider/TrackedResourceTypes/Apps" -Cmd Add -Format bool -Data true
$result | Out-Host
$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/$provider/TrackedResourceTypes/Apps" -Cmd Replace -Format bool -Data true
$result | Out-Host

# Set the installation state to say that we are installed

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/$provider/InstallationState" -Cmd Replace -Format int -Data 3
$result | Out-Host

# Create the app

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/$provider/WaitApp" -Cmd Add 
$result | Out-Host

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/$provider/WaitApp/InstallationState" -Cmd Add -Format int -Data 1 
$result | Out-Host

# Indicate that we are done telling what to track

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/PolicyProviders/$provider/TrackingPoliciesCreated" -Cmd Add -Format bool -Data true 
$result | Out-Host
$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/PolicyProviders/$provider/TrackingPoliciesCreated" -Cmd Replace -Format bool -Data true 
$result | Out-Host

# Force a restart

# Restart-Computer -Force

Stop-Transcript