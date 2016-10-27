function Startup{
    #ERASE ALL THIS AND PUT XAML BELOW between the @" "@
    $inputXML = @"
<Window x:Name="frmUPSD" x:Class="UPSD_Gui.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:UPSD_Gui"
        mc:Ignorable="d"
        Title="UPSD" Height="600" Width="910" WindowStartupLocation="CenterScreen" Background="#FF4F4F4F" MinWidth="910" MinHeight="600">
    <Grid Height="569" VerticalAlignment="Bottom">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="895"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnAddRemoveSoft" Content="Add/Remove Software" Margin="660,25,60,514" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="9"/>
        <Button x:Name="btnUpdateSoftwareList" Content="Update Software List" Margin="660,63,60,476" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="7"/>
        <Label x:Name="lblComputerName" Content="Computer Name:" Margin="299,67,469,476" FontFamily="Lucida Bright" Foreground="White" FontSize="14"/>
        <Label x:Name="lblUserID" Content="Username:" Margin="343,29,469,514" FontFamily="Lucida Bright" Foreground="White" FontSize="14"/>
        <TextBox x:Name="txtComputerName" Margin="431,70,342,476" MaxLines="1" FontFamily="Lucida Bright" TabIndex="1" AllowDrop="False" VerticalScrollBarVisibility="Disabled"/>
        <TextBox x:Name="txtUserID" Margin="431,32,342,514" MaxLines="1" AutoWordSelection="True" FontFamily="Lucida Bright" TabIndex="0" AllowDrop="False" VerticalScrollBarVisibility="Disabled"/>
        <ListBox x:Name="lstSoftwareAssigned" Margin="537,146,10,10" FontFamily="Microsoft Sans Serif" FontSize="14" Background="#FF8B8B8B" Foreground="White" BorderBrush="Black" SelectionMode="Multiple"/>
        <ListBox x:Name="lstSoftwareAvailable" Margin="10,146,535,10" FontFamily="Microsoft Sans Serif" FontSize="14" Background="#FF8B8B8B" Foreground="White" BorderBrush="Black" SelectionMode="Multiple"/>
        <Button x:Name="btnAddSoft" Content="Add &gt;&gt;" Margin="372,290,373,247" FontFamily="Lucida Bright" Background="#FF666666" Foreground="White" FontSize="14" TabIndex="4" BorderBrush="#FF252525"/>
        <Button x:Name="btnRemoveSoft" Content="&lt;&lt; Remove" Margin="372,326,373,211" FontFamily="Lucida Bright" Background="#FF666666" Foreground="White" FontSize="14" TabIndex="5" BorderBrush="#FF252525"/>
        <Button x:Name="btnExit" Content="Exit" Margin="372,516,373,21" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="11" IsCancel="True"/>
        <Button x:Name="btnInstall" Content="Install" Margin="372,409,373,116" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="9" IsDefault="True"/>
        <Button x:Name="btnSettings" Content="Settings" Margin="60,25,660,514" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="7"/>
        <Label x:Name="lblSoftwareAvailable" Content="Software Available" HorizontalAlignment="Left" Margin="100,115,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="18" Foreground="White"/>
        <Label x:Name="lblSoftwareAssigned" Content="Software Selected" HorizontalAlignment="Left" Margin="626,114,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="18" Foreground="White"/>
        <Button x:Name="btnLoadLists" Content="Load List(s)" Margin="372,146,373,391" Background="#FF2B2B2B" Foreground="White" FontSize="14" FontFamily="Lucida Bright" TabIndex="2"/>
        <Button x:Name="btnSaveList" Content="Save List" Margin="372,184,373,353" Background="#FF2B2B2B" Foreground="White" FontSize="14" FontFamily="Lucida Bright" TabIndex="3"/>
        <Button x:Name="btnCustum" Content="Program Me" Margin="60,63,660,476" FontFamily="Lucida Bright" Background="#FF2B2B2B" Foreground="White" FontSize="14" TabIndex="8" IsEnabled="False"/>
        <TextBlock x:Name="txtblkWarning" HorizontalAlignment="Left" Margin="287,98,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="322" Height="43" FontSize="14" FontFamily="Lucida Bright" Foreground="#FFFF2A2A" TextAlignment="Center"/>
    </Grid>
</Window>
"@       
 
    $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXML
    #Read XAML
 
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
      try{$frmUPSD=[Windows.Markup.XamlReader]::Load( $reader )}
    catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
    #===========================================================================
    # Load XAML Objects In PowerShell
    #===========================================================================
 
    $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $frmUPSD.FindName($_.Name)}
 
    Function Get-FormVariables{
    if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
    }
 
    Get-FormVariables
 
    #===========================================================================
    # Actually make the objects work
    #===========================================================================

    function UPSDSettings{
        #ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Name="frmSettings" x:Class="Settings.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Settings"
        mc:Ignorable="d"
        Title="UPSD Settings" Height="360" Width="520" Background="#FF4F4F4F">
    <Grid>
        <Label x:Name="lblScriptLocation" Content="Location of Script Files: *" HorizontalAlignment="Left" Margin="10,44,0,0" VerticalAlignment="Top" Foreground="#FF00F3FF" FontFamily="Lucida Bright"/>
        <Label x:Name="lblSoftwareFolderLocation" Content="Location of Software Folder:" HorizontalAlignment="Left" Margin="10,117,0,0" VerticalAlignment="Top" Foreground="#FF00FF23" FontFamily="Lucida Bright"/>
        <Label x:Name="lblCustomButtonName_" Content="Button Name:" HorizontalAlignment="Left" Margin="10,218,0,0" VerticalAlignment="Top" Foreground="Yellow" FontFamily="Lucida Bright"/>
        <Label x:Name="lblProgramRunPath" Content="Program run Path:" HorizontalAlignment="Left" Margin="10,246,0,0" VerticalAlignment="Top" Foreground="Yellow" FontFamily="Lucida Bright"/>
        <Label x:Name="lblProgramableButtonTitle" Content="Programmable Button Settings" HorizontalAlignment="Left" Margin="10,184,0,0" VerticalAlignment="Top" Foreground="Yellow" FontFamily="Lucida Bright" FontSize="16" FontWeight="Bold"/>
        <TextBox x:Name="txtScriptLocation" HorizontalAlignment="Left" Height="23" Margin="189,45,0,0" VerticalAlignment="Top" Width="300" VerticalScrollBarVisibility="Disabled"/>
        <TextBox x:Name="txtSoftwareFolderLocation" HorizontalAlignment="Left" Height="23" Margin="189,118,0,0" VerticalAlignment="Top" Width="300" VerticalScrollBarVisibility="Disabled"/>
        <TextBox x:Name="txtButtonName" HorizontalAlignment="Left" Height="23" Margin="131,219,0,0" VerticalAlignment="Top" Width="130" VerticalScrollBarVisibility="Disabled"/>
        <TextBox x:Name="txtProgramRunPath" HorizontalAlignment="Left" Height="23" Margin="131,247,0,0" VerticalAlignment="Top" Width="300" VerticalScrollBarVisibility="Disabled"/>
        <Label x:Name="lblLocationTitle" Content="Main Settings" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="16" Foreground="#FF00F3FF" FontWeight="Bold"/>
        <Button x:Name="btnSave" Content="Save" Margin="200,283,0,0" FontFamily="Lucida Bright" FontSize="14" Background="#FF2B2B2B" Foreground="White" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" HorizontalAlignment="Left" Width="112" Height="35" VerticalAlignment="Top"/>
        <TextBlock x:Name="txtblkWarning" HorizontalAlignment="Left" Margin="189,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="300" Height="26" FontFamily="Lucida Bright" FontSize="14" TextAlignment="Center" Foreground="#FFFF1D1D"/>
        <Label x:Name="lblCommonSoftName" Content="(Optional) Common File Name:" HorizontalAlignment="Left" Margin="10,146,0,0" VerticalAlignment="Top" Foreground="#FF00FF23" FontFamily="Lucida Bright"/>
        <TextBox x:Name="txtCommonSoftName" HorizontalAlignment="Left" Height="23" Margin="210,147,0,0" VerticalAlignment="Top" Width="113" VerticalScrollBarVisibility="Disabled" RenderTransformOrigin="0.299,0.501"/>
        <Label x:Name="lblSoftwareSettingsTitle" Content="Software-List Builder Settings" HorizontalAlignment="Left" Margin="10,83,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="16" Foreground="#FF00FF23" FontWeight="Bold"/>
        <Label x:Name="lblSoftwareExtention" Content="File Extension:" HorizontalAlignment="Left" Margin="329,146,0,0" VerticalAlignment="Top" Foreground="#FF00FF23" FontFamily="Lucida Bright"/>
        <TextBox x:Name="txtSoftwareExtention" HorizontalAlignment="Left" Height="23" Margin="433,147,0,0" VerticalAlignment="Top" Width="49" VerticalScrollBarVisibility="Disabled"/>
        <Label x:Name="lblSoftwareExtentioExample" Content="Note:  Use * as a wildcard.  &#xD;&#xA;Example:  *.msi" HorizontalAlignment="Left" Margin="333,175,0,0" VerticalAlignment="Top" Foreground="#FF00FF23" FontFamily="Lucida Bright"/>

    </Grid>
</Window>
"@       
 
        $inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
        [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        [xml]$XAML = $inputXML
        #Read XAML
 
            $reader=(New-Object System.Xml.XmlNodeReader $xaml)
          try{$frmSettings=[Windows.Markup.XamlReader]::Load( $reader )}
        catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
        #===========================================================================
        # Load XAML Objects In PowerShell
        #===========================================================================
 
        $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $frmSettings.FindName($_.Name)}
 
        Function Get-FormVariables{
        if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
        write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
        get-variable WPF*
        }
 
        Get-FormVariables
 
        #===========================================================================
        # Actually make the objects work
        #===========================================================================
    
        if (Test-Path ".\Script_Reference\UPSD_Settings.csv" ){
            #sources the CSVSettings file
            $Global:SettingsSave = Import-Csv ".\Script_Reference\UPSD_Settings.csv"
       
            #Reloads text back into text boxs
            $WPFtxtScriptLocation.text = $Global:SettingsSave.RunLocation
            $WPFtxtSoftwareFolderLocation.text = $Global:SettingsSave.SoftwareFolder
            $WPFtxtButtonName.text = $Global:SettingsSave.ButtonName
            $WPFtxtProgramRunPath.text = $Global:SettingsSave.ButtonPath

        }
    
        #When the Save button is clicked it will save all the text in each text box into a CSV file as their own property.
        $WPFbtnSave.Add_Click({
            #tests if the Script location is filled
            if ($WPFtxtScriptLocation.text){
                          
                $Global:ScriptLocation = $WPFtxtScriptLocation.text
                $Global:SoftwareFolder = $WPFtxtSoftwareFolderLocation.text
                $Global:CommonSoftName = $WPFtxtCommonSoftName.text
                $Global:SoftwareExtention = $WPFtxtSoftwareExtention.text
                $Global:CustomButtonName = $WPFtxtButtonName.text
                $Global:CustomButtonPath = $WPFtxtProgramRunPath.text
                
                Set-Location "$Global:ScriptLocation" #Sets new location
                $UPSDSettings = New-Object System.Object
                $UPSDSettings | Add-Member -NotePropertyName RunLocation -NotePropertyValue $Global:ScriptLocation
                $UPSDSettings | Add-Member -NotePropertyName SoftwareFolder -NotePropertyValue $Global:SoftwareFolder
                $UPSDSettings | Add-Member -NotePropertyName CommonSoftName -NotePropertyValue $Global:CommonSoftName
                $UPSDSettings | Add-Member -NotePropertyName SoftwareExtention -NotePropertyValue $Global:SoftwareExtention
                $UPSDSettings | Add-Member -NotePropertyName ButtonName -NotePropertyValue $Global:CustomButtonName
                $UPSDSettings | Add-Member -NotePropertyName ButtonPath -NotePropertyValue $Global:CustomButtonPath
                $UPSDSettingsArray += $UPSDSettings
                #Adds all the sellected software to a CSV list for SoftwareInstallation.exe to analyse and install from.
                $UPSDSettingsArray | Export-Csv -NoType -Path ".\Script_Reference\UPSD_Settings.csv"

                #will make sure that the CSV was created and that it was created in the correct location.
                try{$UPSDSettingsArray | Export-Csv -NoType -Path ".\Script_Reference\UPSD_Settings.csv"}
                catch{$a = New-Object -comobject wscript.shell
                    $intAnswer = $a.popup("Wrong Location Entered!!`rPlease enter the correct location of the script",0,"Error!")
                    UPSDSettings}

                $frmSettings.Close() | out-null
                $frmUPSD.Close() | out-null
                Startup
            }else{
            $WPFtxtblkWarning.content = "**Please add the location of this script!!**"
            $WPFlblScriptLocation.Foreground = "#FFFF0202"
            }
        })





        #===========================================================================
        # Shows the form
        #===========================================================================
        #write-host "To show the form, run the following" -ForegroundColor Cyan
        $frmSettings.ShowDialog() | out-null

    }

    function Loadlists{
        if (!$WPFtxtUserID){

        }else{
        RefreshSoftList
        }


    } #loads a selected end users software data

    function SaveList{

    } #Saves Selected list and end user to CSV

    function RefreshSoftList {
        #Fills up the check list box with all the software names ready to be selected.
        $WPFlstSoftwareAvailable.Items.Clear();
        $WPFlstSoftwareAssigned.Items.Clear();
        $Import = Import-Csv ".\Script_Reference\UpdateSoftwareList\AllSoftware.csv"  #Imports the SoftwarePaths from the currently opened directory.
        $Global:ArraySoft = @()
        $SoftFolderChange = 0

        #Takes the end of the directory from the CSV file an displays it in the CheckListBox
        if ($Import){
            foreach ($objDirectory in $Import){
                if (Test-Path $objDirectory.FullName){
                    $name = Select-String -path $objDirectory.FullName -pattern "REM Name:"
                    $name = $name -replace '.*Name:',""
                    if($name){
                        foreach ($entry in $name){
                            if ($entry){
                                [void] $WPFlstSoftwareAvailable.Items.Add($entry)
                                #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                $objSoftware = New-Object System.Object
                                $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                $Global:ArraySoft += $objSoftware
                            }# if ($entry)
                        } #Foreach
                    }
                    else{
                    $name = $objDirectory.FullName
                    $Global:ArraySoft += $name
                    [void] $WPFlstSoftwareAvailable.Items.Add($name)
                    #Creates A full name Custom Object and adds it to the $ArraySoft array.
                    $objSoftware = New-Object System.Object
                    $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                    $Global:ArraySoft += $objSoftware
                    }
                } #if Test-file path
                else{
                    $SoftFolderChange = ++$SoftFolderChange
                } #else  
            } #Foreach $objDirectory in $Import

            if ($SoftFolderChange -gt 0){
                $WPFtxtblkWarning.content = "Something in your software folder changed!`rPlease Update your CSV!"
                $WPFbtnUpdateSoftwareList.Foreground = "#FFFD0000"
            }# if for $SoftFolderChange
        }else{
            $WPFtxtblkWarning.content = "The CSV contaning the main list of software is missing!`rPlease Update your CSV!"
            $WPFbtnUpdateSoftwareList.Foreground = "#FFFD0000"
        }
    } #Refreshs the Software available list

    function AddSoft{
        $selectedsoftware = ""
        foreach ($selectedsoftware in $WPFlstSoftwareAvailable.selecteditems){
            $WPFlstSoftwareAssigned.Items.add($selectedsoftware)
        }
        foreach($AddedSoftware in $WPFlstSoftwareAssigned.items){
            $WPFlstSoftwareAvailable.Items.remove($AddedSoftware)
        }
    }#add software selected to install function

    function RemoveSoft {
        $selectedsoftware = ""
        foreach ($selectedsoftware in $WPFlstSoftwareAssigned.selecteditems){
            $WPFlstSoftwareAvailable.Items.add($selectedsoftware)
        }
        foreach ($RemovedSoftware in $WPFlstSoftwareAvailable.items){
            $WPFlstSoftwareAssigned.Items.remove($RemovedSoftware)
        }
    }#remove software selected to install function

    function softwareInstallation {
        
       if($lstSoftwareAssigned.hasitems){
            #if $txtComputerName.text has something that is the length of 7 then it is checked to see if it can be pinged.
            $ComputerName = $txtComputerName.text

            if ($txtComputerName.textlength){
                ipconfig /flushdns
                $TestConnect = Test-Connection -ComputerName $ComputerName -Count 1
                if ($TestConnect){
                    #Sets variables if computer name tests have passed.
                    $SoftwareName = $Global:ArraySoft.SoftwareName
                    $Selected = $WPFlstSoftwareAssigned.Items
                    $InstallationArray = @()
                    #Gets all Selected software and indexes them next to the software's directory.
                    foreach ($Install in $Selected){
                        $InstallIndex = (0..($SoftwareName.Count-1)) | where {$SoftwareName[$_] -eq $Install}
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -NotePropertyName SoftwareName -NotePropertyValue $Global:ArraySoft.SoftwareName[$InstallIndex]
                        $objSoftware | Add-Member -NotePropertyName FullName -NotePropertyValue $Global:ArraySoft.Fullname[$InstallIndex]
                        $InstallationArray += $objSoftware
                    }#Foreach Selected to index
                    #adds a null string for future indexing purposes
                    $nullSoft = New-Object System.Object
                    $nullSoft | Add-Member -NotePropertyName SoftwareName -NotePropertyValue "Installs_Complete!"
                    $InstallationArray += $nullSoft
                    #Adds all the sellected software to a CSV list for SoftwareInstallation.exe to analyse and install from.
                    $InstallationArray | Export-Csv -NoType -Path ".\Script_Reference\Software_Installing\$ComputerName.csv"  
                    Start-Process ".\Script_Reference\Software_Installing\SoftwareInstallation.exe" 
                }#Computer Name Test connection
                else{
                    $WPFtxtblkWarning.content = "$ComputerName is not connected to the network! `rComputer is either offline or not in the domain."
                }
            }
            else{
                $WPFtxtblkWarning.content = "Please add the computer name you wish to install software to."

            }
        }else{
            $WPFtxtblkWarning.content = "Please add software to the assigned list before installing."
        }
    }#Prepares CSV and kicks off install script

    #if script has started in the wrong location or if this is the first start-up
    #script will ask and require the path its location.
    #This first part searches for the settigns file and if found, sets the settings accordingly.
    if (Test-Path ".\Script_Reference\UPSD_Settings.csv" ){
            #sources the CSVSettings file
            $Global:SettingsSave = Import-Csv ".\Script_Reference\UPSD_Settings.csv"
            $CurrentLocation = $Global:SettingsSave.Runlocation
            Set-Location "$CurrentLocation" #Sets new location
            if ($Global:SettingsSave.ButtonName){
                $WPFbtnCustum.Content = $Global:SettingsSave.ButtonName
            }else{
                $WPFbtnCustum.Content = "Program Me"
            }
    }else{
        UPSDSettings
    }

    #will disable custom button unless a path is given.
    if ($Global:CustomButtonPath){
        $WPFbtnCustum.IsEnabled = "True"
    }

   # $WPFbtnAddRemoveSoft.Add_Click({Start-Process ".\Script_Reference\AddRemoveSoftware\AddRemoveSoftware.exe"})
   # $WPFbtnUpdateSoftwareList.add_Click({Start-Process ".\Script_Reference\SoftwareList\Update-CSVFile.exe"}) #updatest the CSV file
    $WPFbtnInstall.Add_Click({softwareInstallation}) #When the Install button is pressed it installs the selected software.
    $WPFbtnLoadLists.Add_Click({Loadlists})
    $WPFbtnSaveList.Add_Click({})
    $WPFbtnAddSoft.Add_Click({AddSoft})
    $WPFbtnRemoveSoft.Add_Click({RemoveSoft})
    $WPFbtnCustum.Add_Click({if ($Global:CustomButtonPath.ButtonPath){Start-Process "$Global:CustomButtonPath.ButtonPath"}})
    $WPFbtnSettings.Add_Click({UPSDSettings})
    $WPFbtnExit.Add_Click({$frmUPSD.Close()})  #Closes the form


    #===========================================================================
    # Shows the form
    #===========================================================================
    #write-host "To show the form, run the following" -ForegroundColor Cyan
    $frmUPSD.ShowDialog() | out-null
}
Startup