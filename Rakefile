desc "run unit tests"
task :default
task :test do
  $LOAD_PATH << File.dirname(__FILE__)
  Dir.glob("test/*.rb").each do |filename|
    load filename
  end
end

desc "generate rdoc"
task :doc do
  Process.spawn 'rdoc ./*.rb'
  Process.wait
end
