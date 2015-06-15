###########################
###  Eminom             ###
### Game Sutdio Script  ###
###########################
require "fileutils"
require_relative "locator.rb"

def gen_tp_cmd(sheet_name, png_name, in_dir, out_dir)
    "\"#{Locator.TexturePacker}\" " \
     "--format cocos2d " \
     "--texture-format png "\
     "--data \"#{out_dir}/#{sheet_name}.plist\" "\
     "--algorithm MaxRects "\
     "--maxrects-heuristics Best " \
     "--size-constraints AnySize " \
      "--multipack "\
     "--pack-mode Best "\
     "--trim-mode None "\
     "--scale 1 "\
     "--sheet \"#{out_dir}/#{png_name}.png\" "\
     "--opt RGBA8888 " \
     "--dither-atkinson " \
     "--trim-sprite-names " \
     "#{in_dir}"
end

# print texturePacker

$cur_path = File.absolute_path(__FILE__.encode("UTF-8"))
$cur_path = $cur_path.chomp(File.basename($cur_path))  #Ends with a slash

def ensureDir(dir)
    td = dir
    if File.directory? td then
        #puts "Dir"  -- Alright.
    elsif File.file? td then
        puts "\"#{td}\" is a file"
        puts "Error"
        exit
    else
        #puts "None"
        FileUtils.mkdir_p td
    end

    if not File.directory? td then
        puts "still no "
        exit
    end
    puts "#{dir} IS ENSURED"
end

def checkDirs(opath, outs)
    ensureDir "#{opath}#{outs}"
    excepts = [".git", "bgs"] + [outs]
    Dir.glob("#{opath}**/") do |f|
        #print "#:", f, "   ", opath, "\n"
        next if opath == f
        short = File.basename(f)
        if not excepts.include?short then
            yield short
        end
    end
end

def main(work_dir)
    next_dir = $cur_path + work_dir
    #print next_dir
    if not File.directory? next_dir then
        puts "#{next_dir} is not a valid directory"
        exit
    end
    if not Dir.chdir next_dir then
        puts "Error"
        exit
    end
    puts "Processing #{Dir.pwd} >>>"
    checkDirs(next_dir, "outs"){|s| 
        cmd = gen_tp_cmd s, s, s, "outs"
        if not system(cmd) then
            puts "No"
            puts cmd
            puts $?
            exit
        end    
    }
end

if ARGV.length <= 0 then
    puts "Not enough parameter for me"
    exit
end
main(ARGV[0]+"/")

