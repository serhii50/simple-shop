require 'yaml'
config = YAML.load_file('_config.yml')
active_theme = config['theme']

source "https://rubygems.org"
gem "jekyll"

if active_theme && active_theme.start_with?("simple-shop-theme-")
  gem active_theme, github: "serhii50/#{active_theme}", branch: "main"
elsif active_theme
  gem active_theme
end

gem "webrick"
gem "kramdown-parser-gfm"
