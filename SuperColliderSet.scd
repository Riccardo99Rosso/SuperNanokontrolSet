

/*
L'idea è quella di abbandonare la tastiera classica,
lavorare solo sui controlli midi, impulsi e slider.
Il synth quindi diventa un modulare non controllabile da tastiera
*/

/*Mando email per zip supercollider zucco, supercollider twitt, supercollider code, George Louis*/
s.meter;
(
var long_notes;
var high_saw, voices, little_rand_piano, altezza, i, piano_amp, loop = false, n_h;
var tempo, loop_list;
var scala, out_loop, loop_amp = 0.1, wait_time = 0.6, k, all, rev_mix = 0, total, saw_long;
var piano_scale, piano_midi_notes, piano_synth = \circle_note, cutoff_piano = 100, corretto = 0;

s.boot;
MIDIClient.init;
MIDIIn.disconnectAll;
MIDIIn.connectAll;

n_h = 1;

piano_scale = Array.fill(13, {arg i; false});
piano_midi_notes = Array.fill(13, {arg i; i + 60});
// k = Bus.audio(s, 2);

/*Semplice Synth controllabile via midi per note lunghe*/
SynthDef.new(\tri_synth, {
	arg freq_1 = 40, freq_2 = 5, amp = 0.2, amp_lfo = 0.2, cutoff = 40, rq = 0.8, rev;
	var sig, lfo, filter, out;

	/*var depth = SinOsc.kr(5).range(2, 20);*/
	lfo = SinOsc.ar(freq_2, mul: amp_lfo);
	sig = LFTri.ar(freq_1 + lfo, mul: amp);
	sig = LPF.ar(sig, cutoff);
	out = Out.ar(0, FreeVerb.ar(sig !2, mix: rev));

}).add;

SynthDef.new(\saw_synth, {
	arg freq_1 = 40, freq_2 = 5, amp = 0.2, amp_lfo = 0.2, cutoff = 40, rq = 0.8, rev;
	var sig, lfo, filter, out;

	/*var depth = SinOsc.kr(5).range(2, 20);*/
	lfo = SinOsc.ar(freq_2, mul: amp_lfo);
	sig = Saw.ar(freq_1 + lfo, mul: amp);
	sig = LPF.ar(sig, cutoff);
	out = Out.ar(0, FreeVerb.ar(sig !2, mix: rev));

}).add;
/*
tempo = TempoClock(120/60);
loop_list = [72, 80, 69, 71, 81];
i = 0;
m = true;
{
inf.do{
{
scala = (50.rrand(100)).midicps;
out = Saw.ar(loop_list[i].midicps, mul: loop_amp) * Env.perc(0, 1, 2).kr(doneAction: 2)
dup:2;
//dup:2;
}.play;
i = i + 1;
if (i == l.size) {
i = 0;
};
0.6.wait;
}}.fork(tempo);
*/

SynthDef.new(\circle_note, {
	arg freq=220, width=0.5, amp=0.15, length=1, num_harm = 20, gate = 1, rev = 0, cutoff = 100;
	var sig, env;
	env = EnvGen.ar(
		/*using release node*/
		Env.new(
			[0, 1, 1, 0],
			[0.1, 0.2, 0.1],
			[1,1,1],
			//this one
			2
		),
		//also this one
		gate,
		doneAction: 2;
	);
	sig = Blip.ar(freq, num_harm, amp);
	sig = sig * env;
	Out.ar(0, FreeVerb.ar((sig * amp) !2, mix: rev));
}).add;

SynthDef.new(\pulse, {
	arg freq=220, width=0.5, amp=0.15, length=1, num_harm = 20, cutoff = 100, gate = 1, rev = 0;
	var sig, env;
	env = EnvGen.ar(
		/*using release node*/
		Env.new(
			[0, 1, 1, 0],
			[0.1, 0.2, 0.1],
			[1,1,1],
			//this one
			2
		),
		//also this one
		gate,
		doneAction: 2;
	);
	sig = LFPulse.ar(freq, mul: amp);
	sig = LPF.ar(sig, cutoff);
	sig = sig * env;
	Out.ar(0, FreeVerb.ar((sig * amp) !2, mix: rev));
}).add;

SynthDef.new(\tri, {
	arg freq=220, width=0.5, amp=0.15, length=1, num_harm = 20, cutoff = 100, gate = 1, rev = 0;
	var sig, env;
	env = EnvGen.ar(
		/*using release node*/
		Env.new(
			[0, 1, 1, 0],
			[0.1, 0.2, 0.1],
			[1,1,1],
			//this one
			2
		),
		//also this one
		gate,
		doneAction: 2;
	);
	sig = LFTri.ar(freq, mul: amp);
	sig = LPF.ar(sig, cutoff);
	sig = sig * env;
	Out.ar(0, FreeVerb.ar((sig * amp) !2, mix: rev));
}).add;

SynthDef.new(\saw, {
	arg freq=220, width=0.5, amp=0.15, length=1, num_harm = 20, cutoff = 100, gate = 1, rev = 0;
	var sig, env;
	env = EnvGen.ar(
		/*using release node*/
		Env.new(
			[0, 1, 1, 0],
			[0.1, 0.2, 0.1],
			[1,1,1],
			//this one
			2
		),
		//also this one
		gate,
		doneAction: 2;
	);
	sig = Saw.ar(freq, mul: amp);
	sig = LPF.ar(sig, cutoff);
	sig = sig * env;
	Out.ar(0, FreeVerb.ar((sig * amp) !2, mix: rev));
}).add;

SynthDef.new(\voice, {
	arg rq = 0.01, ctrl_freq = 1, amp = 0.1, rev = 0;

	var noise  = Gendy1.ar(minfreq: 100, maxfreq: 200);
	var freq = Array.rand(36, 200, 9000)*ctrl_freq;
	var filtro = Mix(BPF.ar(noise, freq, rq));
	var out = Out.ar(0, FreeVerb.ar(filtro*amp !2, mix: rev));
}).add;
/*
z = {
all = In.ar(k, 2);
Out.ar(0, FreeVerb.ar(all, mix: ~reverb_m));
}.play(addAction: \addToTail);
*/
long_notes = Synth(\tri_synth, args: [\freq_1, 40, \freq_2, 20, \amp, 0, \amp_lfo, 0, \cutoff, 1]);
saw_long = Synth(\saw_synth, args: [\freq_1, 40, \freq_2, 20, \amp, 0, \amp_lfo, 0, \cutoff, 1]);
voices = Synth(\voice, args: [\ctrl_freq, 1, \amp, 0]);
//little_rand_piano = Synth(\circle_note, args: [\freq, 220, \amp, 0]);

//Synth(\blip);

//altezza segnale
MIDIdef.cc(\cl1, {
	arg val;
	postf("altezza nota tenuta: %\n",  30 + val * (val/4));
	long_notes.set(\freq_1, 30 + val * (val/4));
}, 0);

//cutoff segnale

MIDIdef.cc(\cl2, {
	arg val;
	postf("cutoff lfo: %\n", val * (val/4) + 5);
	long_notes.set(\cutoff, val * (val/4) + 5);
}, 16);


//volume segnale
MIDIdef.cc(\cl3, {
	arg val;
	postf("volume nota tenuta: %\n", val/170);
	long_notes.set(\amp, (val/170));
}, 1);

//ampiezza lfo
MIDIdef.cc(\cl4, {
	arg val;
	postf("ampiezza lfo: %\n", val/3);
	long_notes.set(\amp_lfo, (val * 3));
}, 17);

//clock lfo
MIDIdef.cc(\cl5, {
	arg val;
	postf("clock lfo: %\n", val/8);
	high_saw = 600;
	long_notes.set(\freq_2, val/8);
}, 2);

//volume voci
MIDIdef.cc(\cl6, {
	arg val;
	postf("volume voci: %\n", val/127);
	voices.set(\amp, (val/127));
}, 18);

//altezza voci
MIDIdef.cc(\cl7, {
	//0.00001, 0.1
	arg val;
	postf("altezza voci: %\n", val/85 + 0.5);
	postf("rq: %\n", val/1000 + 0.0001);
	voices.set(\ctrl_freq, val/85 + 0.5);
}, 3);

//altezza piano
MIDIdef.cc(\cl8, {
	//0.00001, 0.1
	arg val;
	altezza = val.midicps;
	postf("altezza piano: %\n", altezza);
	if(little_rand_piano != false) {
		little_rand_piano.set(\freq, altezza);
	};
}, 4);

//on-off piano
MIDIdef.cc(\cl9, {
	//0.00001, 0.1
	arg val;
	val.postln;
	if(val == 0, {
		little_rand_piano.set(\gate, 0);
		little_rand_piano = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		little_rand_piano = Synth.new(piano_synth, args: [\freq, altezza, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix, \cutoff, cutoff_piano]);
	});
}, 43);

//volume piano
MIDIdef.cc(\cl10, {
	arg val;
	piano_amp = val/127;
	if(little_rand_piano != false) {
		little_rand_piano.set(\amp, piano_amp);
	};
	postf("volume piano: %\n", piano_amp);
	for(0, 12,
		{
			arg i;
			if(piano_scale[i] != false) {
				piano_scale[i].set(\amp, piano_amp);
			};
	});
}, 19);

//armonici piano
MIDIdef.cc(\cl11, {
	arg val;
	if(piano_synth == \circle_note) {
		n_h = val/3;
		postf("numero di armonici piano: %\n", n_h);
		if(little_rand_piano != false) {
			little_rand_piano.set(\num_harm, n_h);
		};
		for(0, 12,
			{
				arg i;
				if(piano_scale[i] != false) {
					piano_scale[i].set(\num_harm, n_h);
				};

		});
	};
	cutoff_piano = val * (val/4) + 300;
	if((piano_synth == \pulse) || (piano_synth == \tri) || (piano_synth == \saw)){
		postf("piano pulse cutoff: %\n", cutoff_piano);
		if(little_rand_piano != false) {
			little_rand_piano.set(\cutoff, cutoff_piano);
		};
		for(0, 12,
			{
				arg i;
				if(piano_scale[i] != false) {
					piano_scale[i].set(\cutoff, cutoff_piano);
				};

		});
	};
}, 20);
/*
MIDIdef.cc(\cl12, {
arg val;
postf("volume loop: %\n", val/127);
//loop_amp = val/127;
loop_amp = 0.6;
//little_rand_piano.set(\num_harm, val/4);
}, 5);
*/
MIDIdef.cc(\cl12, {
	arg val;
	postf("reverb mix: %\n", val/127);
	rev_mix = val/127;
	if(little_rand_piano != false) {
		little_rand_piano.set(\rev, rev_mix);
	};
	voices.set(\rev, rev_mix);
	long_notes.set(\rev, rev_mix);
	saw_long.set(\rev, rev_mix);

	for(0, 12,
		{
			arg i;
			if(piano_scale[i] != false) {
				piano_scale[i].set(\rev, rev_mix);
			};
	});
}, 23);

//altezza saw
MIDIdef.cc(\cl13, {
	arg val;
	postf("altezza saw: %\n",  30 + val * (val/4));
	saw_long.set(\freq_1, 30 + val * (val/4));
}, 5);

//cutoff saw
MIDIdef.cc(\cl14, {
	arg val;
	postf("cutoff lfo saw: %\n", val * (val)/4 + 5);
	saw_long.set(\cutoff, val * (val)/4 + 5);
}, 21);

//volume saw
MIDIdef.cc(\cl15, {
	arg val;
	postf("volume saw: %\n", (val/170));
	saw_long.set(\amp, (val/170));
}, 6);

//ampiezza lfo saw
MIDIdef.cc(\cl16, {
	arg val;
	postf("ampiezza lfo saw: %\n", val/3);
	saw_long.set(\amp_lfo, (val * 3));
}, 22);

//clock lfo saw
MIDIdef.cc(\cl17, {
	arg val;
	postf("clock lfo saw: %\n", val/8);
	saw_long.set(\freq_2, val/8);
}, 7);

//Do piano
MIDIdef.cc(\cl18, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[0].set(\gate, 0);
		piano_scale[0] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[0] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[0].midicps,
			\amp, piano_amp, \cutoff, cutoff_piano,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 64);

//Do# piano
MIDIdef.cc(\cl19, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[1].set(\gate, 0);
		piano_scale[1] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[1] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[1].midicps,
			\amp, piano_amp, \cutoff, cutoff_piano,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 49);

//Re piano
MIDIdef.cc(\cl20, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[2].set(\gate, 0);
		piano_scale[2] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[2] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[2].midicps,
			\amp, piano_amp, \cutoff, cutoff_piano,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 65);

//Re# piano
MIDIdef.cc(\cl21, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[3].set(\gate, 0);
		piano_scale[3] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[3] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[3].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 50);

//Mi piano
MIDIdef.cc(\cl22, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[4].set(\gate, 0);
		piano_scale[4] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[4] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[4].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 66);

//Fa piano
MIDIdef.cc(\cl23, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[5].set(\gate, 0);
		piano_scale[5] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[5] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[5].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 67);

//Fa# piano
MIDIdef.cc(\cl24, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[6].set(\gate, 0);
		piano_scale[6] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[6] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[6].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 52);

//Sol piano
MIDIdef.cc(\cl25, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[7].set(\gate, 0);
		piano_scale[7] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[7] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[7].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 68);

//Sol# piano
MIDIdef.cc(\cl26, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[8].set(\gate, 0);
		piano_scale[8] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[8] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[8].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 53);

//La piano
MIDIdef.cc(\cl27, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[9].set(\gate, 0);
		piano_scale[9] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[9] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[9].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 69);

//La# piano
MIDIdef.cc(\cl28, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[10].set(\gate, 0);
		piano_scale[10] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[10] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[10].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 54);


//Si piano
MIDIdef.cc(\cl29, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[11].set(\gate, 0);
		piano_scale[11] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[11] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[11].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 70);

//Do alto piano
MIDIdef.cc(\cl30, {
	//0.00001, 0.1
	arg val;
	if(val == 0, {
		piano_scale[12].set(\gate, 0);
		piano_scale[12] = false;
	}, {
		postf("piano on\n");
		//little_rand_piano.free;
		piano_scale[12] = Synth.new(piano_synth, args: [\freq, piano_midi_notes[12].midicps,
			\cutoff, cutoff_piano, \amp, piano_amp,
			\num_harm, n_h, \rev, rev_mix]);
	});
}, 71);

//Panic
MIDIdef.cc(\cl31, {
	arg val;
	s.freeAll;
}, 45);

//lower octave piano
MIDIdef.cc(\cl32, {
	arg val;
	if((val != 0) && (piano_midi_notes[0] >= 12)) {
		for(0, 12, {
			arg i;
			piano_midi_notes[i] = piano_midi_notes[i] - 12;
			if(piano_scale[i] != false){
				piano_scale[i].set(\freq, piano_midi_notes[i].midicps);
			};
		});
		postf("do basso: %\n", piano_midi_notes[0]);
	};
}, 61);

//higher octave piano
MIDIdef.cc(\cl33, {
	arg val;
	if((val != 0) && (piano_midi_notes[0] <= 108)) {
		for(0, 12, {
			arg i;
			piano_midi_notes[i] = piano_midi_notes[i] + 12;
			if(piano_scale[i] != false){
				piano_scale[i].set(\freq, piano_midi_notes[i].midicps);
			};
		});
		postf("do basso: %\n", piano_midi_notes[0]);
	};
}, 62);

//piano blip
MIDIdef.cc(\cl34, {
	arg val;
	if(val != 0) {
		piano_synth = \circle_note;
		postf("piano synth: blip\n");
	};
}, 32);

//piano pulse
MIDIdef.cc(\cl35, {
	arg val;
	if(val != 0) {
		piano_synth = \pulse;
		postf("piano synth: pulse\n");
	};
}, 33);

//piano pulse
MIDIdef.cc(\cl36, {
	arg val;
	if(val != 0) {
		piano_synth = \tri;
		postf("piano synth: tri\n");
	};
}, 34);

//piano saw
MIDIdef.cc(\cl37, {
	arg val;
	if(val != 0) {
		piano_synth = \saw;
		postf("piano synth: saw\n");
	};
}, 35);

//terza sotto
MIDIdef.cc(\cl38, {
	arg val;
	if((val != 0) && (piano_midi_notes[0] >= 12)) {
		corretto = corretto - 1;
		for(0, 12, {
			arg i;
			piano_midi_notes[i] = piano_midi_notes[i] - 1;
			if(piano_scale[i] != false){
				piano_scale[i].set(\freq, piano_midi_notes[i].midicps);
			};
		});
		postf("do giusto %\n", corretto);
	};
}, 58);

//terza sotto
MIDIdef.cc(\cl39, {
	arg val;
	if((val != 0) && (piano_midi_notes[0] <= 108)) {
		corretto = corretto + 1;
		for(0, 12, {
			arg i;
			piano_midi_notes[i] = piano_midi_notes[i] + 1;
			if(piano_scale[i] != false){
				piano_scale[i].set(\freq, piano_midi_notes[i].midicps);
			};
		});
		postf("do giusto %\n", corretto);
	};
}, 59);
/*
tempo = TempoClock(120/60);
loop_list = [72, 80, 69, 71, 81].midicps;
i = 0;
m = true;
{while({m == true})
{
{
out_loop = Saw.ar(loop_list[i], mul: loop_amp) * Env.perc(0, 1, 2).kr(doneAction: 2)
dup:2;
//dup:2;
}.play;
i = i + 1;
if (i == l.size) {
i = 0;
};
wait_time.wait;
}}.fork(tempo);
*/
//loop on-off
/*
MIDIdef.cc(\cl10, {
arg val;
if(val == 127) {
if(loop == true, {loop = false},{loop = true});
postf("loop: %\n", loop);
little_rand_piano.set(\amp, piano_amp);
};
}, 44);

loop_amp = 0;
*/

)


SynthDef.new(\blip,

	{arg freq = 440, amp=0.0;

		var sig = Blip.ar(freq,20,mul:amp);
		var env = EnvGen.ar(Env.perc(0.01,0.5),doneAction:2);
		var out = Out.ar(0, sig*env !2);

}).add;


//controllo esterno

Synth(\sine)

Synth(\sine,[\freq,880 ,\amp, 0.3 ]);

Synth(\blip,[\freq,880 ,\amp, 0.3 ]);

x = Routine {

	Synth(\sine,[\freq,880 ,\amp, 0.3 ]);
	1.wait;
	Synth(\blip,[\freq,880 ,\amp, 0.3 ]);
	1.wait;
	Synth(\sine,[\freq,880 ,\amp, 0.3 ]);
	1.wait;
	Synth(\blip,[\freq,880 ,\amp, 0.3 ]);
	1.wait;
	Synth(\sine,[\freq,880 ,\amp, 0.3 ]);
	1.wait;

};

x.play;
x.reset;

)

Env.new(
			[0, 1, 1, 0],
			[0.05, 0.2, 0.05],
			[1,1,1],
			//this one
			2
		).plot;



(
space.clear;
space.pop;
)