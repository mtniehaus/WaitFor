Start-Transcript "C:\Windows\Temp\WaitFor-Initialize.log"

# Tell CSP that WaitFor supports tracking apps

$rt = Get-CimInstance -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_TrackedResourceTypes04 -Filter "InstanceID = 'TrackedResourceTypes' AND ParentID = './Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/WaitFor'"
if ($rt) {
	Write-Host "TrackedResourceTypes already exists for WaitFor provider, setting Apps to true"
	$rt.Apps = $true
	Set-CimInstance -CimInstance $rt
} else {
	Write-Host "Creating WaitFor TrackedResourceTypes with Apps = true"
	$resourceTypesClass = Get-CimClass -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_TrackedResourceTypes04
	$rt = New-CimInstance -CimClass $resourceTypesClass -Property @{
		InstanceID = "TrackedResourceTypes"; ParentID="./Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders/WaitFor"; Apps = $true }
}

# Set the installation state

$pp = Get-CimInstance -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_PolicyProviders02_01 -Filter "InstanceID = 'WaitFor'"
if ($pp) {
	Write-Host "WaitFor policy provider already exists, setting InstallationState = 3"
	$pp.InstallationState = 3
	Set-CimInstance -CimInstance $pp
} else {
	Write-Host "Creating WaitFor policy provider with InstallationState = 3"
	$policyProviderClass = Get-CimClass -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_PolicyProviders02_01
	$pp = New-CimInstance -CimClass $policyProviderClass -Property @{
		InstanceID = "WaitFor"; ParentID="./Vendor/MSFT/EnrollmentStatusTracking/DevicePreparation/PolicyProviders"; InstallationState = 3 }
}

# Create the app, saying it is not installed (InstallationState = 1)

$tc = Get-CimInstance -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_Tracking03_02 -Filter "InstanceID = 'WaitForApp'"
if ($tc) {
	Write-Host "WaitForApp already exists, setting InstallationState = 1"
	$tc.InstallationState = 1
	Set-CimInstance -CimInstance $tc
} else {
	Write-Host "Creating WaitForApp with InstallationState = 1"
	$trackingClass = Get-CimClass -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_Tracking03_02
	$tc = New-CimInstance -CimClass $trackingClass -Property @{
		InstanceID = "WaitForApp"; ParentID="./Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/WaitFor"; InstallationState = 1 }
}

# Indicate that we are done telling what to track

$dc = Get-CimInstance -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_PolicyProviders03_01 -Filter "InstanceID = 'WaitFor'"
if ($dc) {
	Write-Host "Setting TrackingPoliciesCreated"
	$dc.TrackingPoliciesCreated = $true
	Set-CimInstance -CimInstance $dc
} else {
	Write-Host "Creating and setting TrackingPoliciesCreated"
	$doneClass = Get-CimClass -Namespace root\cimv2\mdm\dmmap -ClassName MDM_EnrollmentStatusTracking_PolicyProviders03_01
	$dc = New-CimInstance -CimClass $doneClass -Property @{
		InstanceID = "WaitFor"; ParentID="./Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/PolicyProviders"; TrackingPoliciesCreated = $true }
}

# Force a restart

Restart-Computer -Force

Stop-Transcript