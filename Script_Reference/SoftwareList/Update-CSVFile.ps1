#indexs all software based on the bath given in the settings csv.
if (Test-Path ".\Script_Reference\UPSD_Settings.csv"){
    $Global:SettingsSave = Import-Csv ".\Script_Reference\UPSD_Settings.csv"
    $CurrentLocation = $Global:SettingsSave.Runlocation
    Set-Location "$CurrentLocation" #Sets new location
    $SoftwarePath = $Global:SettingsSave.SoftwareFolder
    $SoftwareFile = $Global:SettingsSave.CommonSoftName + $Global:SettingsSave.SoftwareExtention
    if(test-path "$SoftwarePath"){
        $a = New-Object -comobject wscript.shell
        $intAnswer = $a.popup("Would you like to proceed? `nThis process can take up to 30 minutes. `nYou May continue using the script as the CSV rebuilds.", `
        0,"Proceed?",4)

        if ($intAnswer -eq 6) {
            #ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Name="frmUpdatingSoftwareList" x:Class="PleasewaitSoftwarelistUpdate.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PleasewaitSoftwarelistUpdate"
        mc:Ignorable="d"
        Title="Please Wait..." Height="163" Width="271" Background="#FF4F4F4F">
    <Grid>
        <Button x:Name="btnCancel" Content="Cancel" Margin="88,95,88,0" VerticalAlignment="Top" Background="#FF2B2B2B" Foreground="White" Height="22" HorizontalAlignment="Center" Width="87"/>
        <TextBlock x:Name="txtblkRebuildingSoft" HorizontalAlignment="Left" Margin="10,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="69" Width="243" Foreground="White" FontWeight="Bold" FontFamily="Lucida Bright" FontSize="24" TextAlignment="Center" Text="Rebuilding the software list!"/>

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

            $WPFbtnInstall.Add_Click({$frmUpdatingSoftwareList.close()})

            #Copies CSV to a temporary backup folder
            md ".\Script_Reference\SoftwareList\BuildingCSV_temp"

            #Rebuids CSV File and displays progress in text box 
            Get-ChildItem -Path "$SoftwarePath" -Recurse|
            Where-Object { !$PsIsContainer -and [System.IO.Path]::GetFileName($_.Name) -eq "$SoftwareFile" } |
            Export-Csv ".\Script_Reference\SoftwareList\BuildingCSV_temp\Temp_AllSoftware.csv" -force

            $Temp = Import-Csv ".\Script_Reference\SoftwareList\BuildingCSV_temp\Temp_AllSoftware.csv"
            $AllSoft = @()
            foreach($Software in $Temp) {
                if (Test-Path $Software.FullName){
                    $name = Select-String -path $Software.FullName -pattern "REM Name:"
                    $name = $name -replace '.*Name:',""
                    if($name){
                        foreach ($entry in $name){
                            if ($entry){
                                #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                $objSoftware = New-Object System.Object
                                $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Software.FullName
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareRegistry -Value $RegName
                                $AllSoft += $objSoftware
                            }# if ($entry)
                        } #Foreach
                    }
                    else{
                    $name = $Software.FullName
                    $AllSoft += $name
                    #Creates A full name Custom Object and adds it to the $ArraySoft array.
                    $objSoftware = New-Object System.Object
                    $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Software.FullName
                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareRegistry -Value $RegName
                    $AllSoft += $objSoftware
                    }
                } #if Test-file path
            }#Foreach $Software in $Temp

            #Exports the Allsoft array into a CSV
            $AllSoft | Export-Csv -NoType -Path ".\Script_Reference\SoftwareList\BuildingCSV_temp\AllSoftware.csv"
            Remove-Item ".\Script_Reference\SoftwareList\BuildingCSV_temp\Temp_AllSoftware.csv"

            $TempAdd = Import-Csv ".\Script_Reference\AddedSoftware.csv"
            $AddedSoft = @()
            foreach($Software in $TempAdd) {
                if (Test-Path $Software.FullName){
                    $name = Select-String -path $Software.FullName -pattern "REM Name:"
                    $name = $name -replace '.*Name:',""
                    if($name){
                        foreach ($entry in $name){
                            if ($entry){
                                #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                $objSoftware = New-Object System.Object
                                $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Software.FullName
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareRegistry -Value $RegName
                                $AddedSoft += $objSoftware
                            }# if ($entry)
                        } #Foreach
                    }
                    else{
                    $name = $Software.FullName
                    $AllSoft += $name
                    #Creates A full name Custom Object and adds it to the $ArraySoft array.
                    $objSoftware = New-Object System.Object
                    $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Software.FullName
                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareRegistry -Value $RegName
                    $AddedSoft += $objSoftware
                    }
                } #if Test-file path
            }#Foreach TempAdd

            $AddedSoft | Export-Csv -NoType -Append -Path ".\Script_Reference\SoftwareList\BuildingCSV_temp\AllSoftware.csv"
            $frmPleaseWait.Close() #Closes form when command finished
        
            #checks if rebuild was successfull.
            if ((Get-Item ".\Script_Reference\SoftwareList\BuildingCSV_temp\AllSoftware.csv").length -gt 1kb){
                $a.popup("CSV has been rebuilt! `nA manual refresh is required to see the results.",0,"Success!")
                Remove-Item ".\Script_Reference\SoftwareList\AllSoftware.csv"
                Copy-Item -Path ".\Script_Reference\SoftwareList\BuildingCSV_temp\AllSoftware.csv" -Destination ".\Script_Reference\SoftwareList" -Force
                Remove-Item ".\Script_Reference\SoftwareList\BuildingCSV_temp" -Recurse
            }#Tests to make sure CSV copied over.
            else{
                $a.popup("CSV rebuild has failled!",0,"Failure!")
                $intAnswer = $c.popup("CSV rebuild has failled! `nWould you like to try to rebuild the CSV again?", `
                0,"Failure!",4)
                if ($intAnswer -eq 6) {
                    Update-CSVFile
                }#if for update-CSVFile
                Else{
                    Remove-Item ".\Script_Reference\SoftwareList\BuildingCSV_temp" -Recurse
                }
            }#If then for Get-item
        } #if statmeant
        #===========================================================================
        # Shows the form
        #===========================================================================
        #write-host "To show the form, run the following" -ForegroundColor Cyan
        $frmUPSD.ShowDialog() | out-null
        }else{
            $a = New-Object -comobject wscript.shell
            $intAnswer = $a.popup("Please make sure the proper`rsoftware path in the settings`rais set correctly.",0,"Error!")
        }#If softwarefiles arn't set
    }else{
        $a = New-Object -comobject wscript.shell
        $intAnswer = $a.popup("Please restart the main window to ensure `rthat the script is running in the correct location.",0,"Error!")
    }#if settings file exists