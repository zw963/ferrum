require "spec"
require "../src/ferrum"

PROJECT_ROOT = File.expand_path("..", __dir__)

ENV["FERRUM_NEW_WINDOW_WAIT"] ||= "0.8" if ENV["CI"]?
