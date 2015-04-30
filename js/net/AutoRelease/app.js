

var path = require("path");
var express = require("express");
var fs = require("fs");
var spawn = require("child_process").spawn;
var app = express();
var shared = path.resolve(__dirname, "./public");

app.use(express.static(shared));

String.prototype.endsWith = function(that){
    return this.substr(this.length - that.length, that.length) === that;
};

g_isCompiling = false;

app.get("/compile", function(req, res){
    if(g_isCompiling){
        res.writeHead(500, {"Content-Type":"text/html"});
        res.write("<h3>Server is busy compiling</h3>");
        res.write("<a href=\"/\">View the publishes</a>");
        return;
    }

    g_isCompiling = true;
    // And do the work
    //var exec = "C:/Program Files (x86)/CMake/bin/cmake-gui.exe";
    var exec = "ruby";
    var path = "f:/Stuff/Ark/ChaseGame/frameworks/cocos2d-x/tools/cocos2d-console/bin/auto.rb";
    var worker = spawn(exec, [path]);
    worker.stdout.on("data", function(data){
        process.stdout.write(data.toString("utf-8"));
    });
    worker.on("close", function(code, signal){
        console.log("child process terminated due to signal " + signal);
        console.log("exit code: " + code);
        if(0==code){
            res.writeHead(200, {"Content-Type":"text/html"});
            res.write("<h3>Built sucess on " + (new Date().toString("utf-8")) + " </h3>");
            res.write("<a href=\"/\">View the latest published</a>");
            res.end();
        } else {
            console.error("Error!");
            res.writeHead(500, {"Content-Type":"text/html"});
            res.write("<h3>" + "Failed to pack it up, connect the server maintainer please".toUpperCase() +"</h3>");
            res.write("<a href=\"/\">View the latest published</a>");
            res.end();
        }
        g_isCompiling = false;
    });
});

app.get("/", function(req, res){
    fs.readdir(shared, function(err, files){
        if(err){
            res.writeHead(500, {"Content-Type":"text/plain"});
            res.write("Cannot access to this directory");
            res.end();
            return;
        }
        res.writeHead(200, {"Content-Type":"text/html"});
        res.write('<a href="/compile">Compile new APK </a><br/><br/>');
        for(var i=files.length-1;i>=0;--i){
            if( ! files[i].endsWith(".apk")){
                continue;
            }
            var ent = "/" + files[i];
            res.write("<a href=\"");
            res.write(ent);
            res.write("\">");
            res.write(files[i]);
            res.write("</a>");
            res.write("<br/>");
        }
        res.end();
    });
});

app.listen(8080, function(){
    console.log("Server is tarting");
});