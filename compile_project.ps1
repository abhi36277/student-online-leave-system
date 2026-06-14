# compile_project.ps1
$classesDir = "$PSScriptRoot/WebContent/WEB-INF/classes"
if (-not (Test-Path $classesDir)) {
    New-Item -ItemType Directory -Path $classesDir -Force
}

$classpath = "$PSScriptRoot/WebContent/WEB-INF/lib/servlet-api.jar;$PSScriptRoot/WebContent/WEB-INF/lib/jsp-api.jar;$PSScriptRoot/WebContent/WEB-INF/lib/mysql-connector-j-8.4.0.jar"

# Find all Java files recursively
$javaFiles = Get-ChildItem -Path "$PSScriptRoot/src" -Filter "*.java" -Recurse | ForEach-Object { $_.FullName }

if (-not $javaFiles) {
    Write-Error "No Java source files found in src directory!"
    exit 1
}

Write-Host "Compiling Java files..."
javac -d $classesDir -cp $classpath $javaFiles

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful! Class files are placed in: $classesDir"
} else {
    Write-Error "Compilation failed!"
    exit 1
}
