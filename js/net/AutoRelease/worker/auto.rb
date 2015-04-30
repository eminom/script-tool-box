#! ruby
require_relative "conf.rb"

def doCleans
    puts "Cleans all"
    cmd = "rm -rf \"#{Conf.dest}*.apk\""
    system(cmd)
    puts cmd
    puts "done"
end

def doCopies
    puts "\n\n\n\nCopying>>\n"
    suffix = ".apk"
    Dir.glob("#{Conf.source_dir}**/*#{suffix}") do |file|
        fshort = File.basename(file)
        suf = File.extname(fshort)
        fshort = fshort.chomp(suf)
        #puts fshort

        mt = File.mtime file
        target = Conf.dest + fshort + mt.strftime("%Y%m%d_%H%M%S") + suf
        if not File.exist?(target) or File.mtime(target) < mt then
            cmd = "cp -f \"#{file}\" \"#{target}\""
            if not system(cmd) then
                puts cmd
                puts $?
            else
                puts "#{target} is published"
            end
        end
    end
    puts "copying done"
end

if ARGV.include? "--clean" then
    doCleans
    exit 0
end

#cur_path = File.absolute_path(__FILE__.encode("UTF-8"))
#cur_path = cur_path.chomp(File.basename(cur_path))

#puts "We are working under \"#{cur_path}\""
#puts Dir.pwd


#OK. We need to switch
previous_dir = Dir.pwd
Dir.chdir ENV['QQ']
#puts "Now we are working under \"#{Dir.pwd}\""
if Dir.pwd != ENV['QQ'] then    #Equals with ==
    puts "Cannot access target directory:\"#{ENV['QQ']}\""
    exit 1
end

cmd = "git pull origin master"
if not system(cmd) then
  puts "Failed to sync"
  puts $?
  exit 1
end

if not system "cocos compile -p android -m release" then
  puts "Failed to pack"
  exit 1
end
doCopies
puts "Packing done"
exit 0
