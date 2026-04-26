import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5174,
    proxy: {
      '/api/auth': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/api/admin': {
        target: 'http://localhost:8084',
        changeOrigin: true
      }
    }
  }
});
