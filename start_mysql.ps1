# start_mysql.ps1
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld.exe"
$dataDir = "$PSScriptRoot\mysql_data"

$running = Get-Process -Name mysqld -ErrorAction SilentlyContinue
if ($running) {
    Write-Host "MySQL is already running."
    return
}

# Dynamically generate/update my.ini with current absolute path
$myIniContent = @"
[mysqld]
port=3306
datadir="$($PSScriptRoot.Replace('\', '/'))/mysql_data"
"@
$myIniContent | Out-File -FilePath "$PSScriptRoot\my.ini" -Encoding utf8 -Force

Write-Host "Starting MySQL server in a new window..."
Start-Process -FilePath $mysqlPath -ArgumentList "--defaults-file=`"$PSScriptRoot\my.ini`""
Start-Sleep -Seconds 4

$runningNow = Get-Process -Name mysqld -ErrorAction SilentlyContinue
if ($runningNow) {
    Write-Host "MySQL server started successfully on port 3306 (Root user, NO password)."
} else {
    Write-Error "Failed to start MySQL server. Check log files in the mysql_data directory."
}
