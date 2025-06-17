import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

/*
 * Boiler-plate adapted from:
 *   – Vite + React “library” template
 *   – Supabase docs: “Deploy Vite-React on Vercel”
 *   – Your existing alias pattern (`@` ➜ src/)
 */
export default defineConfig({
  plugins: [react()],

  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),          // import foo from '@/utils/foo'
    },
  },

  envPrefix: ['VITE_'],                         // only expose vars that start with VITE_

  server: {
    port: 5173,                                 // keep local port you’re used to
    strictPort: true,
  },

  build: {
    outDir: 'dist',                             // Vercel / Netlify pick this up automatically
    emptyOutDir: true,
  },

  // Optional: copy everything under /public to the root of the build
  publicDir: 'public',
});