import { defineConfig } from 'vite'

export default defineConfig({
    root: 'src',           // <-- index.html location
    build: {
        outDir: '../dist', // <-- compiled files go here
        emptyOutDir: true
    }
})
