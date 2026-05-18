import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.jsx'],
            refresh: true,
        }),
        react(),
        tailwindcss(),
    ],
    server: {
        // Forzar IPv4 127.0.0.1 (mismo host que `php artisan serve`).
        // Evita que el archivo `hot` use [::1] (IPv6) y rompa con CORS.
        host: '127.0.0.1',
        port: 5173,
        strictPort: true,
        cors: true,
        watch: {
            ignored: ['**/storage/framework/views/**'],
        },
    },
});
