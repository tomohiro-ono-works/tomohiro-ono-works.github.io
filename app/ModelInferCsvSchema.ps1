function Infer-CsvSchema {
    param (
        [string]$CsvPath,
        [string]$JsonOutputPath,
        [int]$SampleSize = 100,
        [string]$InputEncoding = "utf8",
        [string]$OutputEncoding = "utf8"
    )

    if (-not (Test-Path $CsvPath)) {
        Write-Error "CSVファイルが見つかりません: $CsvPath"
        return
    }

    # CSV読み込み（最大 $SampleSize 行まで）
    $rows = Get-Content -Path $CsvPath -Encoding $InputEncoding | ConvertFrom-Csv | Select-Object -First $SampleSize
    if (-not $rows) {
        Write-Error "CSVにデータが存在しません"
        return
    }

    $header = $rows[0].PSObject.Properties.Name
    $schema = @()

    for ($i = 0; $i -lt $header.Count; $i++) {
        $colName = $header[$i]
        $fieldName = ('fields_{0:000}' -f ($i + 1))
        $samples = $rows | ForEach-Object { $_.$colName }

        # データ型の推定
        $type = 'string'  # デフォルト
        if ($samples -match '^[+-]?\d+$') {
            $type = 'int64'
        } elseif ($samples -match '^[+-]?\d*\.\d+$') {
            $type = 'float64'
        } elseif ($samples -match '^\d{4}[-/]\d{1,2}[-/]\d{1,2}$') {
            $type = 'date'
        } elseif ($samples -match '^(True|False|true|false)$') {
            $type = 'boolean'
        }

        $schema += [pscustomobject]@{
            name        = $fieldName
            type        = $type
            description = $colName
        }
    }

    # JSONとして出力（エクスポート文字コードを指定）
    $schema | ConvertTo-Json -Depth 3 | Set-Content -Encoding $OutputEncoding -Path $JsonOutputPath

    Write-Host "✅ JSONスキーマ出力完了: $JsonOutputPath"
}

Write-Host "関数 Infer-CsvSchema が定義されました。"
