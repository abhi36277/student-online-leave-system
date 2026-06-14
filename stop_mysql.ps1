# stop_mysql.ps1
$running = Get-Process -Name mysqld -ErrorAction SilentlyContinue
if ($running) {
    Write-Host "Stopping MySQL server..."
    Stop-Process -Name mysqld -Force
    Write-Host "MySQL server stopped."
} else {
    Write-Host "MySQL server is not running."
}
