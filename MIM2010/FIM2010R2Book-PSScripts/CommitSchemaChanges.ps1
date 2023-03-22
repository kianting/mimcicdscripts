$prodWorkDir = "C:\FIMConfig\"
$changes_filename = $prodWorkDir+"SchemaChanges.xml"
$undone_filename = $prodWorkDir+"SchemaUndone.xml"

$imports = ConvertTo-FIMResource -file $changes_filename
if($imports -eq $null)
  {
    throw (new-object NullReferenceException -ArgumentList "Changes is null.  Check that the changes file has data.")
  }
Write-Host "Importing changes into production."
$undoneImports = $imports | Import-FIMConfig
if($undoneImports -eq $null)
  {
    Write-Host "Import complete."
  }
else
  {
    Write-Host
    Write-Host "There were " $undoneImports.Count " uncompleted imports."
    $undoneImports | ConvertFrom-FIMResource -file $undone_filename
    Write-Host
    Write-Host "Please see the documentation on how to resolve the issues."
  }