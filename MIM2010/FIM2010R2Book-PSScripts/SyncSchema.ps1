$prodWorkDir = "C:\FIMConfig\"
$devWorkDir = "\\fim-dev\fimconfig\"
$pilot_filename = $devWorkDir+"FIM-Dev-Schema.xml"
$production_filename = $prodWorkDir+"FIM-Prod-Schema.xml"
$changes_filename = $prodWorkDir+"SchemaChanges.xml"
$joinrules = @{
    # === Schema configuration ===
    # This is based on the system names of attributes and objects
    # Notice that BindingDescription is joined using its reference attributes.
    ObjectTypeDescription = "Name";
    AttributeTypeDescription = "Name";
    BindingDescription = "BoundObjectType BoundAttributeType";
}
if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

Write-Host "Loading production file " $production_filename "."
$production = ConvertTo-FIMResource -file $production_filename
if($production -eq $null)
{
    throw (new-object NullReferenceException -ArgumentList "Production Schema is null.  Check that the production file has data.")
}
Write-Host "Loaded file " $production_filename "." $production.Count " objects loaded."

Write-Host "Loading pilot file " $pilot_filename "."
$pilot = ConvertTo-FIMResource -file $pilot_filename
if($pilot -eq $null)
{
    throw (new-object NullReferenceException -ArgumentList "Pilot Schema is null.  Check that the pilot file has data.")
}

Write-Host "Loaded file " $pilot_filename "." $pilot.Count " objects loaded."
Write-Host
Write-Host "Executing join between pilot and production."
Write-Host 
$matches = Join-FIMConfig -source $pilot -target $production -join $joinrules -defaultJoin DisplayName
if($matches -eq $null)
{
    throw (new-object NullReferenceException -ArgumentList "Matches is null.  Check that the join succeeded and join criteria is correct for your environment.")
}
Write-Host "Executing compare between matched objects in pilot and production."
$changes = $matches | Compare-FIMConfig
if($changes -eq $null)
{
    throw (new-object NullReferenceException -ArgumentList "Changes is null.  Check that no errors occurred while generating changes.")
}
Write-Host "Identified " $changes.Count " changes to apply to production."
Write-Host "Saving changes to " $changes_filename "."
$changes | ConvertFrom-FIMResource -file $changes_filename
Write-Host
Write-Host "Sync complete. The next step is to commit the changes using CommitSchemaChanges.ps1."