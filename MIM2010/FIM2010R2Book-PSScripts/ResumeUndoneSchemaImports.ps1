$prodWorkDir = "C:\FIMConfig\"
$undone_filename = $prodWorkDir+"SchemaUndone.xml"
$undoneImports = ConvertTo-FIMResource -file $undone_filename
if($undoneImports -eq $null)
  {
    throw (new-object NullReferenceException -ArgumentList "Changes is null.  Check that the undone file has data.")
  }
Write-Host "Resuming import"
$newUndoneImports = $undoneImports | Import-FIMConfig

if($newUndoneImports -eq $null)
  {
    Write-Host "Import complete."
  }
else
  {
    Write-Host
    Write-Host "There were " $newUndoneImports.Count " uncompleted imports."
    $newUndoneImports | ConvertFrom-FIMResource -file $undone_filename
    Write-Host
    Write-Host "Please see the documentation on how to resolve the issues."
  }