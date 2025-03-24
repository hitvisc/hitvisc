import 'dotenv/config';
import { config } from 'dotenv';
import * as Joi from 'joi';

const validationSchema = Joi.object({
  APP_PORT: Joi.string().required(),
  JWT_TOKEN_SECRET: Joi.string().required(),
  DB_URL: Joi.string().required(),
  DB_SCHEMA: Joi.string().required(),
  DB_SYNC_MODELS: Joi.boolean().required(),
  EMAIL_HOST: Joi.string().required(),
  EMAIL_PORT: Joi.string().required(),
  EMAIL_USER: Joi.string().required(),
  EMAIL_PASSWORD: Joi.string().required(),
  JWT_VERIFICATION_TOKEN_SECRET: Joi.string().required(),
  JWT_VERIFICATION_TOKEN_EXPIRATION_TIME: Joi.string().required(),
  EMAIL_CONFIRMATION_URL: Joi.string().required(),
  NEW_PASSWORD_URL: Joi.string().required(),
  LOGIN_URL: Joi.string().required(),
  CORS_ORIGIN_HOSTS: Joi.string().required(), // hosts separated by ' '
  HITVISC_DATA_DIR: Joi.string().required(),
  STORAGE_DIRECTORY: Joi.string().required(),
  UPLOADS_SETTINGS_PATH: Joi.string().required(),
  CREATE_TARGET_SCRIPT_PATH: Joi.string().required(),
  UPDATE_TARGET_SCRIPT_PATH: Joi.string().required(),
  DELETE_TARGET_SCRIPT_PATH: Joi.string().required(),
  CREATE_LIBRARY_SCRIPT_PATH: Joi.string().required(),
  UPDATE_LIBRARY_SCRIPT_PATH: Joi.string().required(),
  DELETE_LIBRARY_SCRIPT_PATH: Joi.string().required(),
  CREATE_SEARCH_SCRIPT_PATH: Joi.string().required(),
  UPDATE_SEARCH_SCRIPT_PATH: Joi.string().required(),
  DELETE_SEARCH_SCRIPT_PATH: Joi.string().required(),
  UPDATE_HOST_TYPE_SCRIPT_PATH: Joi.string().required(),
  BOINC_PROJECT_NEW_HOST_URL: Joi.string().required(),
  SYNC_USERS_SCRIPT_PATH: Joi.string().required(),
});

const result = validationSchema.validate(process.env, { stripUnknown: true });
if (result.error) {
  throw new Error(`Invalid config: ${result.error.message}`);
}

config({
  path: process.env.UPLOADS_SETTINGS_PATH,
});
