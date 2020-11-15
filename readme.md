### System Requirements

You need to have PowerShell Core 7.0+. Thats it.

### Usage

From PowerShell:

If the script is on the path:
```powershell
 Write-OffenceScoreToFile -HighRiskPhrasesFilePath <path-to-highrisk-phrases> -LowRiskPhrasesFilePath <path-to-lowrisk-phrases> -FilePath <array-of-file-paths> -OutputFilePath <path-to-output-file>
 ```

If the script is not on the path:
```powershell
& absolute-path-to-script -HighRiskPhrasesFilePath <path-to-highrisk-phrases> -LowRiskPhrasesFilePath <path-to-lowrisk-phrases> -FilePath <array-of-file-paths> -OutputFilePath <path-to-output-file>
```

If you want to scan all files in directory (non recursively) instead of a list of files:
```powershell
 Write-OffenceScoreToFile -HighRiskPhrasesFilePath <path-to-highrisk-phrases> -LowRiskPhrasesFilePath <path-to-lowrisk-phrases> -DirectoryPath <path-to-directory> -OutputFilePath <path-to-output-file>
```

#### Testing
There are unit/integration tests contained in the `pester/Write-OffenceScoreToFile.tests.ps1` folder that can be used to validate the script's correctness. I have based the test cases off of the 15 input files provided.

Pester can be installed by running the following two commands from your PowerShell Core session:

`Install-Module Pester -Force`

`Import-Module Pester -Passthru`

The output of the second command should be as follows

```
C:\> Import-Module Pester -Passthru

ModuleType Version    PreRelease Name
---------- -------    ---------- ----
Script     5.0.4                 Pester
```

The tests can then be run with the following command:

`Invoke-Pester -Output Detailed <path-to-pester-tests>`

This should display a list of test cases and the result of them:

```
Describing Write-OffenseScoreToFile
 Context Failure Cases - Shared
   [+] Should throw if no 'HighRiskPhrasesFilePath' is specified 24ms (24ms|1ms)
   [+] Should throw if file 'HighRiskPhrasesFilePath' does not exist 9ms (8ms|1ms)
   [+] Should throw if 'LowRiskPhrasesFilePath' is not specified 13ms (12ms|1ms)
   [+] Should throw if file 'LowRiskPhrasesFilePath' does not exist 13ms (12ms|1ms)
   [+] Should throw if 'OutputFilePath' is not specified. 8ms (8ms|1ms)
   [+] Should throw if file 'OutputFilePath' already exists and 'Force' is not specified 14ms (13ms|1ms)
   [+] Should throw a parameter set error if neither 'FilePath' nor 'DirectoryPath' are specified 8ms (7ms|1ms)
 Context Failure Cases - AllInDirectory
   [+] Should throw if no 'DirectoryPath' is specified 7ms (7ms|0ms)
   [+] Should throw if directory 'DirectoryPath' does not exist 7ms (6ms|1ms)
 Context Failure Cases - List of Files
   [+] Should throw if no 'FilePath' is specified 7ms (7ms|0ms)
   [+] Should throw if any file path in 'FilePath' is null 17ms (16ms|0ms)
   [+] Should throw if any file path in 'FilePath' does not exist 13ms (12ms|1ms)
 Context Happy Path - ListOfFiles
   [+] Should correctly score files with special characters 11ms (11ms|0ms)
   [+] Should correctly score simple files with no special cases 14ms (14ms|1ms)
   [+] Should correctly score files with risky phrases regardless of character case 8ms (8ms|1ms)
   [+] Should correctly score multiline files 7ms (7ms|1ms)
   [+] Should output file scores in the same order that the files were passed in 17ms (17ms|1ms)
 Context Happy Path - AllInDirectory
   [+] Should write the offence score of all files in the 'testdata/inputs' folder to the specified output file 20ms (20ms|1ms)
   [+] Should overwrite the offence score of all files in the 'testdata/inputs' folder in the already existing 'OutputFile' 19ms (19ms|1ms)
Tests completed in 515ms
Tests Passed: 19, Failed: 0, Skipped: 0 NotRun: 0
```

#### Remarks
The Force flag can be used to overwrite an existing file (specified by the `OutputFile` parameter)
The `DirectoryPath` parameter can be used en lieu of the `FilePath` parameter to generate a report for all files in the specified directory. Note that this will attempt to parse ALL files, not just text files.

### Assumptions

- Special characters/whitespace/newlines breaking up a 'risky phrase' should not be matched. ie `pl an` would not be matched, given that `plan` is a 'risky word'.
- Variations of matched words that differ only by casing /should/ be matched; that is to say `PLAN` as well as `pLan` or `PlAN` would be matched, given that `plan` is a 'risky word'.
- The files defining the risky phrases are well formed; there is no real error checking on file contents for high or low risk phrase definitions.
- The order of the output should be sorted alphabetically based on full file path when using the `DirectoryPath` parameter. If `FilePath` is specified instead, it will use the path provided and preserve order. (in `DirectoryPath`, the output will contain the absolute path to the file, even if the `DirectoryPath` parameter is relative.)
- The script is allowed to return a value; in this case it returns the string array that is written to file.
- The encoding of the output file should be UTF8 (without BOM)
- Characters can be part of multiple matches; for example, suppose you have a file with contents `sss`, and `ss` is considered a low risk risky word. This script will mark the score of this file as 2; the first match would be the first and second s, and the second match would be the second and third s.






