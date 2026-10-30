# JS and CSS lint toolchain, run by the global ESLint and Stylelint git hooks
require "json"

say "🧹 Setting up ESLint and Stylelint...", :blue

create_file "package.json", JSON.pretty_generate({ "name" => app_name, "private" => true, "type" => "module" }) + "\n"

create_file "eslint.config.js", <<~JS
  import js from "@eslint/js"
  import globals from "globals"

  export default [
    { ignores: ["vendor/**", "public/**", "tmp/**"] },
    js.configs.recommended,
    {
      languageOptions: {
        globals: globals.browser
      }
    }
  ]
JS

stylelint_config = { "extends" => [ "stylelint-config-standard" ], "ignoreFiles" => [ "vendor/**", "public/**", "tmp/**" ] }
create_file ".stylelintrc.json", JSON.pretty_generate(stylelint_config) + "\n"

append_to_file ".gitignore", "\n# npm\n/node_modules\n"

run "npm install --save-dev eslint @eslint/js globals stylelint stylelint-config-standard", abort_on_failure: true
say "  ✓ Created ESLint and Stylelint configuration", :green
