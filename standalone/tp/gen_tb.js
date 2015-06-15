


var fs = require("fs");
var path = require("path");
var current_path = __dirname;

if(process.argv.length < 3){
    throw new Error("Not enough parameter for me");
}

/*
for(var i=0;i<process.argv.length;++i){
    console.log(process.argv[i]);
}
*/
//process.exit();

function processSingle(dc, value, currentPath){
    var dirs = fs.readdirSync(currentPath);
    for(var i=0;i<dirs.length;++i){
        var full = path.join(currentPath, dirs[i]);
        //console.log(full);
        if( fs.statSync(full).isFile() ){
            if( dirs[i].match(/"*\.PNG$/i)){
                var now = dirs[i];
                var chompLen = path.extname(dirs[i]).length;
                now = now.substr(0, now.length - chompLen);
                //console.log(now);
                if(dc[now]) {
                    throw new Error("Duplicated key :"+now);
                }
                dc[now] = value;
            }
        }
    }
}

function isPassed(name){
    return name !== "bgs" && name !== ".git" && name !== "outs";
}

function main(){
    var target_path = path.join(current_path, process.argv[2]);
    if (! fs.statSync(target_path).isDirectory()){
        throw new Error("Not a directory for " + target_path);
    }
    var reverse_t = {}
    var dirs = fs.readdirSync(target_path);
    for(var i=0;i<dirs.length;++i){
        //console.log(dirs[i]);
        var full = path.join(target_path, dirs[i]);
        if( fs.statSync(full).isDirectory() && isPassed(dirs[i]) ){
            // console.log("Processing ["+dirs[i]+"]");
            processSingle(reverse_t, dirs[i], full);
        }
    }

    console.log(JSON.stringify(reverse_t));
}

// Master entry
main();
