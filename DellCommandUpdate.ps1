  <#
  Author : Madhu Sunke
  Date : 11/30/2021
  Script to execute Dell command update and gather execution output.
  #>
  #https://www.dell.com/support/manuals/en-in/command-update/dellcommandupdate_rg/command-line-interface-error-codes?guid=guid-fbb96b06-4603-423a-baec-cbf5963d8948&lang=en-us
  $ignoreExitCodesHash = @{
            0="Command execution was successful."
            1="A reboot was required from the execution of an operation."
            2="An unknown application error has occurred."
            3="The current system manufacturer is not Dell."
            4="The CLI was not launched with administrative privilege."
            5="A reboot was pending from a previous operation."
            6="Another instance of the same application (UI or CLI) is already running."
            7="The application does not support the current system model."
            8="No update filters have been applied or configured."
            100="While evaluating the command line parameters, no parameters were detected."
            101="While evaluating the command line parameters, no commands were detected."
            102="While evaluating the command line parameters, invalid commands were detected."
            103="While evaluating the command line parameters, duplicate commands were detected."
            104="While evaluating the command line parameters, the command syntax was incorrect."
            105="While evaluating the command line parameters, the option syntax was incorrect."
            106="While evaluating the command line parameters, invalid options were detected."
            107="While evaluating the command line parameters, one or more values provided to the specific option was invalid."
            108="While evaluating the command line parameters, all mandatory options were not detected."
            109="While evaluating the command line parameters, invalid combination of options were detected."
            110="While evaluating the command line parameters, multiple commands were detected."
            111="While evaluating the command line parameters, duplicate options were detected."
            112="An invalid catalog was detected."
            500="No updates were found for the system when a scan operation was performed."
            501="An error occurred while determining the available updates for the system, when a scan operation was performed."
            502="The cancellation was initiated, Hence, the scan operation is canceled."
            503="An error occurred while downloading a file during the scan operation."
            1000="An error occurred when retrieving the result of the apply updates operation."
            1001="The cancellation was initiated, Hence, the apply updates operation is canceled."
            1002="An error occurred while downloading a file during the apply updates operation."
            1505="An error occurred while exporting the application settings."
            1506="An error occurred while importing the application settings."
            2000="An error occurred when retrieving the result of the Advanced Driver Restore operation."
            2001="The Advanced Driver Restore process failed."
            2002="Multiple driver CABs were provided for the Advanced Driver Restore operation."
            2003="An invalid path for the driver CAB was provided as in input for the driver install command."
            2004="The cancellation was initiated, Hence, the driver install operation is canceled."
            2005="An error occurred while downloading a file during the driver install operation."
            2006="Indicates that the Advanced Driver Restore feature is disabled."
            2007="Indicates that the Advanced Diver Restore feature is not supported."
            2500="An error occurred while encrypting the password during the generate encrypted password operation."
            2501="An error occurred while encrypting the password with the encryption key provided."
            2502="The encrypted password provided does not match the current encryption method."
            3000="The Dell Client Management Service is not running."
            3001="The Dell Client Management Service is not installed."
            3002="The Dell Client Management Service is disabled."
            3003="The Dell Client Management Service is busy."
            3004="The Dell Client Management Service has initiated a self-update install of the application."
            3005="The Dell Client Management Service is installing pending updates."
            }
           
  $DatebeforeDCURun = Get-Date
  $DCu = Start-Process -FilePath "$env:ProgramFiles\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyUpdates -outputLog=`"C:\Windows\Logs\dcu.log`"" -PassThru -ErrorAction SilentlyContinue -WindowStyle Hidden -Wait
  
  Write-Output "Exit codes from dcu : $($DCu.ExitCode)"
  #Get description of DCU exit code 
  $DCUErrorDesc = $ignoreExitCodesHash.GetEnumerator() | ? {$_.name -eq $($DCu.ExitCode)}
  #Get Dell Commandline Update activity info
  Write-Output "DCU exit code description : $($DCUErrorDesc.Value)"
  try{
  $activity = [xml](Get-Content "C:\ProgramData\Dell\UpdateService\Log\Activity.log" -ErrorAction Stop)
  if($activity){
   $activityMsg = ($activity.LogEntries.LogEntry | Select-Object @{label='TimeStamp';expression={[datetime]$_.timestamp}},message  `
            | Sort-Object -Property TimeStamp -Descending `
            | Where-Object {$_.TimeStamp -ge $DatebeforeDCURun} `
            | Select-Object -ExpandProperty message) -join "`n"
         }}catch{
                $activityMsg = ""
      }

Write-Output "DCU Last Activity Info : $activityMsg"

if($DCu.ExitCode -in $($ignoreExitCodesHash.Keys|?{$_ -notin ('500','1002','3001','4','7','8','3')})){
     & shutdown.exe -r -t 180
  }
