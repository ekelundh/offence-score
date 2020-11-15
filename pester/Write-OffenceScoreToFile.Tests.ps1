BeforeAll { 
    [string] $rootDirectory = (Split-Path -Path $PSScriptRoot -Parent) 
    [string] $writeOffenceScoreToFile = Join-Path $rootDirectory 'Write-OffenceScoreToFile.ps1'
    [string] $pesterRoot = Join-Path $rootDirectory 'pester'
    [string] $testDataRoot = Join-Path $pesterRoot 'testdata'
    [string] $outputFilePath = Join-Path $testDataRoot 'output.txt'
    [string] $inputTestDataRoot = Join-Path $testDataRoot 'input'

    [string] $highRiskPhrasesFilePath = Join-Path $testDataRoot 'high_risk_phrases.txt'
    [string] $lowRiskPhrasesFilePath = Join-Path $testDataRoot 'low_risk_phrases.txt'
    [string] $pathThatDoesntExist = Join-Path $testDataRoot 'IDontExist'
    [string] $multiLineFile = Join-Path $inputTestDataRoot 'multiline1.txt'
    [string] $simpleFile0 = Join-Path $inputTestDataRoot 'simple0.txt'
    [string] $simpleFile1 = Join-Path $inputTestDataRoot 'simple1.txt'
    [string] $simpleFile2 = Join-Path $inputTestDataRoot 'simple2.txt'
    [string] $simpleFile3 = Join-Path $inputTestDataRoot 'simple3.txt'
    [string] $simpleFile4 = Join-Path $inputTestDataRoot 'simple4.txt'
    [string] $mixedCaseFile2 = Join-Path $inputTestDataRoot 'mixedCase2.txt'
    [string] $mixedCaseFile5 = Join-Path $inputTestDataRoot 'mixedCase5.txt'
    [string] $specialCharFile1 = Join-Path $inputTestDataRoot 'specialChar1.txt'
    [string] $specialCharFile3 = Join-Path $inputTestDataRoot 'specialChar3.txt'

    [string] $simpleFile0Result = 'simple0.txt:0'
    [string] $simpleFile1Result = 'simple1.txt:1'
    [string] $simpleFile2Result = 'simple2.txt:2'
    [string] $simpleFile3Result = 'simple3.txt:3'
    [string] $simpleFile4Result = 'simple4.txt:4'
    [string] $mixedCaseFile2Result = 'mixedCase2.txt:2'
    [string] $mixedCaseFile5Result = 'mixedCase5.txt:5'
    [string] $specialCharFile1Result = 'specialChar1.txt:1'
    [string] $specialCharFile3Result = 'specialChar3.txt:3'
    [string] $multiLineFileResult = 'multiLine1.txt:1'
}   

Describe 'Write-OffenseScoreToFile' {
    Context 'Failure Cases - Shared' {
        It 'Should throw if no ''HighRiskPhrasesFilePath'' is specified' {
            {
                & $writeOffenceScoreToFile `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $simpleFile0 `
                    -OutputFilePath $outputFilePath
            } | Should -Throw 'Parameter ''HighRiskPhrasesFilePath'' must be non-empty.'
        }

        It 'Should throw if file ''HighRiskPhrasesFilePath'' does not exist' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $pathThatDoesntExist `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $simpleFile0 `
                    -OutputFilePath $outputFilePath
            } | Should -Throw "The 'high risk phrases' file resolved to path ""$pathThatDoesntExist"" is not found."
        }

        It 'Should throw if ''LowRiskPhrasesFilePath'' is not specified' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -FilePath $simpleFile0 `
                    -OutputFilePath $outputFilePath
            } | Should -Throw 'Parameter ''LowRiskPhrasesFilePath'' must be non-empty.'
        }

        It 'Should throw if file ''LowRiskPhrasesFilePath'' does not exist' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $pathThatDoesntExist `
                    -FilePath $simpleFile0 `
                    -OutputFilePath $outputFilePath
            } | Should -Throw "The 'low risk phrases' file resolved to path ""$pathThatDoesntExist"" is not found."
        }

        It 'Should throw if ''OutputFilePath'' is not specified.' {
             
            {    & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $simpleFile0 `
            } | Should -Throw "Parameter 'OutputFilePath' must be non-empty."
        }   

        It 'Should throw if file ''OutputFilePath'' already exists and ''Force'' is not specified' {
            {
                New-Item -Path $outputFilePath -ItemType 'file' -Value 'this is a string'
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $simpleFile0 `
                    -OutputFilePath $outputFilePath
            } | Should -Throw "The file resolved to path ""$outputFilePath""  already exists, and the '-Force' flag was not specified. Either delete the file, or override it by passing the '-Force' flag."
        }

        It 'Should throw a parameter set error if neither ''FilePath'' nor ''DirectoryPath'' are specified' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -OutputFilePath $outputFilePath

            } | Should -Throw '*Parameter set cannot be resolved*'
        }

        # TODO: Add test cases for illegal paths...? (probably overkill)
    }

    Context 'Failure Cases - AllInDirectory' {
        It 'Should throw if no ''DirectoryPath'' is specified' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -DirectoryPath '' `
                    -OutputFilePath $outputFilePath
            } | Should -Throw 'Parameter ''DirectoryPath'' must be non-empty if specified.'
        }

        It 'Should throw if directory ''DirectoryPath'' does not exist' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -DirectoryPath $pathThatDoesntExist `
                    -OutputFilePath $outputFilePath
            } | Should -Throw "Directory ""$pathThatDoesntExist"" is not found."
        }
    }

    Context 'Failure Cases - List of Files' {
        It 'Should throw if no ''FilePath'' is specified' {
           {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $null `
                    -OutputFilePath $outputFilePath
            } | Should -Throw 'Parameter ''FilePath'' must be non-empty if specified.'
        }

        It 'Should throw if any file path in ''FilePath'' is null' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath @($simpleFile0, '') `
                    -OutputFilePath $outputFilePath
            } | Should -Throw 'All file paths in parameter ''FilePath'' must be non-empty.' 
        }

        It 'Should throw if any file path in ''FilePath'' does not exist' {
            {
                & $writeOffenceScoreToFile `
                    -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                    -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                    -FilePath $pathThatDoesntExist `
                    -OutputFilePath $outputFilePath
            } | Should -Throw "The file ""$pathThatDoesntExist"" is not found."
        }
    }

    Context 'Happy Path - ListOfFiles' {
        It 'Should correctly score files with special characters' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -FilePath @($specialCharFile1, $specialCharFile3) `
                -OutputFilePath $outputFilePath | Out-Null
            $outputFilePath | Should -FileContentMatch $specialCharFile1Result 
            $outputFilePath | Should -FileContentMatch $specialCharFile3Result
        }

        It 'Should correctly score simple files with no special cases' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -FilePath @($simpleFile0, $simpleFile1, $simpleFile2, $simpleFile3, $simpleFile4) `
                -OutputFilePath $outputFilePath | Out-Null
            $outputFilePath | Should -FileContentMatch $simpleFile0Result 
            $outputFilePath | Should -FileContentMatch $simpleFile1Result
            $outputFilePath | Should -FileContentMatch $simpleFile2Result 
            $outputFilePath | Should -FileContentMatch $simpleFile3Result
            $outputFilePath | Should -FileContentMatch $simpleFile4Result
        }

        It 'Should correctly score files with risky phrases regardless of character case' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -FilePath @($mixedCaseFile2, $mixedCaseFile5) `
                -OutputFilePath $outputFilePath | Out-Null
            $outputFilePath | Should -FileContentMatch $mixedCaseFile2Result 
            $outputFilePath | Should -FileContentMatch $mixedCaseFile5Result
        }

        It 'Should correctly score multiline files' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -FilePath @($multiLineFile) `
                -OutputFilePath $outputFilePath | Out-Null
            $outputFilePath | Should -FileContentMatch $multiLineFileResult
        }

        It 'Should output file scores in the same order that the files were passed in' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -FilePath @($simpleFile3, $simpleFile4, $simpleFile0, $simpleFile1, $simpleFile2) `
                -OutputFilePath $outputFilePath | Out-Null
                
            [string[]] $fileContent = [System.IO.File]::ReadAllLines($outputFilePath)
            $fileContent[0] | Should -Match $simpleFile3Result
            $fileContent[1] | Should -Match $simpleFile4Result
            $fileContent[2] | Should -Match $simpleFile0Result
            $fileContent[3] | Should -Match $simpleFile1Result
            $fileContent[4] | Should -Match $simpleFile2Result
            $fileContent.Length | Should -Be 5
        }
    }

    Context 'Happy Path - AllInDirectory' {
        It 'Should write the offence score of all files in the ''testdata/inputs'' folder to the specified output file' {
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -DirectoryPath $inputTestDataRoot `
                -OutputFilePath $outputFilePath | Out-Null
            $outputFilePath | Should -FileContentMatch $simpleFile0Result 
            $outputFilePath | Should -FileContentMatch $simpleFile1Result
            $outputFilePath | Should -FileContentMatch $simpleFile2Result 
            $outputFilePath | Should -FileContentMatch $simpleFile3Result
            $outputFilePath | Should -FileContentMatch $simpleFile4Result
            $outputFilePath | Should -FileContentMatch $multiLineFileResult
            $outputFilePath | Should -FileContentMatch $mixedCaseFile2Result 
            $outputFilePath | Should -FileContentMatch $mixedCaseFile5Result
            $outputFilePath | Should -FileContentMatch $specialCharFile1Result 
            $outputFilePath | Should -FileContentMatch $specialCharFile3Result
        }

        It 'Should overwrite the offence score of all files in the ''testdata/inputs'' folder in the already existing ''OutputFile''' {
            New-Item -Path $outputFilePath -ItemType 'file' -Value 'this is a string'
            & $writeOffenceScoreToFile `
                -HighRiskPhrasesFilePath $highRiskPhrasesFilePath `
                -LowRiskPhrasesFilePath $lowRiskPhrasesFilePath `
                -DirectoryPath $inputTestDataRoot `
                -OutputFilePath $outputFilePath `
                -Force | Out-Null
            $outputFilePath | Should -FileContentMatch $simpleFile0Result 
            $outputFilePath | Should -FileContentMatch $simpleFile1Result
            $outputFilePath | Should -FileContentMatch $simpleFile2Result 
            $outputFilePath | Should -FileContentMatch $simpleFile3Result
            $outputFilePath | Should -FileContentMatch $simpleFile4Result
            $outputFilePath | Should -FileContentMatch $multiLineFileResult
            $outputFilePath | Should -FileContentMatch $mixedCaseFile2Result 
            $outputFilePath | Should -FileContentMatch $mixedCaseFile5Result
            $outputFilePath | Should -FileContentMatch $specialCharFile1Result 
            $outputFilePath | Should -FileContentMatch $specialCharFile3Result
        }
    }

    AfterEach {
        Remove-Item -Path $outputFilePath -Force -ErrorAction SilentlyContinue
    }
}