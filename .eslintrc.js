module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  extends: 'standard-with-typescript',
  overrides: [
    {
      files: ['*.ts', '*.tsx'],

      extends: [
        'plugin:@typescript-eslint/recommended',
        'plugin:@typescript-eslint/recommended-requiring-type-checking',
      ],

      parserOptions: {
        project: ['./tsconfig.json'],
      },
    },
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    'comma-dangle': ['error', 'always-multiline'],
    '@typescript-eslint/comma-dangle': ['error', 'always-multiline'],
    'import/first': 0,
    'no-multi-spaces': 0,
    'quotes': [2, 'double', { 'avoidEscape': true }],
    '@typescript-eslint/quotes': [2, 'double', { 'avoidEscape': true }],
    'space-before-function-paren': 0,
    '@typescript-eslint/space-before-function-paren': 0,
  }
}
