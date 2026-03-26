#!/bin/bash
set -e

THEME_NAME="Temaken"
PANEL_PATH="/var/www/pterodactyl"
BACKUP_VIEWS="$PANEL_PATH/resources/views"
LOCAL_THEME_PATH="$(pwd)/theme"
PUBLIC_THEME_PATH="$PANEL_PATH/public/themes/$THEME_NAME"

echo "=== Mulai Install Tema $THEME_NAME ==="

# Copy theme ke public folder
mkdir -p "$PUBLIC_THEME_PATH/css" "$PUBLIC_THEME_PATH/js" "$PUBLIC_THEME_PATH/images"
cp -r "$LOCAL_THEME_PATH/css/"* "$PUBLIC_THEME_PATH/css/"
cp -r "$LOCAL_THEME_PATH/js/"* "$PUBLIC_THEME_PATH/js/"
# Hanya copy images jika ada
if [ -d "$LOCAL_THEME_PATH/images" ] && [ "$(ls -A $LOCAL_THEME_PATH/images)" ]; then
    cp -r "$LOCAL_THEME_PATH/images/"* "$PUBLIC_THEME_PATH/images/"
fi
cp "$LOCAL_THEME_PATH/theme.json" "$PUBLIC_THEME_PATH/"

# Inject CSS/JS ke Blade views
for file in $(find "$BACKUP_VIEWS" -name "*.blade.php"); do
    if ! grep -q "$THEME_NAME/css/app.css" "$file"; then
        sed -i "/<head>/a \    <link rel=\"stylesheet\" href=\"/themes/$THEME_NAME/css/app.css\">" "$file"
    fi
    if ! grep -q "$THEME_NAME/js/app.js" "$file"; then
        sed -i "/<\/body>/i \    <script src=\"/themes/$THEME_NAME/js/app.js\"></script>" "$file"
    fi
done

# Bersihkan cache Laravel
php "$PANEL_PATH/artisan" view:clear
php "$PANEL_PATH/artisan" cache:clear
php "$PANEL_PATH/artisan" config:clear

echo "✅ Tema $THEME_NAME berhasil diinstall!"
