#!/usr/bin/env bash
# Configura el proyecto para compilar en iOS.
# Requisitos previos (ver instrucciones): flutter en PATH y cocoapods instalado.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
echo "==> Proyecto: $ROOT"

# 1) Verificaciones
command -v flutter >/dev/null || { echo "ERROR: flutter no está en el PATH. Abre una terminal nueva o ajusta el PATH."; exit 1; }
command -v pod >/dev/null || { echo "ERROR: cocoapods (pod) no está instalado. Ver instrucciones."; exit 1; }

# 2) Asegurar el archivo .env (asset obligatorio según pubspec.yaml)
if [ ! -f .env ]; then
  echo "==> Creando .env desde .env.example"
  cp .env.example .env
fi

# 3) Dependencias de Dart/Flutter
echo "==> flutter pub get"
flutter pub get

# 4) Regenerar el scaffold de iOS si falta el proyecto de Xcode
if [ ! -d ios/Runner.xcodeproj ]; then
  echo "==> Falta ios/Runner.xcodeproj — regenerando plataforma iOS (no toca tu código Dart)"
  flutter create --platforms=ios --org com.utammys .
fi

# 5) Instalar pods
echo "==> pod install"
( cd ios && pod install --repo-update )

echo ""
echo "==> Listo. Ahora puedes:"
echo "    flutter devices            # ver simuladores/dispositivos"
echo "    open -a Simulator          # abrir el simulador de iPhone"
echo "    flutter run                # compilar y ejecutar"
echo ""
echo "Para firma/distribución abre: open ios/Runner.xcworkspace"
