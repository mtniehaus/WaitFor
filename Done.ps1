Start-Transcript "C:\Windows\Temp\WaitFor-Done.log"

# Report that the app is done

$app = Get-CimInstance -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_Tracking03_02 -Filter "InstanceID = 'WaitForApp'"
$app.InstallationState = 3
Set-CimInstance -CimInstance $app

Stop-Transcript