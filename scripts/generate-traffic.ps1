# Script PowerShell para generar tráfico en los microservicios

Write-Host "🚀 Generando tráfico en los microservicios..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$TOTAL_REQUESTS = 0

function Hacer-Solicitud {
    param(
        [string]$url,
        [string]$descripcion
    )
    
    Write-Host "📡 $descripcion" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        Write-Host "   ✅ OK (200)" -ForegroundColor Green
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.Value__
        Write-Host "   ❌ Error ($statusCode)" -ForegroundColor Red
    }
    
    $script:TOTAL_REQUESTS++
    Start-Sleep -Milliseconds 500
}

Write-Host "🔄 Generando tráfico normal..." -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow
Write-Host ""

for ($i = 1; $i -le 10; $i++) {
    Write-Host "Iteración $i de 10:" -ForegroundColor Cyan
    Hacer-Solicitud "http://localhost:8002/" "Catalog Home"
    Hacer-Solicitud "http://localhost:8002/catalog" "Lista de Cursos (via Catalog)"
    Hacer-Solicitud "http://localhost:8002/firstcourse" "Primer Curso (via Catalog)"
    Hacer-Solicitud "http://localhost:8001/" "Course App Home"
    Hacer-Solicitud "http://localhost:8001/courses" "Lista de Cursos (directo)"
    Write-Host ""
}

Write-Host ""
Write-Host "⚠️  Generando algunos errores (para logs)..." -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow
Write-Host ""

for ($i = 1; $i -le 5; $i++) {
    Write-Host "Generando error $i de 5:" -ForegroundColor Cyan
    Hacer-Solicitud "http://localhost:8002/nonexistent" "Endpoint inexistente"
    Hacer-Solicitud "http://localhost:8001/999999" "Curso inexistente"
    Write-Host ""
}

Write-Host ""
Write-Host "📊 Resumen:" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Total de solicitudes: $TOTAL_REQUESTS" -ForegroundColor White
Write-Host ""
Write-Host "✅ Tráfico generado exitosamente!" -ForegroundColor Green
