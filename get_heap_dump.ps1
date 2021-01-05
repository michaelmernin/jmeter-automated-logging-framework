param(
    $DOMAIN,
    $PORT,
    $HEAP_DIR,
    $HEAP_NAME
)

Set-Location -Path $HEAP_DIR

if ($PORT) {
    $DOMAIN = $DOMAIN + ":" + $PORT
}
$uri = "https://" + $DOMAIN + "/example/heapdump/endpoint"

$ProgressPreference = "SilentlyContinue"

$response = Invoke-WebRequest -URI $uri -Certificate (Get-PfxCertificate C:\example\path\to\example.cer)

Set-Content -Path "$HEAP_NAME" -Encoding Byte -Value $response.content

C:\example\path\to\HeapDumpAnalyzer\ParseHeapDump.bat "$HEAP_NAME"

C:\example\path\to\HeapDumpAnalyzer\ParseHeapDump.bat "$HEAP_NAME" org.eclipse.mat.api:suspects

Remove-Item * -Exclude *.zip -Recurse -Force

$full = "$HEAP_DIR\$HEAP_NAME"

$report_name = $full.Substring(0, $full.Length - 13) + "_Leak_Suspects.zip"

Expand-Archive $report_name -DestinationPath $HEAP_DIR

Remove-Item $report_name -Recurse -Force