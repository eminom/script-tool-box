
//Just slice it up !
var fs = require('fs');
var assert  = require('assert');
var eventValidators={
	movestart:function(op){
		assert( typeof(op.float) == 'number', 'must give a speed for me');
	},
	moveend:function(){},
	freezingstart:function(){},
	freezingend:function(){},
	invinciblestart:function(){},
	invincibleend:function(){},
	restingfree:function(){},
	zfinished:function(){},
	trigger:function(op){
		if ( typeof(op.int) !== 'number'){
			console.error('must be number for trigger int');
		} else if ( op.int <= 0 ){
			console.error('must be greater than zero');
		} else {
			//console.log('trigger:', op.int);
		}
	},
	starteffect:function(){}
};

var balanceCounter = {
	freezingstart:{ balance:'freezing', value:+1 },
	freezingend:{ balance:'freezing', value:-1},
	invinciblestart:{ balance:'invincible', value:+1},
	invincibleend:  { balance:'invincible', value:-1},
	movestart:      { balance:'move',       value:+1},
	moveend:        { balance:'move',       value:-1},
};

var expectingCount = {
	freezing:0,
	invincible:0,
	move:0,
};

function checkEvents(evs){
	var ok = true;
	for(var i in evs){
		var found = typeof(eventValidators[i]) != 'undefined';
		if(!found){
			console.error(i,' is not valid !');
			ok = false;
		}
	}
	return ok;
}

function processSingle(filePath) {
	//////
	console.log('processing [', filePath, ']  ...');
	var content = require(filePath);
	checkEvents(content.events);

	var skill_pat = /^skill/i;
	var isSkill = function(name){ return skill_pat.exec(name) || 'attack' === name;};
	for(var i in content.animations){
		if (!isSkill(i)) {
			continue;
		}
		var ani = content.animations[i];
		if ( !Array.isArray(ani.events) ){
			console.log('warning: no events for ', i);
			continue;
		}

		var bc = {};
		for(var k in expectingCount){
			bc[k] = 0;
		}

		//
		for(var k=0;k<ani.events.length;++k){
			var one = ani.events[k];
			//console.log(one.name);
			eventValidators[one.name](one);

			//
			var bco = balanceCounter[one.name];
			if ( bco ){
				assert( typeof(bco.balance) == 'string', 'must be string');
				assert( typeof(bco.value)   == 'number', 'must be number');
				bc[bco.balance] += bco.value;
			}
		}
		for(var k in bc){
			if( bc[k] != expectingCount[k] ){
				console.error('balancing error for ', k, bc[k]);
			}
		}
		////
	}
}

function isException(name){
	return 'spineboy' === name;
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
		processSingle(fullpath);
	}

	// 
	console.log('done');
}


main();

