#!/bin/bash

# Script para verificar e instalar dependencias del checkout con Recurrente

echo "🚀 Verificando dependencias del Checkout con Recurrente..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter está instalado${NC}"

# Cambiar al directorio del proyecto
cd "$(dirname "$0")" || exit 1

# Ejecutar flutter pub get
echo ""
echo "📦 Instalando dependencias..."
flutter pub get

# Verificar si las dependencias se instalaron correctamente
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencias instaladas correctamente${NC}"
else
    echo -e "${RED}❌ Error al instalar dependencias${NC}"
    exit 1
fi

echo ""
echo "📋 Dependencias requeridas para Checkout:"
echo "  - flutter_inappwebview: ^6.0.0"
echo "  - connectivity_plus: ^6.0.0"

echo ""
echo "📁 Archivos creados:"
echo "  ✅ lib/services/checkout_service.dart"
echo "  ✅ lib/services/connectivity_service.dart"
echo "  ✅ lib/screens/checkout_screen.dart"
echo "  ✅ lib/screens/checkout_webview_screen.dart"
echo "  ✅ lib/screens/order_confirmation_screen.dart"

echo ""
echo "⚙️ Configuración necesaria:"
echo "  1. Asegúrate de que API_URL en .env esté correcta"
echo "  2. Verifica que tu backend tenga los endpoints:"
echo "     - POST /shop/cart/initialize-checkout"
echo "     - GET /shop/orders/latest"
echo "     - Webhook POST /webhooks/recurrente"

echo ""
echo "🧪 Para probar:"
echo "  1. Ejecuta: flutter run"
echo "  2. Navega al carrito"
echo "  3. Presiona 'Proceder a Pago'"
echo "  4. Completa el formulario"

echo ""
echo -e "${GREEN}✅ Setup completado${NC}"
