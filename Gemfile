require 'yaml'
config = YAML.load_file('_config.yml')
active_theme = config['theme'] || 'simple-shop-theme-mini'

source "https://rubygems.org"
gem "jekyll"

# Динамически подключаем гем-тему с GitHub 
if active_theme.start_with?("simple-shop-theme-")
  gem active_theme, github: "serhii50/#{active_theme}", branch: "main"
else
  gem active_theme
end

gem "webrick"
gem "kramdown-parser-gfm"
