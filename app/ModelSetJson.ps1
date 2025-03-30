function Get-Parameters {
    param (
        [string]$ConfigPath = "config.json"
    )
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "設定ファイルが見つかりません: $ConfigPath"
        exit 1
    }
    $config = Get-Content $ConfigPath -Encoding utf8 | ConvertFrom-Json
    # 初期値
    $parameters = @{
        ProjectName             = "サンプル"
        SourceFolder            = ".\\"
        SourceFilePattern       = ".*"
        SourceFileEncoding      = "Unicode"
        SourceFileHeaderLine    = 1
        SourceFileDataStartLine = 2
        SourceFileImportLines   = 0
        ImportFileColumns       = "*"
        ExportFileEncoding      = "Default"
    }
    # 出力確認用
    $config.PSObject.Properties | ForEach-Object {
        Write-Host "configキー: $($_.Name) = $($_.Value)"
    }
    # キー列挙固定（列挙中の変更エラー回避）
    $keys = @($parameters.Keys)
    foreach ($key in $keys) {
        $prop = $config.PSObject.Properties | Where-Object { $_.Name -eq $key }
        if ($prop) {
            $parameters[$key] = $prop.Value
        }
    }
    # 結果を返す
    return $parameters
}