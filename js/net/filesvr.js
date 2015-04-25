var path = require('path');
var express = require('express');
var fs = require('fs');


// Start
var app = express();
var shared = path.resolve(__dirname,'./public');

app.use(express.static(shared))

app.get('/', function(req,res){
    fs.readdir(shared, function(err, files){
        if(err){
            res.writeHead(500,{'Content-Type':'text/plain'});
            res.write('cannot access to this directory.');
            res.end();
            return;
        }
        
        res.writeHead(200, {'Content-Type':'text/html'});
        for(var i=files.length-1;i>=0;--i){
            var entry = '/' + files[i];
            res.write('<a href="');
            res.write(entry);
            res.write('">');
            res.write( files[i] );
            res.write('</a>');
            res.write('<br/>');
        }
        res.end();
    });
});

app.listen(5000,function(){console.log('server is on');});