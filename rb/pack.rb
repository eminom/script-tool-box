

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
cmd = gen_tp_cmd "role", "role", "role"
if not system(cmd) then
    puts "No"
    puts cmd
    puts $?
    exit
end
