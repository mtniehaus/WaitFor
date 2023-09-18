Start-Transcript "C:\Windows\Temp\WaitFor-Done.log"

Import-Module LocalMDM

# Get the policy provider name

$provider = (Get-ItemProperty "HKlM:\Software\Oofhours" -Name "PolicyProvider").PolicyProvider

# Report that the app is done

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/$provider/WaitApp/InstallationState" -Cmd Add -Format int -Data 3
$result | Out-Host

$result = Send-LocalMDMRequest -OmaUri "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/$provider/WaitApp/InstallationState" -Cmd Replace -Format int -Data 3
$result | Out-Host

# Save that we are done in the registry

Set-ItemProperty -Path "HKLM:\Software\Oofhours" -Name "Done" -Value "true"

Stop-Transcript