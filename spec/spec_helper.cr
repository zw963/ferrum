require "spec"
require "../src/ferrum"

PROJECT_ROOT = File.expand_path("..", __DIR__)

ENV["FERRUM_NEW_WINDOW_WAIT"] ||= "0.8" if ENV["CI"]?

# puts ""
# command = Ferrum::Browser::Command.build(Ferrum::Browser::Options.new, nil)
# puts `'#{command.path}' --version`
# puts ""
