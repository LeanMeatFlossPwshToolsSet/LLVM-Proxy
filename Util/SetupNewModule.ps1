param(
    [Parameter(ValueFromPipeline,Mandatory)]
    [string]
    $ModuleName
)
$initLocation=Get-Location
Set-Location "$PSScriptRoot/../"
$gitUrl=(git remote get-url --all origin)
Write-Host "Current git url is $gitUrl"
$gitRepoName=($gitUrl.replace(".git","") -split "/")[-1]
Write-Host "Current git repo name is $gitRepoName"
$moduleBaseName=$gitRepoName.Replace("-","")
Write-Host "Current module base name $moduleBaseName"
$gitHostName=($gitUrl.replace(".git","") -split "/")[-2]
New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName" -ItemType Directory -Force
New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/$moduleBaseName-$ModuleName.Tests.ps1" -ItemType File -Force -Value @'
BeforeAll{
    $currentTestModuleName=([System.IO.FileInfo]$PSCommandPath).Name.Replace(".Tests.ps1","")
    $env:PSModulePath=(Resolve-Path "$PSScriptRoot/..").Path+[IO.Path]::PathSeparator+$env:PSModulePath
    $moduleManifestFile=Import-PowerShellDataFile  "$PSScriptRoot/$currentTestModuleName.psd1"
    # install dependency modules
    $moduleManifestFile.RequiredModules|Foreach-Object{
        if(-not (Get-Module $_)){
             # install them
             Install-Module $_ -Force
             Update-Module $_
        }
    }
    Import-Module $currentTestModuleName -Force
}
'@
New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/Module" -ItemType Directory -Force
New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/Module/$moduleBaseName-$ModuleName.psm1" -ItemType File -Force
# New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/Script" -ItemType Directory -Force
# New-Item -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/Script/$moduleBaseName-$ModuleName.Classes.ps1" -ItemType File -Force
New-ModuleManifest -Description "$moduleBaseName"  -Path "./$moduleBaseName/$moduleBaseName-$ModuleName/$moduleBaseName-$ModuleName.psd1" -Author "LeanMeatFloss" -CompanyName "Song" -Copyright @"
MIT License

Copyright (c) 2022 Hansong Li

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
