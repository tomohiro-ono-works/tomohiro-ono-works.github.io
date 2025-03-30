function Cleanse-CsvWithSchema {
    param (
        [string]$InputCsvPath,
        [string]$InputCsvEncoding = "utf8",
        [string]$OutputCsvPath,
        [string]$OutputCsvEncoding = "utf8",
        [string]$SchemaJsonPath,
        [string]$SchemaJsonEncoding = "utf8"
    )

    if (-not (Test-Path $InputCsvPath)) {
        Write-Error "入力CSVファイルが見つかりません: $InputCsvPath"
        return
    }
    if (-not (Test-Path $SchemaJsonPath)) {
        Write-Error "スキーマファイルが見つかりません: $SchemaJsonPath"
        return
    }

    $schemaJson = Get-Content -Path $SchemaJsonPath -Encoding $SchemaJsonEncoding | ConvertFrom-Json
    $schemaMap = @{}
    foreach ($field in $schemaJson) {
        $schemaMap[$field.description] = $field.type
    }

    $rows = Import-Csv -Path $InputCsvPath -Encoding $InputCsvEncoding
    $output = @()

    foreach ($row in $rows) {
        $newRow = @{}
        foreach ($col in $row.PSObject.Properties.Name) {
            $value = $row.$col
            if ($schemaMap.ContainsKey($col) -and $schemaMap[$col] -eq "date") {
                try {
                    $parsed = [datetime]::Parse($value)
                    $value = $parsed.ToString("yyyy-MM-dd")
                } catch {
                    # パースできない場合は元の値を維持
                }
            }
            $newRow[$col] = $value
        }
        $output += [pscustomobject]$newRow
    }

    $output | Export-Csv -Path $OutputCsvPath -Encoding $OutputCsvEncoding -NoTypeInformation
    Write-Host "✅ クレンジング完了: $OutputCsvPath"
}

Write-Host "関数 Cleanse-CsvWithSchema が定義されました。"
