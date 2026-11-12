// ESLint flat config, used by `npx eslint` and by MegaLinter (see .mega-linter.yml)
const neostandard = require('neostandard')
const cypress = require('eslint-plugin-cypress')
const globals = require('globals')

module.exports = [
  {
    ignores: [
      ...neostandard.resolveIgnoresFromGitignore(),
      'coverage/**',
      'megalinter-reports/**',
      'public/**',
      'vendor/**'
    ]
  },
  ...neostandard(),
  {
    languageOptions: { globals: { ...globals.browser, ...globals.node } }
  },
  {
    files: ['**/*.cy.js', 'cypress/support/**/*.js'],
    ...cypress.configs.globals
  },
  {
    files: ['**/*_spec.js'],
    languageOptions: { globals: globals.jasmine }
  }
]
