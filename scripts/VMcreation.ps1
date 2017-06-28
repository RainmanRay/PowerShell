


function New-SpecifiedVM
{
param(
[string[]]$ComputerName='localhost',
[ValidateSet('C','D','E')]
[string]$VMStoreDir='C',
[string]$VmNamePrefix='08R2'
)

[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null  
Write-Host "Runtime required DLL loaded";
Write-Host "Make sure you run this script as Admin";


$DriveAvailible=Get-PSDrive|Where-Object {$_.Free -gt 15};

if(($DriveAvailible|Measure-Object).Count -lt 1)
{
Write-Host "There is no enough free space for new VM hosting!Script will terminate!";
Start-Sleep -Seconds 3;
Exit
}
$VMStoreDirRoot="$VMStoreDir`:\Hyper-V";
if(!(Test-Path -Path $VMStoreDirRoot))
{
New-Item -ItemType Directory -Path $VMStoreDirRoot
}
$index=(Get-ChildItem -Path $VMStoreDirRoot|Measure-Object).Count

if($index -lt 10) 
{
$index="0$index"
};

$VMStoredPath="$VMStoreDirRoot\$VmNamePrefix$index"

New-Item -ItemType Directory -Path $VMStoredPath

Write-Host -ForegroundColor Green "Select the source VHD"
###################################################################
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = ""
$OpenFileDialog.ShowDialog() | Out-Null
$SourceVHD=$OpenFileDialog.FileName
$SourceFileName=$OpenFileDialog.SafeFileName
###################################################################

Write-Host -ForegroundColor Yellow "Copy source VHD to desiteny directory......"
Copy-Item -LiteralPath $SourceVHD -Destination $VMStoredPath
Write-Host -ForegroundColor Yellow "Done!"




$VmSwitch=Get-VMSwitch|Where-Object {$_.SwitchType -eq "External"}|Select-Object -Index 0

New-VM -Name "$VmNamePrefix$index" -Path $VMStoredPath -MemoryStartupBytes 256mb -SwitchName $VmSwitch.Name `
 -VHDPath "$VMStoredPath\$SourceFileName"  -Generation 1|
 Set-VM -ProcessorCount 4 -DynamicMemory;
 Get-VM|Where-Object {$_.Name -eq "$VmNamePrefix$index"}| Start-VM 
 }