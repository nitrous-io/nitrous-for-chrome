require 'rubygems'
require 'bundler'
require 'logger'
require 'fileutils'
require 'json'

Bundler.require

ROOT_DIR    = File.expand_path(File.dirname(__FILE__))
LOGGER      = Logger.new(STDOUT)
BUNDLES     = %w( manifest.json application.css application.js )
BUILD_DIR   = "build"
SOURCE_DIR  = "src/"
VENDOR_DIR  = "vendor/"

task :advertise_target do
  ENV['TARGET'] ||= 'development'
  puts "Building #{ENV['TARGET']} release...\n\n"
end

task :compile do
  puts 'Compiling assets'

  sprockets = Sprockets::Environment.new(ROOT_DIR) do |env|
    env.logger = LOGGER

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
  sprockets.append_path File.join(ROOT_DIR, VENDOR_DIR)

  target = ENV['TARGET']

  BUNDLES.each do |bundle|
    asset = sprockets.find_asset(bundle)
    prefix = asset.pathname.to_s.split('/')[-2]

    if prefix == 'src'
      prefix = ''
    end

    FileUtils.mkpath File.join(BUILD_DIR, target, prefix)
    asset.write_to File.join(BUILD_DIR, target, prefix, bundle)
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
  ['icons',
   'images',
   'background.js',
   'index.html'
  ].each do |resource|
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
