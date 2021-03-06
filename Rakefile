ROOT = File.dirname __FILE__

task :default => :build

desc "Build Enginemill"
build_deps = [
    'dist/lib/apprunner.js',
    'dist/bin/deploy.sh',
    'dist/em-cli.js',
    'dist/enginemill-cli.js',
    'dist/bin/em.js',
    'dist/bin/enginemill.js',
    'dist/package.json'
]
task :build => build_deps do
    puts "Built Enginemill"
end

desc "Run Treadmill tests for Enginemill"
task :test => [:build, :setup] do
    system 'bin/runtests'
end

task :setup => 'tmp/setup.dump' do
    puts "dev environment setup done"
end

task :clean do
    rm_rf 'tmp'
    rm_rf 'node_modules'
    rm_rf 'dist'
end

file 'tmp/setup.dump' => ['dev.list', 'tmp'] do |task|
    list = File.open(task.prerequisites.first, 'r')
    list.each do |line|
        npm_install(line)
    end
    File.open(task.name, 'w') do |fd|
        fd << "done"
    end
end

directory 'tmp'
directory 'dist'
directory 'dist/lib'
directory 'dist/bin'

file 'dist/package.json' => ['package.json', 'dist'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
    Dir.chdir 'dist'
    sh 'npm install' do |ok, id|
        ok or fail "npm could not install Maestro dependencies"
    end
    Dir.chdir ROOT
end

file 'dist/lib/apprunner.js' => ['lib/apprunner.coffee', 'dist/lib'] do |task|
    brew_javascript task.prerequisites.first, task.name
end

file 'dist/bin/deploy.sh' => ['bin/deploy.sh', 'dist/bin'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

file 'dist/em-cli.js' => ['em-cli.coffee', 'dist'] do |task|
    brew_javascript task.prerequisites.first, task.name
end

file 'dist/enginemill-cli.js' => ['enginemill-cli.coffee', 'dist'] do |task|
    brew_javascript task.prerequisites.first, task.name
end

file 'dist/bin/em.js' => ['bin/em.js', 'dist/bin'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

file 'dist/bin/enginemill.js' => ['bin/enginemill.js', 'dist/bin'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

def npm_install(package)
    sh "npm install #{package}" do |ok, id|
        ok or fail "npm could not install #{package}"
    end
end

def brew_javascript(source, target, node_exec=false)
    File.open(target, 'w') do |fd|
        if node_exec
            fd << "#!/usr/bin/env node\n\n"
        end
        fd << %x[coffee -pb #{source}]
    end
end
