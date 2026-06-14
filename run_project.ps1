# run_project.ps1

# 1. Start MySQL if not running
Write-Host "Ensuring MySQL is running..."
$runningMysql = Get-Process -Name mysqld -ErrorAction SilentlyContinue
if (-not $runningMysql) {
    Write-Host "Starting MySQL server in a new window..."
    
    # Dynamically generate/update my.ini with current absolute path
    $myIniContent = @"
[mysqld]
port=3306
datadir="$($PSScriptRoot.Replace('\', '/'))/mysql_data"
"@
    $myIniContent | Out-File -FilePath "$PSScriptRoot\my.ini" -Encoding utf8 -Force

    Start-Process -FilePath "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld.exe" -ArgumentList "--defaults-file=`"$PSScriptRoot\my.ini`""
    Start-Sleep -Seconds 4
}

# 2. Compile Java files
Write-Host "Compiling Java files..."
powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\compile_project.ps1"

# 3. Clean and Deploy to Tomcat's ROOT app
$tomcatRoot = "$PSScriptRoot\tomcat-9\apache-tomcat-9.0.91\webapps\ROOT"
Write-Host "Deploying files to Tomcat ROOT..."

if (Test-Path $tomcatRoot) {
    # Delete existing files to ensure clean deploy
    Get-ChildItem -Path $tomcatRoot | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $tomcatRoot -Force
}

# Copy WebContent contents to Tomcat ROOT
Copy-Item -Path "$PSScriptRoot\WebContent\*" -Destination $tomcatRoot -Recurse -Force

# 4. Stop any existing Tomcat java process (if running)
Write-Host "Stopping any currently running Tomcat instance..."
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25"
$env:CATALINA_HOME = "$PSScriptRoot\tomcat-9\apache-tomcat-9.0.91"
& "$env:CATALINA_HOME\bin\shutdown.bat" 2>$null | Out-Null
Start-Sleep -Seconds 2

# 5. Start Tomcat in the foreground
Write-Host "Launching web browser at http://localhost:8080/..."
Start-Process "http://localhost:8080/"

Write-Host "Starting Apache Tomcat in this terminal..."
Write-Host "========================================================"
Write-Host "Keep this terminal open and running!"
Write-Host "To stop the web server, click here and press Ctrl + C."
Write-Host "========================================================"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25"
$env:CATALINA_HOME = "$PSScriptRoot\tomcat-9\apache-tomcat-9.0.91"
& "$env:CATALINA_HOME\bin\catalina.bat" run

Write-Host "--------------------------------------------------------"
Write-Host "Success! The application has been deployed."
Write-Host "If the web page does not load immediately, please refresh in 5 seconds."
Write-Host "--------------------------------------------------------"
