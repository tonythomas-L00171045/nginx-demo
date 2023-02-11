$currentPath = Get-Location | Select-Object -ExpandProperty Path;
$solutionPath = (Get-Item $currentPath).parent.parent.FullName;

$tempDirectory = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())

Write-Host ("Creating temporary folder: " + $tempDirectory) -ForegroundColor Green
[System.IO.Directory]::CreateDirectory($tempDirectory);

try
{
    $folders = @("ShowProcessId/ShowProcessId"
                );
    
    foreach ($folder in $folders)
    {
        $repoPath = $solutionPath  + "\" + $folder;
        $destPath = $tempDirectory  + "\" + $folder;

        Write-Host ('Copy ' + $repoPath + ' to ' + $destPath)
        Copy-Item $repoPath -Destination $destPath -Recurse 
    }

    $dockerFilePath = $currentPath + "\ShowProcessId.Dockerfile";
    Write-Host ('Copy ' + $dockerFilePath + ' to ' + ($tempDirectory + "/Dockerfile"))
    Copy-Item $dockerFilePath -Destination ($tempDirectory + "/Dockerfile")

    Write-Host ('Building docker image') -ForegroundColor Green
    Invoke-Expression ("docker build -t showprocess:v1 --force-rm " + $tempDirectory)
    Invoke-Expression ('docker rmi $(docker images -f "dangling=true" -q)')
}

finally
{
    Write-Host ("Deleting temporary folder: " + $tempDirectory) -ForegroundColor Green
    Remove-Item -Recurse -Force $tempDirectory;
}