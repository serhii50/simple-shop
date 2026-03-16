@echo off
echo Building Tailwind CSS...
npx tailwindcss@3 -i ./assets/css/input.css -o ./assets/css/style.css --minify
echo Done!
pause
