
def getScriptDir
    dir = File.absolute_path(__FILE__.encode("UTF-8"))
    dir = dir.chomp(File.basename(dir))
    dir
end

def pack_pngs(dir, array)
    for i in array do 
        #puts i
        f = "#{dir}/#{i}.png"
        puts f
    end
end

#puts getScriptDir  # Test OK

packins = ["Doraemon", 
    "FlashMan", 
    "Franken",
    "Long",
    "Mario",
    "Monk",
    "Mushroom",
    "Naruto",
    "Ninja_R",
    "Warrior",
    "Zombie"
]

pack_pngs("#{getScriptDir}tex", packins)