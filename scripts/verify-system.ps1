# Script PowerShell para verificar que todos los componentes estén funcionando

Write-Host "🔍 Verificando el sistema de observabilidad..." -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

function Verificar-Servicio {
    param(
        [string]$nombre,
        [string]$url,
        [int]$esperado
    )
    
    Write-Host "Verificando $nombre... " -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq $esperado) {
            Write-Host "✅ OK" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ FAIL (código: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ FAIL (no responde)" -ForegroundColor Red
        return $false
    }
}

# Verificar servicios Docker
Write-Host "📦 Verificando servicios Docker..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# Verificar servicios web
Write-Host "🌐 Verificando endpoints..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Verificar-Servicio "Course Service" "http://localhost:8001/" 200
Verificar-Servicio "Catalog Service" "http://localhost:8002/" 200
Verificar-Servicio "Jaeger UI" "http://localhost:16686" 200
Verificar-Servicio "Prometheus" "http://localhost:9090" 200
Verificar-Servicio "Grafana" "http://localhost:3000" 200
Verificar-Servicio "Kibana" "http://localhost:5601" 200
Verificar-Servicio "Elasticsearch" "http://localhost:9200" 200
Write-Host ""

# Verificar métricas del collector
Write-Host "📊 Verificando OpenTelemetry Collector..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Verificar-Servicio "OTEL Collector Metrics" "http://localhost:8889/metrics" 200
Write-Host ""

# Verificar Elasticsearch
Write-Host "📚 Verificando índices en Elasticsearch..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
try {
    $indices = Invoke-RestMethod -Uri "http://localhost:9200/_cat/indices?v" -UseBasicParsing
    Write-Host $indices
} catch {
    Write-Host "⚠️  No se pudo obtener índices" -ForegroundColor Yellow
}
Write-Host ""

# Verificar si hay logs
Write-Host "📝 Verificando logs en Elasticsearch..." -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
try {
    $count = Invoke-RestMethod -Uri "http://localhost:9200/otel-logs-*/_count" -UseBasicParsing
    Write-Host "✅ Logs encontrados: $($count.count)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No se encontraron logs. Genera tráfico primero." -ForegroundColor Yellow
}
Write-Host ""

# Resumen
Write-Host "📋 Resumen del Sistema" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host "URLs de acceso:" -ForegroundColor White
Write-Host ""
Write-Host "  🔹 Microservicios:" -ForegroundColor Cyan
Write-Host "     - Course Service:   http://localhost:8001" -ForegroundColor White
Write-Host "     - Catalog Service:  http://localhost:8002" -ForegroundColor White
Write-Host ""
Write-Host "  🔹 Observabilidad:" -ForegroundColor Cyan
Write-Host "     - Jaeger:          http://localhost:16686" -ForegroundColor White
Write-Host "     - Prometheus:      http://localhost:9090" -ForegroundColor White
Write-Host "     - Grafana:         http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "     - Kibana:          http://localhost:5601" -ForegroundColor White
Write-Host "     - Elasticsearch:   http://localhost:9200" -ForegroundColor White
Write-Host ""
Write-Host "✅ Verificación completada!" -ForegroundColor Green
