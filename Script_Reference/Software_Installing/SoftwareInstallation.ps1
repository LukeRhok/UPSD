if (Test-Path ".\Script_Reference\UPSD_Settings.csv"){
    $Global:SettingsSave = Import-Csv ".\Script_Reference\UPSD_Settings.csv"
    $CurrentLocation = $Global:SettingsSave.Runlocation
    Set-Location "$CurrentLocation" #Sets new location
    $SoftwarePath = $Global:SettingsSave.SoftwareFolder

    if(test-path "$SoftwarePath"){

        $File = Get-ChildItem -Path ".\Script_Reference\Software_Installing\" |
        Where-Object {$_.Name -Notlike "~*.csv"}
    
        #For Each CSV file we will get the file name (Computer Name) and the contents (Software)
        Foreach ($Computer in $File.BaseName) {    
        
            $ImportComputer = Import-Csv ".\Script_Reference\Software_Installing\$Computer.csv"
            Rename-Item -path ".\Script_Reference\Software_Installing\$Computer.csv" -NewName "~$Computer.csv" -Force
       
            $a = New-Object -comobject wscript.shell
            $SoftwareName = $ImportComputer.SoftwareName
            $InstallArray = @()

            #Gets all checked software and indexes them next to the software's directory.
            foreach ($Install in $SoftwareName){
                $InstallIndex = (0..($SoftwareName.Count-1)) | where {$SoftwareName[$_] -eq $Install}
                $InstallArray += $InstallIndex
            }#Foreach Checked to index

            #installs the software one at a time locally or remotely.
            foreach ($Installation in $InstallArray){
                Add-Type -AssemblyName System.Windows.Forms
                #~~< PleaseWaitInstallation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                $PleaseWaitInstallation = New-Object System.Windows.Forms.Form
                $PleaseWaitInstallation.AutoSize = $true
                $PleaseWaitInstallation.ClientSize = New-Object System.Drawing.Size(328, 91)
                $PleaseWaitInstallation.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
                $PleaseWaitInstallation.ShowInTaskbar = $false
                $PleaseWaitInstallation.Text = "PleaseWait..."
                #~~< lblCurrentInstallation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                $lblCurrentInstallation = New-Object System.Windows.Forms.Label
                $lblCurrentInstallation.Font = New-Object System.Drawing.Font("Times New Roman", 14.25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
                $lblCurrentInstallation.Location = New-Object System.Drawing.Point(-3, 45)
                $lblCurrentInstallation.Size = New-Object System.Drawing.Size(328, 37)
                $lblCurrentInstallation.TabIndex = 2
                $lblCurrentInstallation.Text = $ImportComputer.SoftwareName[$Installation]
                $lblCurrentInstallation.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                #~~< lblPleaseWaitInstall >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                $lblPleaseWaitInstall = New-Object System.Windows.Forms.Label
                $lblPleaseWaitInstall.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12.0, ([System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline)), [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
                $lblPleaseWaitInstall.Location = New-Object System.Drawing.Point(-3, 0)
                $lblPleaseWaitInstall.Size = New-Object System.Drawing.Size(328, 41)
                $lblPleaseWaitInstall.TabIndex = 0
                $lblPleaseWaitInstall.Text = "The selected software is currently installing on:  $Computer"+[char]13+[char]10
                $lblPleaseWaitInstall.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                $PleaseWaitInstallation.Controls.Add($lblCurrentInstallation)
                $PleaseWaitInstallation.Controls.Add($lblPleaseWaitInstall)
                $PleaseWaitInstallation.Cursor = [System.Windows.Forms.Cursors]::WaitCursor

                $PleaseWaitInstallation.Visible = $True
                $PleaseWaitInstallation.Update()
                
                psexec "\\$Computer" -s $ImportComputer.FullName[$Installation]
                #Enables PSRemoting        
                psexec "\\$Computer" -u .\sfisupport -p SFIGl@bal! -d powershell.exe "enable-psremoting -force"            

                #Checks to see if setup.exe and/or msiexec is running before continuing to the next software.
                $CADCheck = $ImportComputer.SoftwareName[$Installation]
                "Auto","auto"|%{if($CADCheck.Contains($_)){
                    Do{
                        if (Get-Process -name setup, msiexec -computername $Computer -ErrorAction SilentlyContinue){
                            Invoke-Command -ComputerName $Computer {Wait-Process setup, msiexec -ErrorAction SilentlyContinue}
                            Start-Sleep -s 5
                            $RemoteProcessStatement = "True"
                        }#If get-process command block
                        else {
                            $RemoteProcessStatement = "False"
                        }
                    }
                    Until($RemoteProcessStatement -eq "False")
                }}#if (get-process) statement
                $PleaseWaitInstallation.close() #closes dialog box for next software
            }#Foreach Index to install
            #closes please wait form and shows a popup saying that the Software installation is compelete.
            $PleaseWaitInstallation.close()
            $a.popup("Software Installation Complete for $Computer!",0,"Complete!")
            Remove-Item ".\Script_Reference\Software_Installing\~$Global:Computer.csv"
        }
    }else{
            $a = New-Object -comobject wscript.shell
            $intAnswer = $a.popup("Please make sure the proper`rsoftware path in the settings`rais set correctly.",0,"Error!")
        }#If softwarefiles arn't set
    }else{
        $a = New-Object -comobject wscript.shell
        $intAnswer = $a.popup("Please restart the main window to ensure `rthat the script is running in the correct location.",0,"Error!")
    }#if settings file exists