if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
$workDir = "C:\FIMConfig\"
$schema_filename = $workDir + "FIM-Dev-Schema.xml"
Write-Host "Exporting configuration objects from pilot."
# Please note that SynchronizationFilter Resources inform the FIM MA.
$schema = Export-FIMConfig -schemaConfig -customConfig "/SynchronizationFilter"
if ($schema -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to Export-FIMConfig are correct."
}
else
{
    Write-Host "Exported " $schema.Count " objects from pilot."
    $schema | ConvertFrom-FIMResource -file $schema_filename
    Write-Host "Pilot file is saved as " $schema_filename "."
    if($schema.Count -gt 0)
    {
        Write-Host "Export complete.  The next step is to run FIM-Dev-ExportPolicy.ps1."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct." 
     }
}