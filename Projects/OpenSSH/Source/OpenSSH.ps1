##Initialize######
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[String]$ScriptDirectory = split-path $myinvocation.mycommand.path
#$ScriptDirectory =(get-location).path
function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$ScriptDirectory\Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

$Get_Status=$Form.FindName("Get_Status")
$Quit=$Form.FindName("Quit")
$Install=$Form.FindName("Install")
$Status_Client= $form.FindName("Status_Client")
$Status_Server= $form.FindName("Status_Server")
$Install_C = $Form.FindName("Install_C")
$Install_S = $Form.FindName("Install_S")

function Init {

    $Info_Client = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    $Info_Server = Get-WindowsCapability -Online |  Where-Object Name -like 'OpenSSH.Server*'
       $Global:InfoC = $Info_Client.State 
       $Global:InfoS = $Info_Server.State 
       $Global:InfoCP = $Info_Client.Name 
       $Global:InfoSP = $Info_Server.Name 
       $Install_C.IsChecked = $Install_S.IsChecked = $false
       
    }
   
 
$Install.add_Click({

      

                if ($Install_C.IsChecked -eq 'True') 
                    {
                    Add-WindowsCapability -Online -Name $Global:InfoCP | Out-Null   
                    
                    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Success :-)", "The OpenSSH Client is Installed")
                    }

                if ($Install_S.IsChecked -eq 'True')
                    {
                    Add-WindowsCapability -Online -Name $Global:InfoSP | Out-Null
                    
                    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Success :-)", "The OpenSSH Server is Installed")
                    }

                if ($Install_C.IsChecked -eq 'True' -and $Install_S.IsChecked -eq 'True')
                {
                    Add-WindowsCapability -Online -Name $Global:InfoSP | Out-Null
                    Add-WindowsCapability -Online -Name $Global:InfoCP | Out-Null  
                    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Success :-)", "The OpenSSH Server and Client are Installed")
                }
            
    Init

})        
    
$Get_Status.add_Click({
                
    Init
    

    if ($Global:InfoC -eq 'NotPresent'  )
       {
        $Status_Client.Content = "Not Present"
        $Status_Client.Foreground = "Red"	
        $Status_Client.Fontweight = "Bold"
        $Install_C.IsEnabled = $true
       
    	}
    
        else 
         {
        $Status_Client.Content = "Installed"
        $Status_Client.Foreground = "Green"	
        $Status_Client.Fontweight = "Bold"	
        $Install_C.IsEnabled  = $false
       

         }
    
    if ($Global:InfoS -eq 'NotPresent'  )
    {
        $Status_Server.Content = "Not Present"
        $Status_Server.Foreground = "Red"	
        $Status_Server.Fontweight = "Bold"
        $Install_S.IsEnabled = $true
        
    }
    else
    {
        $Status_Server.Content = "Installed"
        $Status_Server.Foreground = "Green"	
        $Status_Server.Fontweight = "Bold"	
        $Install_S.IsEnabled = $false
    }    

    })
    
    
$Quit.add_Click({
  
    
    $form.Close()

})


$Form.ShowDialog() | Out-Null

