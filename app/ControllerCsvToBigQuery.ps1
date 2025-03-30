param (
    [string]$ConfigPath = ".\testcase\config.json"
)

# 設定ファイルを取得
. ".\proc\ModelSetJson.ps1"
$params = Get-Parameters -ConfigPath $ConfigPath

# 参照元ファイルを取得
. ".\proc\ModelGetFliepath.ps1"
$targetFile = Get-MatchingFile `
    -SourceFolder $params.SourceFolder `
    -FilePattern $params.SourceFilePattern
Write-Host "対象ファイル: $targetFile"

# ファイル取得
. ".\proc\ModelConvertCsv.ps1"
$outputFileName = Main `
    -FilePath $targetFile `
    -ProjectName $params.ProjectName `
    -Encoding $params.SourceFileEncoding `
    -HeaderLine $params.SourceFileHeaderLine `
    -DataStartLine $params.SourceFileDataStartLine `
    -OutputEncoding $params.ExportFileEncoding `
    -MaxDataLines $params.SourceFileImportLines `
    -IncludeColumns $params.ImportFileColumns

# データ型を取得
. ".\proc\ModelInferCsvSchema.ps1"
Infer-CsvSchema `
    -CsvPath ".\元データ\$outputFileName" `
    -JsonOutputPath "schema.json" `
    -SampleSize 100 `
    -InputEncoding "Default" `
    -OutputEncoding "utf8"

# データクレンジング
. ".\proc\ModelCrensingData.ps1"
Cleanse-CsvWithSchema `
    -InputCsvPath ".\元データ\$outputFileName" `
    -InputCsvEncoding "Default" `
    -OutputCsvPath ".\元データ\temp_$outputFileName" `
    -OutputCsvEncoding "Default" `
    -SchemaJsonPath "schema.json" `
    -SchemaJsonEncoding "utf8"



