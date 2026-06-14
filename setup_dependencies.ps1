# setup_dependencies.ps1

Write-Host "Creating WebContent/WEB-INF/lib folder..."
$libDir = "WebContent/WEB-INF/lib"
if (-not (Test-Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir -Force
}

# 1. Download MySQL Connector/J
$mysqlJarPath = "$libDir/mysql-connector-j-8.4.0.jar"
if (-not (Test-Path $mysqlJarPath)) {
    Write-Host "Downloading MySQL Connector/J 8.4.0..."
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar" -OutFile $mysqlJarPath
    Write-Host "MySQL Connector/J downloaded successfully."
} else {
    Write-Host "MySQL Connector/J already exists."
}

# 2. Download Tomcat 9.0.91
$tomcatZip = "tomcat.zip"
$tomcatDir = "tomcat-9"
if (-not (Test-Path $tomcatDir)) {
    Write-Host "Downloading Apache Tomcat 9.0.91..."
    Invoke-WebRequest -Uri "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.zip" -OutFile $tomcatZip
    Write-Host "Extracting Apache Tomcat 9.0.91..."
    Expand-Archive -Path $tomcatZip -DestinationPath $tomcatDir
    Remove-Item -Path $tomcatZip -Force
    Write-Host "Tomcat extracted successfully."
} else {
    Write-Host "Tomcat folder already exists."
}

# 3. Copy servlet-api.jar and jsp-api.jar
Write-Host "Copying servlet-api.jar and jsp-api.jar from Tomcat to lib folder..."
$tomcatLibSrc = Get-ChildItem -Path "$tomcatDir/apache-tomcat-9.0.91/lib" -ErrorAction SilentlyContinue
if (-not $tomcatLibSrc) {
    # If the zip extracted into a slightly different nested folder
    $tomcatLibSrc = Get-ChildItem -Path "$tomcatDir/*/lib" -ErrorAction SilentlyContinue
}

if ($tomcatLibSrc) {
    Copy-Item -Path (Join-Path $tomcatLibSrc.DirectoryName "servlet-api.jar") -Destination $libDir -Force
    Copy-Item -Path (Join-Path $tomcatLibSrc.DirectoryName "jsp-api.jar") -Destination $libDir -Force
    Write-Host "Servlet and JSP APIs copied successfully."
} else {
    Write-Warning "Could not find Tomcat lib folder to copy servlet-api.jar and jsp-api.jar."
}

Write-Host "Dependencies setup completed!"
