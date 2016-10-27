if (Test-Path ".\Script_Reference\UPSD_Settings.csv"){
    $Global:SettingsSave = Import-Csv ".\Script_Reference\UPSD_Settings.csv"
    $CurrentLocation = $Global:SettingsSave.Runlocation
    Set-Location "$CurrentLocation" #Sets new location
    $SoftwarePath = $Global:SettingsSave.SoftwareFolder

    if(test-path "$SoftwarePath"){

#ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Name="frmAddRemoveSoftware" x:Class="frmAddRemoveSoftware.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:frmAddRemoveSoftware"
        mc:Ignorable="d"
        Title="Add and Remove Software" Height="510" Width="610" Background="#FF4F4F4F">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnViewAdded" Content="Added List" HorizontalAlignment="Left" Margin="10,112,0,0" VerticalAlignment="Top" Width="96" Height="40" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" ScrollViewer.VerticalScrollBarVisibility="Disabled" UseLayoutRounding="False" ScrollViewer.HorizontalScrollBarVisibility="Hidden" FontFamily="Lucida Bright" TabIndex="3"/>
        <Button x:Name="btnViewRemoved" Content="Removed List" HorizontalAlignment="Left" Margin="10,157,0,0" VerticalAlignment="Top" Width="96" Height="40" FontFamily="Lucida Bright" TabIndex="4"/>
        <Button x:Name="btnViewCurrentSoft" Content="Current List" HorizontalAlignment="Left" Margin="10,202,0,0" VerticalAlignment="Top" Width="96" Height="40" FontFamily="Lucida Bright" TabIndex="5"/>
        <TextBox x:Name="txtFullName" HorizontalAlignment="Left" Height="23" Margin="214,12,0,0" VerticalAlignment="Top" Width="307" FontFamily="Lucida Bright" VerticalScrollBarVisibility="Disabled" TabIndex="0"/>
        <TextBox x:Name="txtSoftwareName" HorizontalAlignment="Left" Height="23" Margin="214,40,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="307" FontFamily="Lucida Bright" TabIndex="1"/>
        <TextBox x:Name="txtUninstalRegPath" HorizontalAlignment="Left" Height="23" Margin="214,68,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="307" FontFamily="Lucida Bright" TabIndex="2"/>
        <Label x:Name="lblFullName" Content="Full File Path:" HorizontalAlignment="Left" Margin="113,9,0,0" VerticalAlignment="Top" Foreground="White" FontFamily="Lucida Bright" FontSize="14"/>
        <Label x:Name="lblSoftName" Content="Software Name:" HorizontalAlignment="Left" Margin="98,37,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="14" Foreground="White"/>
        <Label x:Name="lblUninstallPath" Content="Uninstall Reg Path:" HorizontalAlignment="Left" Margin="76,65,0,0" VerticalAlignment="Top" FontFamily="Lucida Bright" FontSize="14" Foreground="White"/>
        <Button x:Name="btnAdd" Content="Add" HorizontalAlignment="Left" Margin="10,271,0,0" VerticalAlignment="Top" Width="96" Height="40" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" ScrollViewer.VerticalScrollBarVisibility="Disabled" UseLayoutRounding="False" ScrollViewer.HorizontalScrollBarVisibility="Hidden" FontFamily="Lucida Bright" TabIndex="6"/>
        <Button x:Name="btnRemove" Content="Remove" HorizontalAlignment="Left" Margin="10,316,0,0" VerticalAlignment="Top" Width="96" Height="40" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" ScrollViewer.VerticalScrollBarVisibility="Disabled" UseLayoutRounding="False" ScrollViewer.HorizontalScrollBarVisibility="Hidden" FontFamily="Lucida Bright" TabIndex="7"/>
        <Button x:Name="btnExit" Content="Exit" HorizontalAlignment="Left" Margin="10,393,0,0" VerticalAlignment="Top" Width="96" Height="40" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" ScrollViewer.VerticalScrollBarVisibility="Disabled" UseLayoutRounding="False" ScrollViewer.HorizontalScrollBarVisibility="Hidden" FontFamily="Lucida Bright" TabIndex="8"/>
        <ListBox x:Name="lstSoftware" HorizontalAlignment="Left" Height="356" Margin="113,100,0,0" VerticalAlignment="Top" Width="471" Background="#FF8B8B8B" Foreground="White" BorderBrush="Black"/>
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

        function ViewAllSoftware{
            $Global:ImportAllSoft = @()
            $Global:ImportAllSoft = Import-Csv ".\Script_Reference\AddRemoveSoftware\AllSoftware.csv"
            $Global:ArraySoft = @()
            $WPFlstSoftware.Unselectall()
            $WPFbtnAdd.IsEnabled = $true
            $WPFlblFullName.IsEnabled = $true
            $WPFtxtFullName.IsEnabled = $true
            $WPFlblSoftName.IsEnabled = $true
            $WPFtxtSoftwareName.IsEnabled = $true
            $WPFlblUninstallPath.IsEnabled = $true
            $WPFtxtUninstalRegPath.IsEnabled = $true
            $WPFbtnViewCurrentSoft.FontWeight="Bold"
            $WPFbtnViewAdded.FontWeight="Normal"
            $WPFbtnViewRemoved.FontWeight="Normal"

            foreach ($objDirectory in $Global:ImportAllSoft){
                    if (Test-Path $objDirectory.FullName){
                        $name = Select-String -path $objDirectory.FullName -pattern "REM Name:"
                        $name = $name -replace '.*Name:',""
                        if($name){
                            foreach ($entry in $name){
                                if ($entry){
                                    [void] $WPFlstSoftware.Items.Add($entry)
                                    #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                    $objSoftware = New-Object System.Object
                                    $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                                    $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                    $Global:ArraySoft += $objSoftware
                                }# if ($entry)
                            } #Foreach
                        }
                        else{
                        $name = $objDirectory.FullName
                        [void] $WPFlstSoftware.Items.Add($name)
                        #Creates A full name Custom Object and adds it to the $ArraySoft array.
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                        $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                        $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                        $Global:ArraySoft += $objSoftware
                        }
                    } #if Test-file path
                } #Foreach $objDirectory in $Import
        } #ViewAllSoftware function

        function ViewAdded {
            $Global:ImportAddedSoft = @()
            $Global:ImportAddedSoft = Import-Csv ".\Script_Reference\AddRemoveSoftware\AddedSoftware.csv"
            $Global:ArraySoft = @()
            $WPFlstSoftware.Unselect()
            $WPFbtnAdd.IsEnabled = $true
            $WPFtxtFullName.IsEnabled = $true
            $WPFtxtFullName.IsEnabled = $true
            $WPFlblSoftName.IsEnabled = $true
            $WPFtxtSoftwareName.IsEnabled = $true
            $WPFlblUninstallPath.IsEnabled = $true
            $WPFtxtUninstalRegPath.IsEnabled = $true
            $WPFbtnViewCurrentSoft.FontWeight="Normal"
            $WPFbtnViewAdded.FontWeight="Bold"
            $WPFbtnViewRemoved.FontWeight="Normal"

            foreach ($objDirectory in $Global:ImportAddedSoft){
                if (Test-Path $objDirectory.FullName){
                    $name = Select-String -path $objDirectory.FullName -pattern "REM Name:"
                    $name = $name -replace '.*Name:',""
                    if($name){
                        foreach ($entry in $name){
                            if ($entry){
                                [void] $WPFlstSoftware.Items.Add($entry)
                                #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                $objSoftware = New-Object System.Object
                                $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                                $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                                $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                $Global:ArraySoft += $objSoftware
                            }# if ($entry)
                        } #Foreach
                    }
                    else{
                        $name = $objDirectory.FullName
                        [void] $WPFlstSoftware.Items.Add($name)
                        #Creates A full name Custom Object and adds it to the $ArraySoft array.
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                        $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                        $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                        $Global:ArraySoft += $objSoftware
                    }
                } #if Test-file path
            } #Foreach $objDirectory in $Import
            If($Global:ImportAddedSoft.count -le "1"){
            $objSoftware = New-Object System.Object
            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value "Null!"
            $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value "Null!"
            $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value "Null!"
            $Global:ArraySoft += $objSoftware
            }
        } #ViewAdded function


        function ViewRemoved {
            $Global:ImportRemovedSoft = @()
            $Global:ImportRemovedSoft = Import-Csv ".\Script_Reference\AddRemoveSoftware\RemovedSoftware.csv"
            $Global:ArraySoft = @()
            $WPFbtnAdd.IsEnabled = $false
            $WPFtxtFullName.IsEnabled = $false
            $WPFtxtFullName.IsEnabled = $false
            $WPFlblSoftName.IsEnabled = $false
            $WPFtxtSoftwareName.IsEnabled = $false
            $WPFlblUninstallPath.IsEnabled = $false
            $WPFtxtUninstalRegPath.IsEnabled = $false
            $WPFlstSoftware.UnselectAll()
            $WPFbtnViewCurrentSoft.FontWeight="Normal"
            $WPFbtnViewAdded.FontWeight="Normal"
            $WPFbtnViewRemoved.FontWeight="Bold"

            foreach ($objDirectory in $Global:ImportRemovedSoft){
                    if (Test-Path $objDirectory.FullName){
                        $name = Select-String -path $objDirectory.FullName -pattern "REM Name:"
                        $name = $name -replace '.*Name:',""
                        if($name){
                            foreach ($entry in $name){
                                if ($entry){
                                    [void] $WPFlstSoftware.Items.Add($entry)
                                    #Creates A full name Custom Object and adds it to the $ArraySoft array.
                                    $objSoftware = New-Object System.Object
                                    $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                                    $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                                    $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $entry
                                    $Global:ArraySoft += $objSoftware
                                }# if ($entry)
                            } #Foreach
                        }
                        else{
                        $name = $objDirectory.FullName
                        [void] $WPFlstSoftware.Items.Add($name)
                        #Creates A full name Custom Object and adds it to the $ArraySoft array.
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $objDirectory.FullName
                        $objSoftware | Add-Member -type NoteProperty -Name UninstallPath -Value $WPFlblUninstallPath
                        $objSoftware | Add-Member -type NoteProperty -Name SoftwareName -Value $name
                        $Global:ArraySoft += $objSoftware
                        }
                    } #if Test-file path
                } #Foreach $objDirectory in $Import

        } #ViewRemoved function

        function AddSoftware {
            #Sets variables if computer name tests have passed.
            $a = New-Object -comobject wscript.shell
            $SoftwareName = $Global:ArraySoft.SoftwareName
            $AddFilePath = $txtFilePath.Text
            $IfCompareTrue = 0
            $AddFileArray = @()

            if ($AddFilePath -eq ""){
                $a.popup("Cannot add nothing!",0,"NULL ERROR!")
            }#if checked is null
            else{
                if (Test-Path "$AddFilePath"){
                    $ImportPath = Get-ChildItem $AddFilePath.Name
                    if ($AddFilePath -like "*.bat"){
                        $SoftCompare = Compare-Object $AddFilePath $Global:ImportAllSoft.FullName -IncludeEqual

                        foreach($Compared in $SoftCompare) {
                            if ($Compared.SideIndicator -eq "=="){
                                $IfCompareTrue = $IfCompareTrue + 1
                            }#If compare
                        }
                        $SoftCompare = ""
                        $SoftCompare = Compare-Object $AddFilePath $Global:ImportRemovedSoft.FullName -IncludeEqual
                        foreach($Compared in $SoftCompare) {
                            if ($Compared.SideIndicator -eq "=="){
                                $IfCompareTrue = $IfCompareTrue + 1
                            }#If compare
                        }#foreach compare
                        if ($IfCompareTrue -eq 0){
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $txtFilePath.Text
                            $AddFileArray += $objSoftware
                
                            $AddFileArray | Export-Csv -NoType -Append -Path ".\Script_Reference\AddRemoveSoftware\AllSoftware.csv" -force
                            $AddFileArray | Export-Csv -NoType -Append -Path ".\Script_Reference\AddRemoveSoftware\AddedSoftware.csv" -force
                            $txtFilePath.Text = ""

                            if($WPFbtnViewAdded.FontWeight -eq "Bold"){
                                ViewAdded
                            }
                            else{
                                ViewAllSoftware
                            }#if button is selected
                        }#if compare is true
                        else{
                            $a.popup("This software already exists somewhere in these lists",0,"Exists!")
                        }
                    }#if the file contains
                    Else{
                        $a.popup("Path needs to contain a .bat file `nPlease enter a valid file Path",0,"Bat File Required!")
                    }
                }#if the file exists
                Else{
                    $a.popup("Path does not exist! `nPlease enter a valid file Path",0,"Does not exist!")
                }
            }#if file path text box is empty
        } #AddSoftware function

        function RemoveSoftware {
            #Sets variables if computer name tests have passed.
            $a = New-Object -comobject wscript.shell
            $SoftwareName = $Global:ArraySoft.SoftwareName
            $Checked = $WPFlstSoftware.SelectedItems
            $RemoveCheckedArray = @()
            $KeepSoft = @()
            $ReAddRemovedSoft = @()
            $RemovedSoft = @()
    

            if ($Checked -eq $null){
                $a.popup("Cannot remove nothing!",0,"NULL ERROR!")
            }#if checked is null
            else{
                If($WPFbtnViewRemoved.FontWeight -eq "Bold"){
                    #Gets all checked software and indexes them next to the software's directory.
                    foreach ($Remove in $Checked){
                        $RemoveIndex = (0..($SoftwareName.Count-1)) | where {$SoftwareName[$_] -eq $Remove}
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -NotePropertyName FullName -NotePropertyValue $Global:ArraySoft.Fullname[$RemoveIndex]
                        $RemoveCheckedArray += $objSoftware
                    }#Foreach Checked to index

                    #Compares the Removed software list with the selected software 
                    $SoftCompare = Compare-Object $RemoveCheckedArray.FullName $Global:ImportRemovedSoft.FullName -IncludeEqual
           
                    foreach($Compared in $SoftCompare) {
                        if ($Compared.SideIndicator -ne "=="){
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $KeepSoft += $objSoftware
                        }
                        else{
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $ReAddRemovedSoft += $objSoftware
                        }
                    }
                    #Updates CSV's with the latest changes
                    $ReAddRemovedSoft | Export-Csv -NoType -Append -Path ".\Script_Reference\AddRemoveSoftware\AllSoftware.csv" -force
                    $KeepSoft | Export-Csv -NoType -Path ".\Script_Reference\AddRemoveSoftware\RemovedSoftware.csv" -force
                    ViewRemoved
                }#If WPFbtnViewRemoved.FontWeight -eq "Bold"
                elseif($WPFbtnViewCurrentSoft.FontWeight -eq "Bold"){
                    #Gets all checked software and indexes them next to the software's directory.
                    foreach ($Remove in $Checked){
                        $RemoveIndex = (0..($SoftwareName.Count-1)) | where {$SoftwareName[$_] -eq $Remove}
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -NotePropertyName FullName -NotePropertyValue $Global:ArraySoft.Fullname[$RemoveIndex]
                        $RemoveCheckedArray += $objSoftware
                    }#Foreach Checked to index

                    #Compares the Removed software list with the selected software 
                    $SoftCompare = Compare-Object $Global:ImportAllSoft.FullName $RemoveCheckedArray.FullName -IncludeEqual

                     foreach($Compared in $SoftCompare) {
                        if ($Compared.SideIndicator -ne "=="){
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $KeepSoft += $objSoftware
                        }
                        else{
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $RemovedSoft += $objSoftware
                        }
                    }
                    #Updates CSV's with the latest changes
                    $RemovedSoft | Export-Csv -NoType -Append -Path ".\Script_Reference\AddRemoveSoftware\RemovedSoftware.csv" -force
                    $KeepSoft | Export-Csv -NoType -Path ".\Script_Reference\AddRemoveSoftware\AllSoftware.csv" -force
                    ViewAllSoftware
                }#Elseif WPFbtnViewCurrentSoft.FontWeight="Bold"
                elseif($WPFbtnViewAdded.FontWeight -eq "Bold"){
                    #Gets all checked software and indexes them next to the software's directory.
                    foreach ($Remove in $Checked){
                        $RemoveIndex = (0..($SoftwareName.Count-1)) | where {$SoftwareName[$_] -eq $Remove}
                        $objSoftware = New-Object System.Object
                        $objSoftware | Add-Member -NotePropertyName FullName -NotePropertyValue $Global:ArraySoft.Fullname[$RemoveIndex]
                        $RemoveCheckedArray += $objSoftware
                    }#Foreach Checked to index

                    #Compares the Removed software list with the selected software 
                    $SoftCompare = Compare-Object $Global:ImportAddedSoft.FullName $RemoveCheckedArray.FullName -IncludeEqual

                     foreach($Compared in $SoftCompare) {
                        if ($Compared.SideIndicator -ne "=="){
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $KeepSoft += $objSoftware
                        }
                        else{
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $RemovedSoft += $objSoftware
                        }
                    }
                    #Updates CSV's with the latest changes
                    $KeepSoft | Export-Csv -NoType -Path ".\Script_Reference\AddRemoveSoftware\AddedSoftware.csv" -force

                    #Clears out variable for a second use
                    $KeepSoft = @()
                    $RemovedSoft = @()
                    $SoftCompare = ""

                    $SoftCompare = Compare-Object $Global:ImportAllSoft.FullName $RemoveCheckedArray.FullName -IncludeEqual

                    foreach($Compared in $SoftCompare) {
                        if ($Compared.SideIndicator -ne "=="){
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $KeepSoft += $objSoftware
                        }
                        else{
                            $objSoftware = New-Object System.Object
                            $objSoftware | Add-Member -type NoteProperty -Name FullName -Value $Compared.InputObject
                            $RemovedSoft += $objSoftware
                        }
                    }
                    #Updates CSV's with the latest changes
                    $KeepSoft | Export-Csv -NoType -Path ".\Script_Reference\AddRemoveSoftware\AllSoftware.csv" -force
                    ViewAdded
                }#Elseif WPFbtnViewAdded.FontWeight -eq "Bold"
            }#Else checked is not null
        } #RemoveSoftware function

        ViewAllSoftware
        $WPFbtnViewAdded.add_Click({ViewAdded})
        $WPFbtnViewRemoved.add_Click({ViewRemoved})
        $WPFbtnViewCurrentSoft.add_Click({ViewAllSoftware})
        $WPFbtnAdd.add_Click({AddSoftware})
        $WPFbtnRemove.add_Click({RemoveSoftware})
        $WPFbtnExit.add_Click({$frmUPSD.close()})

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