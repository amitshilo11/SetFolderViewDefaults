
# *** Change the value of '$Backup' to the path of an existing folder
# *** where you want to registry backups saved to.

$Backup = 'C:\DocHere\Folder View Defaults'

# Set '$LogicalViewMode' values to the desired style
# 1 = Details   2 = Tiles   3 = Icons
# 4 = List      5 = Content

$LogicalViewMode = 5

# If setting the default view to 'Icons', set '$IconSize' to an integer
# between 16 and 256
# 16 = Small Icons (0x10)   48  = Medium Icons (0x30)
# 96 = Large Icons (0x60)   100 = Extra Large Icons (0x100)

$IconSize = 96




# ----------------------------------------------------------------
# Paths for Powershell commands use the registry drives
# ----------------------------------------------------------------

$source = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes'
$dest   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes'
$TVs    = "$dest\*\TopViews\*"

# ----------------------------------------------------------------
# Paths for reg.exe
# ----------------------------------------------------------------

$bagMRU   = 'HKCR\Local Settings\Software\Microsoft\Windows\Shell\BagMRU'
$bags     = 'HKCR\Local Settings\Software\Microsoft\Windows\Shell\Bags'
$defaults = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Defaults'

# ----------------------------------------------------------------
# Backup & then delete saved views and 'Apply to folders' defaults
# ----------------------------------------------------------------

reg export $BagMru "$Backup\bagMRU.reg"
reg delete $bagMRU /f
reg export $Bags "$Backup\bags.reg"
reg delete $bags /f
If (test-path $defaults.Replace('HKCU', 'HKCU:')) {
   reg export $Defaults "$Backup\defaults.reg"
   reg delete $defaults /f
}
reg delete ($dest.Replace(':','')) /f

#-----------------------------------------------------------------
#------------------* The Magic is here *--------------------------
#-----------------------------------------------------------------

# Copy HKLM\...\FolderTypes to HKCU\...\FolderTypes

copy-item $source "$(split-path $dest)" -Recurse

get-childitem $TVs |
     %{$key2edit = (get-item $_.PSParentPath).OpenSubKey($_.PSChildName, $True);
       $key2edit.SetValue('LogicalViewMode', $LogicalViewMode)
       If ($LogicalViewMode -eq 3) {
          $Key2edit.SetValue('IconSize', $IconSize)
       } Elseif ($Key2Edit.GetValue('IconSize')) {
          $key2edit.DeleteValue('IconSize')
       }
       $key2edit.Close()
     }
Get-process explorer | Stop-Process
