import { defineConfig, devices } from '@playwright/test';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load .env file from the e2e directory
dotenv.config({ path: path.resolve(__dirname, '.env') });

export default defineConfig({
  testDir: './tests',
  fullyParallel: false, // Run tests sequentially within each file
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1, // Single worker to avoid parallel login conflicts
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
  ],
  timeout: 30_000,

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:8080',
    screenshot: 'off', // We take screenshots manually via helpers
    video: 'on-first-retry',
    trace: 'on-first-retry',
    navigationTimeout: 60_000,
    actionTimeout: 15_000,

    // Flutter web runs in a single viewport; use desktop size
    viewport: { width: 1280, height: 900 },
  },

  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        viewport: { width: 1280, height: 900 },
      },
    },
  ],

  // Output directory for screenshots and artifacts
  outputDir: './test-results',
});
