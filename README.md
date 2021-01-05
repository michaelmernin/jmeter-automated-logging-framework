# jmeter-automated-framework
A powershell script:
- runs a test against each api in test_case.csv.
- generates dashboard and resonse metadata
- saves data into organized folders

 

Use python's SIMPLE-HTTP server to serve created file location: http://example:<port>

 

Service currently creates two folders, each contain the same data, but organized differently:

 

apis/ best for seeing multiple tests on one api
runs/ best for seeing status of all apis in a single run

 

Path structure:
apis/ --> path to reports <api_name>/yyyy/mm-dd/hour-min-sec/
runs/ --> path to reports yyyy/mm-dd/hour-min-sec/ {/dashboards and /responses}/<environment>}

 

Resources logged:
response.xml : request and response metadata
dashboard: shows a wealth of information, response times, success rate, error codes, etc. The graphs can be found in the charts folder. 
   

Tests can be triggered by Windows Task Scheduler to run at scheduled intervals or can be run on demand.
