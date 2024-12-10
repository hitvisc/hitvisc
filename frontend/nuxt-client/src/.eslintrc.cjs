module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
  },
  extends: ['@nuxtjs/eslint-config-typescript', 'plugin:prettier/recommended'],
  rules: {
    '@typescript-eslint/no-unused-vars': 'warn',
    'no-useless-constructor': 0,
    semi: ['error', 'always'],
    quotes: ['error', 'single'],
    'no-console': 0,
    'prettier/prettier': 0,
    'accessor-pairs': 0,
    'no-new': 0,
    //
    // Vue rules
    'vue/no-multiple-template-root': 0,
    'vue/no-setup-props-destructure': 0, // vue 3.3 supports props destructure
    'vue/no-mutating-props': 0, // cause defineProps used to v-model attrs, stays before experimental defineModel be proved in NUXT
    'vue/no-v-text-v-html-on-component': 0,
    'vue/multi-word-component-names': 0,
    'vue/no-v-html': 0,
  },
};
