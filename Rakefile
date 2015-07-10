require 'rubygems'
require 'bundler'
require 'logger'
require 'fileutils'
require 'json'

Bundler.require

ROOT_DIR    = File.expand_path(File.dirname(__FILE__))
LOGGER      = Logger.new(STDOUT)
BUILD_DIR   = "build"
SOURCE_DIR  = "src/"
VENDOR_DIR  = "vendor/"
BUNDLES     = %w(
  manifest.json
  application.css
  application.js
  background.js
  index.html
  injections/dashboard.css
)

task :advertise_target do
  ENV['TARGET'] ||= 'development'
  puts "Building #{ENV['TARGET']} release...\n\n"
end

task :compile do
  puts 'Compiling assets'

  sprockets = Sprockets::Environment.new(ROOT_DIR) do |env|
    env.logger = LOGGER

    env.register_engine '.slim', Slim::Template

    if ENV['TARGET'] == 'production'
      env.js_compressor = Closure::Compiler.new
      env.css_compressor = YUI::CssCompressor.new
    else
      env.cache = Sprockets::Cache::FileStore.new("tmp/sprockets/#{ENV['TARGET']}")
    end
  end

  sprockets.context_class.class_eval do
    def config
      config_file = File.join(ROOT_DIR, 'config.json')
      JSON.parse(IO.read(config_file)).fetch(ENV['TARGET']) do |t|
        raise "Cannot find configuration for target - #{t}.\nYou can define it in config.json."
      end
    end
  end

  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR)
  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR, 'javascripts')
  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR, 'stylesheets')
  sprockets.append_path File.join(ROOT_DIR, VENDOR_DIR, 'javascripts')
  sprockets.append_path File.join(ROOT_DIR, VENDOR_DIR, 'stylesheets')

  target = ENV['TARGET']

  root = Pathname.new(sprockets.root)

  BUNDLES.each do |bundle|
    asset = sprockets.find_asset(bundle)
    if asset.nil?
      puts "ERROR: #{bundle} not found!"
      exit(1)
    end
    comps = asset.pathname.relative_path_from(root).to_s.split('/')
    comps.shift if comps[0] == 'src'
    pn = Pathname.new(File.join(comps))
    FileUtils.mkpath File.join(BUILD_DIR, target, pn.dirname)
    asset.write_to File.join(BUILD_DIR, target, pn.dirname, Pathname.new(bundle).basename.to_s)
  end

  puts 'Compiled assets'
end

task :clean do
  puts "Cleaning..."
  system "rm -rf build/'#{ENV['TARGET']}'"
end

desc 'clean all'
task :clean_all do
  puts "Cleaning..."
  system "rm -rf build/*"
  system "rm -rf tmp/*"
end

task :build => [:advertise_target, :clean, :compile] do
  target = ENV['TARGET']

  compiled_dir = File.join BUILD_DIR, target
  # copy other resources
  %w(
    icons
    images
    fonts
  ).each do |resource|
    cmd = "cp -r #{File.join SOURCE_DIR, resource} #{compiled_dir}"
    puts cmd
    system cmd
  end

  if ENV['TARGET'] == 'production'
    filename = "NitrousProPackagedApp-#{ENV['TARGET']}-#{load_config['app_version']}"
    system "cd #{compiled_dir}; zip -r ../'#{filename}'.zip *"

    puts "=> build/#{ENV['TARGET']}/#{filename}.zip"
  end
  puts 'DONE!'
end

%w(development staging production).each do |target|
  desc "build for #{target}"
  task target do
    ENV['TARGET'] = target
    Rake::Task["build"].invoke
  end
end

task :default => :build

def load_config
  require 'json'
  if json = JSON.load(File.read('config.json'))
    json[ENV['TARGET']]
  end
end
