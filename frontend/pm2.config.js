module.exports = {
  apps : [{
    name   : "boincaas2-api",
    script : "/app/boincaas2/api/dist/src/main.js",
    env: {
      APP_PORT: 9090,
      JWT_TOKEN_SECRET: "jwt-token-secret-with-some-random-symbols",
      JWT_TOKEN_EXPIRES_IN: "2h",
      DB_URL: "postgresql://postgres:password@localhost:5432/hitvisc",
      DB_SCHEMA: 'registry',
      DB_SYNC_MODELS: 'true',
      EMAIL_HOST: "smtp.yandex.ru",
      EMAIL_PORT: 465,
      EMAIL_USER: "emailbot@yandex.ru",
      EMAIL_PASSWORD: "emailbot-password",
      JWT_VERIFICATION_TOKEN_SECRET: "jwt-verification-token-secret",
      JWT_VERIFICATION_TOKEN_EXPIRATION_TIME: 21600,
      EMAIL_CONFIRMATION_URL: "http://localhost:8080/confirmation",
      NEW_PASSWORD_URL: "http://localhost:8080/new-password",
      LOGIN_URL: "http://localhost:8080/auth",
      CORS_ORIGIN_HOSTS: "http://localhost:8080", // hosts separated by ' '
      HITVISC_DATA_DIR: '/app/boincaas/sysdir',
      STORAGE_DIRECTORY: '/app/boincaas/storage',
      UPLOADS_SETTINGS_PATH: '/app/boincaas/upload_settings.conf',
      CREATE_TARGET_SCRIPT_PATH: '/bin/echo',
      CREATE_LIBRARY_SCRIPT_PATH: '/bin/echo',
      CREATE_SEARCH_SCRIPT_PATH: '/bin/echo',
      UPDATE_HOST_TYPE_SCRIPT_PATH: '/bin/echo',
      BOINC_PROJECT_NEW_HOST_URL: 'http://boinc-project-host-url/hitvisc',
      SYNC_USERS_SCRIPT_PATH: '/bin/echo',
    }
  },{
    name   : "boincaas2-client",
    script : "/app/boincaas2/client/.output/server/index.mjs",
    env: {
      HOST: "0.0.0.0",
      PORT: 8080,
      NUXT_PUBLIC_API_BOINCAAS_BASE_URL: "http://localhost:9090",
    }
  }]
}