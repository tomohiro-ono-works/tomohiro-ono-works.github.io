function Main {
    param (
        [string]$FilePath,
        [string]$ProjectName,
        [string]$Encoding = "utf8",
        [int]$HeaderLine = 1,
        [int]$DataStartLine = 2,
        [int]$MaxDataLines = 0,
        [string]$Delimiter = "`t",
        [int]$ChunkSize = 10000,
        [string]$OutputEncoding = "Default",
        [string[]]$IncludeColumns = @()
    )
    if ($IncludeColumns.Count -eq 1 -and $IncludeColumns[0] -like "*,*") {
        $IncludeColumns = $IncludeColumns[0].Split(",").Trim()
    }
    Write-Host "FilePath:$FilePath"
    Write-Host "ProjectName:$ProjectName"
    Write-Host "IncludeColumns:$IncludeColumns"
    Write-Host "Encoding:$Encoding"
    Write-Host "HeaderLine:$HeaderLine"
    Write-Host "DataStartLine:$DataStartLine"
    Write-Host "MaxDataLines:$MaxDataLines"
    Write-Host "Delimiter:$Delimiter"
    Write-Host "ChunkSize:$ChunkSize"
    Write-Host "OutputEncoding:$OutputEncoding"
    Write-Host "文字コード：" ([int][char]$Delimiter[0])

    $today = Get-Date -Format "yyyyMMdd"
    $outputFileName = "temp_${ProjectName}_$today.csv"
    $outputPath = Join-Path -Path (Split-Path -Parent $FilePath) -ChildPath $outputFileName

    $lineIndex = 0
    $dataLineCount = 0
    $headerParsed = $false
    $finalHeader = @()
    $cleanHeader = @{ }
    $selectedIndexes = @()
    $buffer = @()
    $stopProcessing = $false

    $chunks = Get-TsvChunks -FilePath $FilePath -Encoding $Encoding -ChunkSize $ChunkSize
    foreach ($chunk in $chunks) {
        foreach ($line in $chunk) {
            Write-Host "[Chunk] Processing lineIndex=$lineIndex : $line"
            if ($stopProcessing) { break }

            if (-not $headerParsed -and $lineIndex -eq ($HeaderLine - 1)) {
                Convert-Header -Line $line -Delimiter $Delimiter `
                    -CleanHeader ([ref]$cleanHeader) -FinalHeader ([ref]$finalHeader)

                if ($IncludeColumns.Count -gt 0) {
                    $tempIndexes = @()
                    foreach ($col in $IncludeColumns) {
                        $idx = $finalHeader.IndexOf($col)
                        if ($idx -ge 0) { $tempIndexes += $idx }
                    }
                    $selectedIndexes = $tempIndexes
                    $finalHeader = $IncludeColumns
                } else {
                    $selectedIndexes = 0..($finalHeader.Count - 1)
                }

                Write-CsvChunk -Lines @($finalHeader -join ",") `
                    -OutputPath $outputPath -Encoding $OutputEncoding -Append:$false
                $headerParsed = $true
            }

            if ($lineIndex -ge ($DataStartLine - 1) -and $line -ne "") {
                if ($MaxDataLines -gt 0 -and $dataLineCount -ge $MaxDataLines) {
                    $stopProcessing = $true
                    break
                }

                Convert-Row -Line $line -Delimiter $Delimiter `
                    -Indexes $selectedIndexes -Buffer ([ref]$buffer)
                $dataLineCount++
                Write-Host "[Info] Data line count: $dataLineCount"

                if ($buffer.Count -ge $ChunkSize) {
                    Write-CsvChunk -Lines $buffer -OutputPath $outputPath `
                        -Encoding $OutputEncoding -Append:$true
                    $buffer = @()
                }
            }

            $lineIndex++
        }
        if ($stopProcessing) { break }
    }

    if ($buffer.Count -gt 0) {
        Write-CsvChunk -Lines $buffer -OutputPath $outputPath `
            -Encoding $OutputEncoding -Append:$true
    }
    Write-Host "✅ 変換完了: $outputPath"
    return $outputFileName
}


function Get-TsvChunks {
    param ($FilePath, $Encoding, $ChunkSize)
    Get-Content -Path $FilePath -Encoding $Encoding -ReadCount $ChunkSize
}

function Convert-Header {
    param ($Line, $Delimiter, [ref]$CleanHeader, [ref]$FinalHeader)
    $rawHeader = $Line.Split($Delimiter)
    $header = @()
    for ($i = 0; $i -lt $rawHeader.Count; $i++) {
        $name = $rawHeader[$i].Trim()
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = "Column$($i+1)"
        }
        if ($CleanHeader.Value.ContainsKey($name)) {
            $count = ++$CleanHeader.Value[$name]
            $name = "$name`_$count"
        } else {
            $CleanHeader.Value[$name] = 1
        }
        $header += $name
    }
    Write-Host "[Header] raw: $($rawHeader -join '|')"
    Write-Host "[Header] cleaned: $($header -join '|')"
    $FinalHeader.Value = $header
}

function Convert-Row {
    param ($Line, $Delimiter, $Indexes, [ref]$Buffer)
    $values = $Line.Split($Delimiter)
    $row = @()
    Write-Host "[Row] values: $($values -join '|')"
    Write-Host "[Row] indexes: $($Indexes -join ',')"
    foreach ($i in $Indexes) {
        $value = ""
        if ($i -lt $values.Count) {
            $value = $values[$i]
        }
        if ($value -notmatch '^".*"$') {
            $escaped = $value -replace '"', '""'
            $row += '"' + $escaped + '"'
        } else {
            $row += $value
        }
    }
    Write-Host "[Row] selected: $($row -join '|')"
    $Buffer.Value += ($row -join ",")
}

function Write-CsvChunk {
    param ($Lines, $OutputPath, $Encoding, $Append)
    Write-Host "[Write] Buffer flushed ($($Lines.Count) rows) to $OutputPath"
    if ($Append) {
        $Lines | Add-Content -Path $OutputPath -Encoding $Encoding
    } else {
        $Lines | Out-File -FilePath $OutputPath -Encoding $Encoding
    }
}


function Get-CleanedHeader {
    param (
        [string]$FilePath,
        [string]$Encoding = "utf8",
        [int]$HeaderLine = 1,
        [char]$Delimiter = "`t"
    )
    Write-Host "$FilePath,$Encoding,$HeaderLine,$Delimiter,"
    if (-not (Test-Path $FilePath)) {
        Write-Error "指定されたファイルが存在しません: $FilePath"
        return $null
    }
    Write-Host "2"
    try {
        $lines = @(Get-Content -Path $FilePath -Encoding $Encoding)
        Write-Host "3"
        if ($HeaderLine -gt $lines.Count) {
            Write-Error "指定されたヘッダー行がファイル行数を超えています。"
            return $null
        }
        Write-Host "4"
        $extractedHeaderLine = $lines[$HeaderLine - 1]
        Write-Host "5"
    } catch {
        Write-Error "ファイル読み取りエラー: $_"
        return $null
    }

    $rawHeader = $extractedHeaderLine.Split($Delimiter)
    $cleanHeader = @{}
    $finalHeader = @()

    for ($i = 0; $i -lt $rawHeader.Count; $i++) {
        $name = $rawHeader[$i].Trim()
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = "Column$($i+1)"
        }
        if ($cleanHeader.ContainsKey($name)) {
            $count = ++$cleanHeader[$name]
            $name = "$name`_$count"
        } else {
            $cleanHeader[$name] = 1
        }
        $finalHeader += $name
    }

    return $finalHeader -join ","
}
