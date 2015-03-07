
// Xor cipher by eminem
//~ May.2o14

var fs = require('fs');
var path = require('path');
var pat = /\.lua$/;

var key1 = new Buffer('00000000000000000000000');
var key2 = new Buffer('1111111');
var key3 = new Buffer('22222');


function walkDir(path, handler){
	fs.readdir(path, function(err, files){
		if(err){
			console.error('error dir reading');
		} else {
			files.forEach(function(item){
				var full = path + '/' + item;
				fs.stat(full, function(err1, stats){
					if(err1){
						console.error('state error');
					} else {
						if( stats.isDirectory()){
							walkDir(full, handler);
						} else{
							handler(full);
						}
					}
				});
			});
		}
	});
}

function transformat(buffer, k){
	var len = buffer.length;
	var klen = k.length;
	var p = 0;
	for(var i=0;i<len;++i){
		buffer[i] = buffer[i] ^ k[p];
		p = (p+1) % klen;
	}
}

function processFile(fileName){
	if( ! pat.exec(fileName) ){
		return;
	}

	//console.log('processing ' + fileName);
	fs.readFile(fileName, function(err, data){
		if(err){
			console.error('reading error');
		} else {
			var pt = 0;
			transformat(data, key1);
			transformat(data, key2);
			transformat(data, key3);

			fs.writeFile(fileName, data, function(err){
				if(err){
					console.error('error writing ' + fileName);
				} else {
					console.log(fileName + ' ... done');
				}
			});
		}
	});
}

//Starting here.

var rootStart = path.join(__dirname, 'Resources');
//console.log(rootStart);
walkDir(rootStart, processFile);
