# require "spec"
require "spectator"
require "../src/core/**"
require "../src/ferrum"

PROJECT_ROOT = File.expand_path("..", __DIR__)

ENV["FERRUM_NEW_WINDOW_WAIT"] ||= "0.8" if ENV["CI"]?

puts ""
options = Ferrum::Browser::Options.new
command = Ferrum::Browser::Command.build(options, nil)
puts `'#{command.path}' --version`
puts ""
