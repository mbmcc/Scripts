Function Copy-WithStatus
# Matthew McCourry github.com/mbmcc
<#


#>
{

 [CmdletBinding()]

 Param (

    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        $Source,
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        $Destination
  )

$Source=$Source.ToLower()
Write-Output "Caching Files"
$Filelist= Get-Childitem –Recurse $Source 
$TotalRecords=$Filelist.Count

$LoopRecord=1
    foreach ($File in $Filelist) {
        $RecordPercent= (($LoopRecord/$TotalRecords)*100).ToString("#")
        $FileName=$File.FullName.Replace((Resolve-Path $Source), "")
        $DestinationFile=($Destination+'\'+$FileName)
        Write-Progress -Activity "Copying data from $Source to $Destination `t File: $LoopRecord of $TotalRecords `t $RecordPercent% Complete" -Status "Copying File $File" -PercentComplete ($RecordPercent)
        Copy-Item -Verbose $File.FullName -Destination $DestinationFile
        $LoopRecord++
    }

}