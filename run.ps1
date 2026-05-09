param(
    [string]$HostName = "localhost",
    [int]$Port = 5432,
    [string]$User = "postgres",
    [string]$Password = "",
    [string]$PsqlPath = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlDir = Join-Path $root "sql"

if ([string]::IsNullOrWhiteSpace($PsqlPath)) {
    $psqlCommand = Get-Command psql -ErrorAction SilentlyContinue
    if ($null -ne $psqlCommand) {
        $PsqlPath = $psqlCommand.Source
    } else {
        $candidatePaths = @(
            "C:\Program Files\PostgreSQL\18\bin\psql.exe",
            "C:\Program Files\PostgreSQL\17\bin\psql.exe",
            "C:\Program Files\PostgreSQL\16\bin\psql.exe",
            "C:\Program Files\PostgreSQL\15\bin\psql.exe"
        )

        foreach ($candidate in $candidatePaths) {
            if (Test-Path -LiteralPath $candidate) {
                $PsqlPath = $candidate
                break
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($PsqlPath) -or -not (Test-Path -LiteralPath $PsqlPath)) {
    throw "No se encontro psql. Instale PostgreSQL o ejecute con -PsqlPath 'ruta\psql.exe'."
}

if ([string]::IsNullOrWhiteSpace($Password)) {
    $securePassword = Read-Host "Password para el usuario $User" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

$oldPgPassword = $env:PGPASSWORD
$env:PGPASSWORD = $Password

function Invoke-PsqlFile {
    param(
        [string]$Database,
        [string]$FilePath
    )

    Write-Host "Ejecutando $FilePath en base $Database..."
    & $PsqlPath `
        -h $HostName `
        -p $Port `
        -U $User `
        -d $Database `
        -v ON_ERROR_STOP=1 `
        -w `
        -f $FilePath

    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la ejecucion de $FilePath"
    }
}

try {
    Invoke-PsqlFile -Database "postgres" -FilePath (Join-Path $sqlDir "01_create_database.sql")
    Invoke-PsqlFile -Database "bancodb" -FilePath (Join-Path $sqlDir "02_schema.sql")
    Invoke-PsqlFile -Database "bancodb" -FilePath (Join-Path $sqlDir "03_seed_data.sql")

    Write-Host "Validando conteos esperados..."
    & $PsqlPath `
        -h $HostName `
        -p $Port `
        -U $User `
        -d "bancodb" `
        -v ON_ERROR_STOP=1 `
        -w `
        -c "SELECT 'sucursales' AS tabla, COUNT(*) AS total FROM sucursales UNION ALL SELECT 'empleados', COUNT(*) FROM empleados UNION ALL SELECT 'clientes', COUNT(*) FROM clientes UNION ALL SELECT 'tipos_cuenta', COUNT(*) FROM tipos_cuenta UNION ALL SELECT 'cuentas', COUNT(*) FROM cuentas UNION ALL SELECT 'transacciones', COUNT(*) FROM transacciones UNION ALL SELECT 'prestamos', COUNT(*) FROM prestamos ORDER BY tabla;"

    if ($LASTEXITCODE -ne 0) {
        throw "Fallo la validacion de conteos."
    }

    Invoke-PsqlFile -Database "bancodb" -FilePath (Join-Path $sqlDir "04_queries.sql")
    Write-Host "Base de datos bancodb creada y validada correctamente."
} finally {
    $env:PGPASSWORD = $oldPgPassword
}
