function Get-MatchingFile {
    param (
        [string]$SourceFolder,
        [string]$FilePattern = ".*"
    )

    if (-not (Test-Path $SourceFolder)) {
        Write-Error "指定されたフォルダが存在しません: $SourceFolder"
        return $null
    }

    # 正規表現の妥当性を事前にチェック
    try {
        $null = [regex]::new($FilePattern)
    } catch {
        Write-Error "正規表現エラー: $($_.Exception.Message)"
        return "REGEX_ERROR"
    }

    $matchedFiles = Get-ChildItem -Path $SourceFolder -File | Where-Object { $_.Name -match $FilePattern }

    if (-not $matchedFiles -or $matchedFiles.Count -eq 0) {
        Write-Error "一致するファイルが見つかりませんでした。"
        return $null
    }

    $targetFile = $matchedFiles | Sort-Object Name -Descending | Select-Object -First 1
    return $targetFile.FullName
}
