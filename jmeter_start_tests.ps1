param(
    $TEST_CASES,
    $TEMPLATE_DIR,
    $LOG_DIR
)
$date = Get-Date
$year = $date.Year
$month = $date.Month
$day = $date.Day
$hour = $date.Hour
$minute = $date.Minute
$second = $date.Second
$day_time = "$hour" + "-" + "$minute" + "-" + "$second"
$ScriptPath = Get-Location
$test_case_path = "$ScriptPath\$TEST_CASES"
$test_cases = Import-Csv $test_case_path

####----STATIC VALUES----####
$temp_dir = "$ScriptPath\TEMP\"
if(!(Test-Path -Path $temp_dir)){
    New-Item -Type dir $temp_dir
}
if(!$TEMPLATE_DIR){
    $template_dir = "$ScriptPath\test_templates\"
}
if(!$LOG_DIR){
    $log_dir = "C:\example\path\to\jmeter_logs\"
}
$SAVE_FILE = "last_run_jmeter_script.jmx"
####----END STATIC VALUES----####


# Iterate through csv test cases
foreach ($case in $test_cases) {
    # Delete contents (if any) in TEMP/
    Remove-Item "$temp_dir*" -Recurse
    $api = $($case.api_name)
    $template_name = $($case.jmx_template)
    $csv = $($case.csv_data)
    $csv_vars = $($case.csv_vars)
    $domain = $($case.domain)
    $path = $($case.path)
    $port = $($case.port)
    $method = $($case.method)
    $json_body = $($case.json_body)
    
    $template = "$template_dir\$template_name"

    
    # Run jmeter script with values from csv test cases
    & "$ScriptPath\write_jmx_file.ps1" -DOMAIN $domain -PATH $path -PORT $port -METHOD $method -JMX_TEMPLATE $template -SAVE_FILE $SAVE_FILE -CSV_FILE $csv -CSV_VARS $csv_vars -API_NAME $api -JSON_BODY $json_body
    jmeter -n -t $SAVE_FILE
    $new_dashboard_folder_name = "$temp_dir" + "$day_time" + "_$api" + "_$domain" + "_dashboard"
    $dash_csv = "$temp_dir" + "$api" + "_" + $domain + "_dashboard.csv"
    $new_heapdump_folder_name = "$day_time" + "_$api" + "_$domain" + "_heapdump"
    Write-Host $new_heapdump_folder_name
    Write-Host "in start tests"
    Write-Host $temp_dir
    if(!(Test-Path -Path $temp_dir\$new_heapdump_folder_name)){
        New-Item -Type dir $temp_dir\$new_heapdump_folder_name
    }
    # Generate Dashboard
	jmeter -g $dash_csv -o "$new_dashboard_folder_name"
    $old_name = "$temp_dir" + "$api" + "_results.xml"
    
	#Generates Response Graph, deprecated since dashboard
    #JMeterPluginsCMD.bat --generate-png $png_name --input-jtl $old_name --plugin-type ResponseTimesOverTime
    $new_name = $day_time + "_$api" + "_$domain" + "_results.xml"  
    Rename-Item -Path $old_name -NewName $new_name

    # Generates heapdump analysis and saves results into TEMP/
    if ($port) {
        & "$ScriptPath\get_heap_dump.ps1" -DOMAIN $domain -PORT $port -HEAP_NAME $new_heapdump_folder_name -HEAP_DIR $temp_dir\$new_heapdump_folder_name
    }
    
    
    $individual_destination = $log_dir + "\apis\$api\$year\0$month-0$day\$day_time"
    $run_dashboard_destination = $log_dir + "\runs\$year\0$month-0$day\$day_time\dashboards\$domain"
    $run_responses_destination = $log_dir + "\runs\$year\0$month-0$day\$day_time\responses\$domain"
    $run_heapdump_destination = $log_dir + "\runs\$year\0$month-0$day\$day_time\heapdumps\$domain"
    if(!(Test-Path -Path $individual_destination)){
        New-Item -Type dir $individual_destination
    }
    if(!(Test-Path -Path $run_dashboard_destination)){
        New-Item -Type dir $run_dashboard_destination
    }
	if(!(Test-Path -Path $run_responses_destination)){
        New-Item -Type dir $run_responses_destination
    }
    if(!(Test-Path -Path $run_heapdump_destination)){
        New-Item -Type dir $run_heapdump_destination
    }
    Copy-Item "$temp_dir*" -Destination $individual_destination -Recurse
    Copy-Item "$new_dashboard_folder_name" -Destination $run_dashboard_destination -Recurse
    Copy-Item "$temp_dir$new_name" -Destination $run_responses_destination -Recurse
    Copy-Item "$temp_dir\$new_heapdump_folder_name" -Destination $run_heapdump_destination -Recurse
    Get-ChildItem -Recurse -Path "$temp_dir*" | Remove-Item -Force -Recurse
    Remove-Item "$ScriptPath\jmeter.log"
    

}
