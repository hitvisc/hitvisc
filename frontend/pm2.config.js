module.exports = {
  apps : [{
    name   : "hitvisc-api",
    script : "/app/hitvisc/front/app/api/dist/src/main.js",
    env: {
      APP_PORT: 9090,
      JWT_TOKEN_SECRET: "jwt_token_secret",
      JWT_TOKEN_EXPIRES_IN: "2h",
      DB_URL: "postgresql://hitviscadm:hitviscPasswd@localhost/hitvisc?schema=public",
      DB_SCHEMA: 'registry',
      DB_SYNC_MODELS: 'false',
      EMAIL_HOST: "smtp.yandex.ru",
      EMAIL_PORT: 465,
      EMAIL_USER: "user@yandex.ru",
      EMAIL_PASSWORD: "password",
      JWT_VERIFICATION_TOKEN_SECRET: "jwt_verification_token_secret",
      JWT_VERIFICATION_TOKEN_EXPIRATION_TIME: 21600,
      EMAIL_CONFIRMATION_URL: "http://[IP address]:8080/confirmation",
      NEW_PASSWORD_URL: "http://[IP address]:8080/new-password",
      LOGIN_URL: "http://[IP address]:8080/auth",
      CORS_ORIGIN_HOSTS: "http://[IP address]:8080", // hosts separated by ' '
      HITVISC_DATA_DIR: '/app/hitvisc/data',
      STORAGE_DIRECTORY: '/app/hitvisc/front/storage',
      UPLOADS_SETTINGS_PATH: '/app/hitvisc/front/upload_settings.conf',
      CREATE_TARGET_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_add_target.sh',
      UPDATE_TARGET_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_update_target.sh',
      DELETE_TARGET_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_archive_target.sh',
      CREATE_LIBRARY_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_add_library.sh',
      UPDATE_LIBRARY_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_update_library.sh',
      DELETE_LIBRARY_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_archive_library.sh',
      CREATE_SEARCH_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_add_search.sh',
      UPDATE_SEARCH_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_update_search.sh',
      DELETE_SEARCH_SCRIPT_PATH: '/app/hitvisc/api/hitvisc_archive_search.sh',
      UPDATE_HOST_TYPE_SCRIPT_PATH: '/app/hitvisc/main/update_host_type.sh',
      BOINC_PROJECT_NEW_HOST_URL: 'http://[IP address]/hitboinc',
      SYNC_USERS_SCRIPT_PATH: '/app/hitvisc/main/sync_user.sh',
      // SHELL_UID: 999,
    }
  },{
    name   : "hitvisc-client",
    script : "/app/hitvisc/front/app/client/.output/server/index.mjs",
    env: {
      HOST: "0.0.0.0",
      PORT: 8080,
      NUXT_PUBLIC_API_BOINCAAS_BASE_URL: "http://[IP address]:9090",
    }
  }]
}
