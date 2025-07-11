// Configuration for all API keys and services
export const config = {
  // AI Service Configuration
  openai: {
    model: process.env.OPENAI_MODEL || "gpt-4o",
    maxTokens: 1000,
  },

  // Google Cloud Configuration
  gcp: {
    projectId: process.env.GOOGLE_CLOUD_PROJECT_ID || "",
    region: process.env.GCP_REGION || "us-central1",
    storageBucket: process.env.GCP_STORAGE_BUCKET || "",
  },

  // Database Configuration
  supabase: {
    url: process.env.SUPABASE_URL || "",
    anonKey: process.env.SUPABASE_ANON_KEY || "",
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || "",
  },

  // Authentication
  auth: {
    domain: process.env.AUTH0_DOMAIN || "",
    clientId: process.env.AUTH0_CLIENT_ID || "",
    clientSecret: process.env.AUTH0_CLIENT_SECRET || "",
  },

  // Analytics
  analytics: {
    googleAnalyticsId: process.env.GA_MEASUREMENT_ID || "",
    sentryDsn: process.env.SENTRY_DSN || "",
  },
}
