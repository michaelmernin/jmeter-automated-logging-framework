param (
    $API_NAME,
    $JMX_TEMPLATE,
    $CSV_FILE,
    $CSV_VARS,
    $CONCUR_TARGET_LEVEL,
    $RAMP_UP,
    $STEPS,
    $HOLD,
    $UNITS,
    $DOMAIN,
    $PORT,
    $PATH,
    $METHOD,
    $LOG_FILE,
    $SAVE_FILE,
    $SAVE_DIRECTORY,
    $JSON_BODY
    )

    [xml]$jmeter_jmx = Get-Content $JMX_TEMPLATE

    $ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition
    
    # # CSV FILE LOCATION
    If ($CSV_FILE){
        Select-Xml -Xml $jmeter_jmx -XPath "//CSVDataSet//*[@name='filename']" | ForEach-Object {$_.Node.InnerText = $ScriptPath + "\" + $CSV_FILE}
    }
    # # CSV VARIABLE NAMES
    If($CSV_VARS){
        Select-Xml -Xml $jmeter_jmx -XPath "//CSVDataSet//*[@name='variableNames']" | ForEach-Object {$_.Node.InnerText = $CSV_VARS} 
    }
    # # TARGET LEVEL
    If ($CONCUR_TARGET_LEVEL){
        Select-Xml -Xml $jmeter_jmx -XPath "//com.blazemeter.jmeter.threads.concurrency.ConcurrencyThreadGroup//*[@name='TargetLevel']" | ForEach-Object {$_.Node.InnerText = $CONCUR_TARGET_LEVEL} 
    }
    # # RAMP UP
    If ($RAMP_UP){
        Select-Xml -Xml $jmeter_jmx -XPath "//com.blazemeter.jmeter.threads.concurrency.ConcurrencyThreadGroup//*[@name='RampUp']" | ForEach-Object {$_.Node.InnerText = $RAMP_UP} 
    }
    # # STEPS
    If ($STEPS){
        Select-Xml -Xml $jmeter_jmx -XPath "//com.blazemeter.jmeter.threads.concurrency.ConcurrencyThreadGroup//*[@name='Steps']" | ForEach-Object {$_.Node.InnerText = $STEPS} 
    }
    # # HOLD
    If ($HOLD){
        Select-Xml -Xml $jmeter_jmx -XPath "//com.blazemeter.jmeter.threads.concurrency.ConcurrencyThreadGroup//*[@name='Hold']" | ForEach-Object {$_.Node.InnerText = $HOLD} 
    }
    # # UNITS
    If ($UNITS){
        Select-Xml -Xml $jmeter_jmx -XPath "//com.blazemeter.jmeter.threads.concurrency.ConcurrencyThreadGroup//*[@name='Unit']" | ForEach-Object {$_.Node.InnerText = $UNITS} 
    }
    
    # # DOMAIN
    If ($DOMAIN) {
        Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='HTTPSampler.domain']" | ForEach-Object {$_.Node.InnerText = $DOMAIN} 
    }
    # # PORT
    If ($PORT){
        Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='HTTPSampler.port']" | ForEach-Object {$_.Node.InnerText = $PORT} 
    }
    # # PATH
    If ($PATH){
        Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='HTTPSampler.path']" | ForEach-Object {$_.Node.InnerText = $PATH} 
    }
    # # METHOD
    If ($METHOD) {
        Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='HTTPSampler.method']" | ForEach-Object {$_.Node.InnerText = $METHOD} 
    }

    # JSON BODY
    If ($JSON_BODY){
        Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='Argument.value']" | ForEach-Object {$_.Node.InnerText = $JSON_BODY}
		Select-Xml -Xml $jmeter_jmx -XPath "//HTTPSamplerProxy//*[@name='Argument.metadata']" | ForEach-Object {$_.Node.InnerText = "="} 
    }
    # LOG FILE
    If($API_NAME){
        Select-Xml -Xml $jmeter_jmx -XPath "//*[@guiclass='SimpleDataWriter']//*[@name='filename']" | ForEach-Object {$_.Node.InnerText = "$ScriptPath\TEMP\$API_NAME" + "_results.xml" }
		Select-Xml -Xml $jmeter_jmx -XPath "//*[@guiclass='SummaryReport']//*[@name='filename']" | ForEach-Object {$_.Node.InnerText = "$ScriptPath\TEMP\" + "$API_NAME" + "_" + "$DOMAIN" + "_dashboard.csv" } 
    }
  
    $jmeter_jmx.Save("$ScriptPath\$SAVE_FILE")

    
    