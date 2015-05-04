###########################
###  Eminom             ###
### Game Sutdio Script  ###
###########################
require "fileutils"
require_relative "locator.rb"

def gen_tp_cmd(sheet_name, png_name, in_dir)
    "\"#{Locator.TexturePacker}\" " \
     "--format cocos2d " \
     "--texture-format png "\
     "--data \"#{sheet_name}.plist\" "\
     "--algorithm MaxRects "\
     "--maxrects-heuristics Best " \
     "--size-constraints AnySize " \
      "--multipack "\
     "--pack-mode Best "\
     "--trim-mode None "\
     "--scale 1 "\
     "--sheet \"#{png_name}.png\" "\
     "--opt RGBA8888 " \
     "--dither-atkinson " \
     "--trim-sprite-names " \
     "#{in_dir}"
end

# print texturePacker

cur_path = File.absolute_path(__FILE__.encode("UTF-8"))
cur_path = cur_path.chomp(File.basename(cur_path))  #Ends with a slash

def checkDirs(opath)
    excepts = ["bgs"]
    Dir.glob("#{opath}**/") do |f|
        next if opath == f
        short = File.basename(f)
        if not excepts.include?short then
            yield short
        end
    end
end

checkDirs(cur_path){|s| 
    cmd = gen_tp_cmd s, s, s
    if not system(cmd) then
        puts "No"
        puts cmd
        puts $?
        exit
    end    
}

