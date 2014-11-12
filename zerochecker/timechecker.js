
//Just slice it up !
var fs = require('fs');
var assert  = require('assert');
var colors = require('colors');

function walkArray(ani){
	var limit = 0;
	for(var i=0;i<ani.length;++i){
		if( Array.isArray(ani[i])){
			limit = Math.max(limit, walkArray(ani[i]));
		} else if( typeof(ani[i])==='object'){
			limit = Math.max(limit, walkObj(ani[i]));
		}
	}
	return limit;
}

function walkObj(ani){
	var limit = 0;
	for(var i in ani){
		if('time'==i && typeof(ani[i])==='number'){
			limit = Math.max(limit, ani[i]);
			continue;
		}
		if(typeof(ani[i])==='object'){
			limit = Math.max(limit, walkObj(ani[i]));
		} else if( Array.isArray(ani[i]) ){
			limit = Math.max(limit, walkArray(ani[i]));
		}
	}
	return limit;
}

function walkAnimation(ani){
	if(Array.isArray(ani)){
		return walkArray(ani);
	}
	return walkObj(ani);
}


function processSingle(filePath, name) {
	//////
	console.log('Times for [', name.cyan, ']  ...');
	var content = require(filePath);
	var skill_pat = /^skill/i;
	var isSkill = function(name){ return skill_pat.exec(name) || 'attack' === name;};
	for(var i in content.animations){
		if (!isSkill(i)) {
			continue;
		}
		var ani = content.animations[i];
		var limit = walkAnimation(ani);
		console.log(i.yellow, ' ', limit.toString().green, '(s)');
	}
}

function isException(name){
	return 'spineboy' === name || 
		'node_modules' == name ||
		'sandoll' == name;
}

function main() {
	var files = fs.readdirSync('.');
	for (var i=0;i<files.length;++i) {
		var stat = fs.statSync(files[i]);
		if ( ! stat.isDirectory() ) {
			continue;
		}
		if ( '.'===files[i] || '..' == files[i]) {
			continue;
		}

		if (isException(files[i])) {
			continue;
		}

		var fullpath = './' + files[i] + '/skeleton.json';
		processSingle(fullpath, files[i]);
	}

	// 
	// console.log('done');
}


main();

