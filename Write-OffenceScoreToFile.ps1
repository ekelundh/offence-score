#Requires -Version 7.0

using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Text

[CmdletBinding()]
param (
    [Parameter()]
    [string] $HighRiskPhrasesFilePath,

    [Parameter()]
    [string] $LowRiskPhrasesFilePath,

    [Parameter(ParameterSetName = 'ListOfFiles')]
    [string[]] $FilePath,

    [Parameter(ParameterSetName = 'AllInDirectory')]
    [string] $DirectoryPath,

    [Parameter()]
    [string] $OutputFilePath,

    [Parameter()]
    [switch] $Force
)
begin
{
    $ErrorActionPreference = "Stop"

    if ([string]::IsNullOrWhitespace($HighRiskPhrasesFilePath))
    {
        throw "Parameter 'HighRiskPhrasesFilePath' must be non-empty."
    }
    if ([string]::IsNullOrWhitespace($LowRiskPhrasesFilePath))
    {
        throw "Parameter 'LowRiskPhrasesFilePath' must be non-empty."
    }    
    if ([string]::IsNullOrWhitespace($OutputFilePath))
    {
        throw "Parameter 'OutputFilePath' must be non-empty."
    }   

    [string] $currentLocation = Get-Location

    [string] $highRiskPhrasesFullFilePath = [Path]::GetFullPath($HighRiskPhrasesFilePath, $currentLocation)
    if (!([File]::Exists($highRiskPhrasesFullFilePath)))
    {
        throw "The 'high risk phrases' file resolved to path ""$highRiskPhrasesFullFilePath"" is not found."
    }

    [string] $lowRiskPhrasesFullFilePath = [Path]::GetFullPath($LowRiskPhrasesFilePath, $currentLocation)
    if (!([File]::Exists($lowRiskPhrasesFullFilePath)))
    {
        throw "The 'low risk phrases' file resolved to path ""$lowRiskPhrasesFullFilePath"" is not found."
    }

    [string] $outputFullFilePath = [Path]::GetFullPath($OutputFilePath, $currentLocation)
    if ([File]::Exists($outputFullFilePath) -and -not $Force)
    {
        throw "The file resolved to path ""$outputFullFilePath""  already exists, and the '-Force' flag was not specified. Either delete the file, or override it by passing the '-Force' flag."
    }

    [string[]] $fullFilePathsArray = switch ($PSCmdlet.ParameterSetName) `
    {
        'ListOfFiles' 
        {
            if ($FilePath -eq $null -or $FilePath.Length -lt 1)
            {
                throw 'Parameter ''FilePath'' must be non-empty if specified.'
            }

            $FilePath | % `
            {
                if ([string]::IsNullOrWhitespace($_))
                {
                    throw 'All file paths in parameter ''FilePath'' must be non-empty.'
                }
                $fullFilePath = [Path]::GetFullPath($_, $currentLocation)
                if (!([File]::Exists($fullFilePath)))
                {
                    throw "The file ""$fullFilePath"" is not found."
                }

                $fullFilePath
            }
        }

        'AllInDirectory'
        {
            if ([string]::IsNullOrWhitespace($DirectoryPath))
            {
                throw 'Parameter ''DirectoryPath'' must be non-empty if specified.'
            }

            $path = [Path]::GetFullPath($DirectoryPath, $currentLocation)
            if (!([Directory]::Exists($path)))
            {
                throw "Directory ""$path"" is not found."
            }

            (Get-ChildItem -Path $DirectoryPath -File).FullName
        }
        default
        {
            throw "The ParameterSet '$($PSCmdlet.ParameterSetName)' is not yet supported."
        }
    }

    [HashSet[string]] $fullFilePaths = [HashSet[string]]::new($fullFilePathsArray)

    [string[]] $highRiskPhrases = [File]::ReadAllLines($highRiskPhrasesFullFilePath)
    [string[]] $lowRiskPhrases = [File]::ReadAllLines($lowRiskPhrasesFullFilePath)

    function Get-StringOccurrencesInString 
    (
        [string[]] $searchString, `
        [string] $targetString, `
        [StringComparison] $comparisonType = [StringComparison]::OrdinalIgnoreCase
    )
    {
        [int] $occurrences = 0
        foreach ($string in $searchString)
        {
            [int] $targetStringIndex = 0
            do
            {
                [int] $occurrenceIndex = $targetString.IndexOf($string, $targetStringIndex, $comparisonType)
                if ($occurrenceIndex -ne -1)
                {
                    $occurrences++
                    $targetStringIndex = $occurrenceIndex + 1
                }
            } 
            while ($occurrenceIndex -ne -1)
        }
        return $occurrences
    }
}
process
{
    [Dictionary[string, int]] $offenceScoreByFile = [Dictionary[string, int]]::new()
    foreach ($fullFilePath in $fullFilePaths)
    {   
        [int] $offenceScore = 0
        
        [string[]] $fileContent = [File]::ReadAllLines($fullFilePath)
        foreach ($line in $fileContent)
        {  
            $offenceScore = `
                $offenceScore + `
                (Get-StringOccurrencesInString $lowRiskPhrases $line) + `
                (Get-StringOccurrencesInString $highRiskPhrases $line) * 2
        }
        $offenceScoreByFile.Add($fullFilePath, $offenceScore)
    }

    [string[]] $output = @()

    switch ($PSCmdlet.ParameterSetName) `
    {
        'ListOfFiles' 
        {
            foreach ($file in $FilePath)
            {
                $fullFilePath = [Path]::GetFullPath($file, $currentLocation)
                $output += "$file`:$($offenceScoreByFile[$fullFilePath])"
            }
        }

        'AllInDirectory'
        {
            $offenceScoreByFile.Keys | Sort-Object | % `
            {
                $output += "$_`:$($offenceScoreByFile[$_])"
            }
        }
        default
        {
            throw "The ParameterSet '$($PSCmdlet.ParameterSetName)' is not yet supported."
        }
    }

    [Encoding] $outputFileEncoding = [UTF8Encoding]::new($false)
    [File]::WriteAllLines($outputFullFilePath, $output, $outputFileEncoding)

    return $output
}