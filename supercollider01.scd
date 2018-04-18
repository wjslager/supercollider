/* FONT: http://patorjk.com/software/taag/#p=display&f=Roman&t=
Ward Slager 2017 */

/* ==== LINUX / OSX BOOT OPTIONS ==== */

( // Default
Server.local.options.sampleRate = 48000;
Server.local.options.memSize = 8192 * 4;
s.boot;
)

/* ==== WINDOWS BOOT OPTIONS ==== */

( // Focusrite ASIO
Server.local.options.device = "ASIO : Focusrite USB 2.0 Audio Driver";
Server.local.options.sampleRate = 48000;
Server.local.options.memSize = 8192 * 4;
s.boot;
)

( // MOTU Ultralite ASIO
Server.local.options.device = "ASIO : MOTU Audio ASIO";
Server.local.options.sampleRate = 48000;
Server.local.options.memSize = 8192 * 4;
s.boot;
)

( // MME Default
Server.local.options.device = "Built-in Audio";
Server.local.options.sampleRate = 48000;
Server.local.options.memSize = 8192 * 4;
s.boot;
)2

( // SPL Crimson ASIO
Server.local.options.device = "ASIO : Crimson ASIO driver";
Server.local.options.sampleRate = 48000;
Server.local.options.memSize = 8192 * 4;
s.boot;
)

/*
oooooooooo.   ooooooooo.   ooooo     ooo ooo        ooooo  .oooooo..o
`888'   `Y8b  `888   `Y88. `888'     `8' `88.       .888' d8P'    `Y8
.888      888  888   .d88'  888       8   888b     d'888  Y88bo.
.888      888  888ooo88P'   888       8   8 Y88. .P  888   `"Y8888o.
.888      888  888`88b.     888       8   8  `888'   888       `"Y88b
.888     d88'  888  `88b.   `88.    .8'   8    Y     888  oo     .d8P
o888bood8P'   o888o  o888o    `YbodP'    o8o        o888o 8""88888P'
*/

( // BEGIN OF SYNTHDEFS

( // SUSTAIN KICK
SynthDef(\suskick, {arg amp=1, freq=48, gate=1;
	var sine, aenv, penv, click, mix;
	aenv = EnvGen.ar(Env.asr(0.01, 1, 0.5), gate, doneAction:2);
	penv = EnvGen.ar(Env.perc(0.01, 1, 55, -20));
	click = SinOsc.ar(freq*2*EnvGen.ar(Env.perc(0.01, 0.01))) + GrayNoise.ar(0.001*penv);
	sine = SinOsc.ar(freq+penv);
	mix = sine + click;
	Out.ar([0, 1], mix*amp*aenv);
}).add;
);

// ~suskick = Synth(\suskick, [\amp, 0.3, \freq, 48]);
// ~suskick.set(\gate, 0);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // FATBOY KICK
SynthDef(\fatboy, {arg amp=0.8;
	var sig, ampenv, pitchenv;
	ampenv = EnvGen.kr(Env.adsr(0.01, 1, 0, 0, 1, -5), doneAction:2); // Env.perc(0.01, 1, 1, -5)
	pitchenv = EnvGen.kr(Env.perc(0, 0.05, 200));
	sig = SinOsc.ar(48 + pitchenv, 0, 1);
	sig = sig + SoftClipAmp.ar(sig, ampenv*2); // Softclipping voor een beetje drive
	sig = Compander.ar(sig, sig, 0.2, 1, 0.1, 0.005, 0.1, 4).softclip; // Compressie + softclipping
	sig = sig * ampenv * amp;
	DetectSilence.ar(sig, doneAction:2);
	Out.ar([0, 1], sig);
}).add;
);

// ~fatboy = Synth(\fatboy);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // Basisplok
SynthDef(\drum1, {arg amp=0.5, freq=220, verbtime=0.1, attack=0.01;
	var ampenv, noise, delay, verb, mix;
	ampenv = EnvGen.ar(Env.perc(attack, 0.2, 0.5, -10));
	noise = Fold.ar(SinOsc.ar(freq*1, 0, ampenv), -0.1, 0.1);
	delay = DelayL.ar(noise, 1, ampenv*0.15);
	verb = (noise*0.2) + FreeVerb2.ar(delay, delay, verbtime*0.5, verbtime);
	verb = Pan2.ar([verb, DelayN.ar(verb, 0.01, 0.01)], 0);
	Out.ar(0, verb*amp*2);
	DetectSilence.ar(verb, doneAction:2);
	Out.ar(4, 2*verb*ampenv*amp); // Pitch FX send
}).add;
);


// Synth(\drum1, [\freq, 140]);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // Snare
SynthDef(\snare, {arg amp=0.5, freq=96, gate=1;
	var ampenv, penv, fenv, sig;
	ampenv = EnvGen.kr(Env.asr(0, 1, 0.3), gate, doneAction:2);
	penv = EnvGen.kr(Env.perc(0, 0.02, 5));
	fenv = EnvGen.kr(Env.perc(0, 0.4, 5));
	sig = SinOsc.ar(freq*(1+penv)) + (0.2 * WhiteNoise.ar([1, 1]));
	sig = DFM1.ar(sig, freq*2*(1+(5*fenv)), 0.5);
	Out.ar(0, sig*ampenv*amp);
	Out.ar(4, 0.5*sig*ampenv*amp); // Pitch FX send
}).add;
);

// Synth(\fatboy);
// ~snare = Synth(\snare);
// ~snare.set(\gate, 0);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // Hihat
SynthDef(\hh, {arg amp=0.15;
	var ampenv, sig;
	ampenv = EnvGen.kr(Env.perc(0, 0.1), doneAction:2);
	sig = WhiteNoise.ar([1, 1]);
	Out.ar(0, sig*ampenv*amp);
	Out.ar(2, 0.2*sig*ampenv*amp);
}).add;
);

// Synth(\hh);

/*
..oooooo..o oooooo   oooo ooooo      ooo ooooooooooooo ooooo   ooooo  .oooooo..o
d8P'    `Y8  `888.   .8'  `888b.     `8' 8'   888   `8 `888'   `888' d8P'    `Y8
Y88bo.        `888. .8'    8 `88b.    8       888       888     888  Y88bo.
.`"Y8888o.     `888.8'     8   `88b.  8       888       888ooooo888   `"Y8888o.
.....`"Y88b     `888'      8     `88b.8       888       888     888       `"Y88b
oo     .d8P      888       8       `888       888       888     888  oo     .d8P
8""88888P'      o888o     o8o        `8      o888o     o888o   o888o 8""88888P'
*/

( // BASSDRONE
SynthDef(\bassdrone, {arg amp=0.5, gate=1, freq=48, drive=3, fmod=0, fmodrate=5;
	var wave1, wave2, fmlfo, ampenv, sig, filtermod;
	ampenv = EnvGen.kr(Env.asr(0.01, amp, 0.1), gate, doneAction:2);

	// FM Wave
	fmlfo = SinOsc.kr(0.5);
	wave1 = SinOsc.ar(freq*(SinOsc.ar(freq*1, 0, (fmlfo*8))+1));

	// 6x Unison Reese
	wave2 = Splay.ar(
		Pulse.ar(freq, [0.1, 0.2, 0.4, 0.6, 0.8, 0.9]
			* SinOsc.kr([0.1, 0.21, 0.43, 0.5, 0.73, 0.8], 0, 0.4, 0.1), 0.5), 0.7 );

	// Mix / Processing
	sig = (wave1*0.05) + (wave2*0.5);
	filtermod = VarSaw.kr(fmodrate, 0, 0, 1, 1);
	sig = DFM1.ar(sig, (freq*4)+(filtermod*100*fmod), 0.1, drive);

	Out.ar(0, sig*ampenv);
}).add;
);


// ~bassdrone = Synth(\bassdrone, [\amp, 0.5, \freq, 48]);
// ~bassdrone.set(\freq, 96);
// ~bassdrone.set(\freq, 48);
// ~bassdrone.set(\gate, 0);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // BASSPLUCK
SynthDef(\basspluck, {arg amp=0.5, freq=96, gate=1, filter=2, noise=0;
	var sig, ampenv;
	ampenv = EnvGen.kr(Env.adsr(0, 1, 1, 0), gate, doneAction:2);
	sig = VarSaw.ar(freq, 0, SinOsc.ar(freq*0.125, 0, 0.01, 0.1+(ampenv* -0.1)), 10).distort;
	sig = sig * SinOsc.ar(freq*0.5); // Adding a sub
	sig = sig + (0.2 * WhiteNoise.ar * noise); // Adding noise
	sig = BLowPass.ar(sig, freq*8*filter);
	Out.ar([0, 1], sig*ampenv*amp);
	Out.ar([4, 5], 0.1*sig*ampenv*amp); // Pitch FX send
}).add;
);

// ~fatboy = Synth(\fatboy);
// ~bass = Synth(\basspluck);
// ~bass.set(\freq, 96);
// ~bass.set(\gate, 0);

/*
oooooo   oooooo     oooo                          .o8
.`888.    `888.     .8'                          "888
..`888.   .8888.   .8'    .oooo.   oooo d8b  .oooo888
...`888  .8'`888. .8'    `P  )88b  `888""8P d88' `888
....`888.8'  `888.8'      .oP"888   888     888   888
.....`888'    `888'      d8(  888   888     888   888
......`8'      `8'       `Y888""8o d888b    `Y8bod88P"
*/

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

( // SUPERPULSE
SynthDef(\superpulse, {arg amp=0.5, freq=192, fmod=2000, delayfx=0.2;
	var sig, ampenv, fenv;
	ampenv = EnvGen.kr(Env.perc(0.01, 1), doneAction:2);
	fenv = EnvGen.kr(Env.perc(0.01, 0.5)) * fmod;
	sig = Splay.ar(Pulse.ar(
		freq * [0.98, 0.99, 1, 1, 1.01, 1.02],
		[0.1, 0.2, 0.4, 0.6, 0.8, 0.9]
		* SinOsc.kr([0.1, 0.21, 0.43, 0.5, 0.73, 0.8],
			0, 0.4, 0.1), 0.5), 1 );
	sig = 0.7*sig + Pulse.ar(freq*0.5, 0.5, 0.2) + Pulse.ar(freq*1.5, 0.2, 0.05);
	sig = DFM1.ar(sig, 500+fenv, 0.6, 2, 0).softclip;
	Out.ar(0, sig*ampenv*amp); // Output
	Out.ar(2, delayfx*sig*ampenv*amp); // Delay send
}).add;
);

// ~superpulse = Synth(\superpulse);
// ~delay = Synth(\delay);

( // ALARM
SynthDef(\alarm, {arg amp=0.5, freq=192, gate=1;
	var sig, ampenv, mod, modenv;
	ampenv = EnvGen.kr(Env.perc(0.01, 0.2, 1, -2), gate, doneAction:2);
	modenv = (EnvGen.kr(Env.perc(0.01, 2)))*2;
	mod = ClipNoise.ar(0.3, 0.3).lag(0.01);
	sig = SyncSaw.ar([freq*0.98, freq*1.02], freq*8*mod);
	sig = sig * mod;
	sig = Fold.ar(sig*modenv, -1, 1);
	Out.ar(0, sig*ampenv*amp);
	Out.ar(4, 0.5*sig*ampenv*amp); // Pitch FX send
}).add;
);

// ~alarm = Synth(\alarm);

( // YOY
SynthDef(\yoy, {arg amp=0.2, freq=192, gate=1;
	var sig, ampenv, modenv;
	ampenv = EnvGen.kr(Env.asr(0.1, 1, 1), gate, doneAction:2);
	modenv = EnvGen.kr(Env.perc(0, 0.1, 1, -5));
	sig = FBSineL.ar( [1, 0.5] * (modenv + 1 * 5000),);
	Out.ar(0, sig*ampenv*amp);
	Out.ar(4, 4*sig*ampenv*amp); // Pitch FX send
}).add;
);

// ~yoy = Synth(\yoy);

( // Horn
SynthDef(\horn, {arg amp=0.5, freq=96, delayfx=1;
	var sig, ampenv, phase;
	ampenv = EnvGen.kr(Env.perc(0.02, 0.3, 1, -5), doneAction:2);
	phase = Rand(0, 0.5);
	sig = Splay.ar( Pulse.ar([freq*0.99, freq*1.01], SinOsc.kr(0.5, phase, 0.4, 0.5)) );
	sig = Fold.ar(sig*2, -1, 1);
	sig = FreeVerb2.ar(sig, sig, 0, 1, 1);
	Out.ar(0, sig*ampenv*amp);
	Out.ar(2, 2*sig*ampenv*amp.lag(0.01)); // Delay send
	Out.ar(4, 0.1*sig*ampenv*amp); // Pitch FX send
}).add;
);

// Synth(\horn);

( // Lead
SynthDef(\lead, {arg amp=0.2, freq=880, gate=1;
	var sig, pwm, ampenv, fenv, vibr, vibrenv;
	ampenv = EnvGen.kr(Env.adsr(0.01, 0.2, 1, 0.2), gate, doneAction:2);
	fenv = EnvGen.kr(Env.perc(0.01, 1, 1, -5));
	pwm = SinOsc.ar(0.2, [0.1, 0.2, 0.3], 0.3, 0.3);
	vibrenv = EnvGen.kr(Env.asr(1.5, 0.125, 0.01, 5));
	vibr = SinOsc.ar(5, 0, freq*0.125*vibrenv);
	sig = Splay.ar( Pulse.ar([freq*0.997, freq, freq*1.002]+vibr, pwm) );
	sig = (sig*0.8) + Saw.ar(freq*2+vibr, 0.3);
	sig = DFM1.ar(sig, 500+(2000*fenv+(vibrenv*10000)));
	Out.ar(0, sig*ampenv*amp);
	Out.ar(2, 1*sig*ampenv*amp.lag(0.01)); // Delay send
	Out.ar(4, 0.1*sig*ampenv*amp); // Pitch FX send
}).add;
);

// Synth(\lead);

/*
oooooooooooo ooooooo  ooooo
`888'     `8  `8888    d8'
.888            Y888..8P
.888oooo8        `8888'
.888    "       .8PY888.
.888           d8'  `888b
o888o        o888o  o88888o
*/

( // ARP DELAY
SynthDef(\delay, {arg delaytime, feedback, reverb, pitchratio, gain=1;
	// delaytime=0.4, feedback=0.7, reverb=0.2, pitchratio=1, gain=1;
	var sig;
	sig = In.ar(2, 2);
	sig = sig * 2;
	sig = PingPong.ar(~delaybuffer, sig, delaytime.lag(1), feedback);
	sig = FreeVerb.ar(sig, reverb, 1);
	sig = PitchShift.ar(sig, 0.2, pitchratio.lag(0.05));
	sig = sig * gain.lag(1);
	sig = sig * 0.5;
	Out.ar(0, sig*0.5);
}).add;
);

~delaybuffer = Buffer.alloc(Server.local, 48000*2, 2);

( // HI DELAY
SynthDef(\hidelay, {arg rate;
	var sig, lfo;
	sig = In.ar(4, 2);
	lfo = LFTri.kr(0.05, 0, 2).clip(-1, 1);
	lfo = (lfo * 0.25) + 1.75;
	// lfo.lag(1).poll;
	sig = PitchShift.ar(sig, 0.5, lfo.lag(1), 0.05, 0.05);
	Out.ar(0, sig*0.5);
}).add
);

) // END OF SYNTHDEFS

/*
ooooooooooooo ooooooooo.         .o.         .oooooo.   oooo    oooo
8'   888   `8 `888   `Y88.      .888.       d8P'  `Y8b  `888   .8P'
.....888       888   .d88'     .8"888.     888           888  d8'
.....888       888ooo88P'     .8' `888.    888           88888[
.....888       888`88b.      .88ooo8888.   888           888`88b.
.....888       888  `88b.   .8'     `888.  `88b    ooo   888  `88b.
....o888o     o888o  o888o o88o     o8888o  `Y8bood8P'  o888o  o888o
*/

( // THE COMPLETE TRACK

~delaybuffer.free;
~delaybuffer = Buffer.alloc(Server.local, 48000*2, 2);
~hidelay = Synth(\hidelay);

TempoClock.default.tempo=(110/60);

~liedje = Pseq([
	Ppar([~arp01, ~delayfx], 1),
	Ppar([~arp01, ~arp01b, ~delayfx], 1),
	Ppar([~arp01, ~delayfx, ~lead01], 1), // lead
	Ppar([~arp01, ~arp01b, ~delayfx, ~lead01], 1),
	Ppar([~arp02, ~drone01, ~delayfx, ~hh02, ~lead02], 1), // sub
	Ppar([~arp02, ~arp01b, ~drone01, ~hh02, ~delayfx, ~lead02], 1),
	~delayfx02, // buildup

	Ppar([~fatboy01, ~bass01], 4), // boem 1
	Ppar([~fatboy01, ~bass01, ~plok01, ~hh01], 4),
	Ppar([~fatboy01, ~snare01, ~bass01, ~plok01, ~hh01, ~delayfx01], 3),
	Ppar([~fatboy01, ~arp03, ~hh01, ~delayfx03], 1),

	Ppar([~yoy01, ~bass02], 1), // boem 2
	Ppar([~fatboy02, ~bass02, ~alarm01, ~plok02], 3),
	Ppar([~fatboy02, ~bass02, ~alarm01, ~plok02, ~horn01], 2),
	Ppar([~fatboy02, ~bass02, ~alarm01, ~plok02, ~horn01, ~horn02], 2),
	Ppar([~fatboy02, ~bass02, ~alarm01, ~plok02, ~horn01, ~horn02, ~horn03], 4),
	Ppar([~fatboy02, ~drone02, ~horn01, ~horn02, ~horn03, ~delayfx03b], 4), // vloeibaar vibes
	Ppar([~horn01, ~horn02, ~horn03, ~delayfx03b], 4),
	Ppar([~horn02, ~horn03, ~delayfx03b], 4),
	Ppar([~fatboy02, ~yoy01], 1),
], 1);

~liedje.play();
)


/*
ooooooooo.         .o.       ooooooooooooo ooooooooooooo oooooooooooo ooooooooo.   ooooo      ooo  .oooooo..o
`888   `Y88.      .888.      8'   888   `8 8'   888   `8 `888'     `8 `888   `Y88. `888b.     `8' d8P'    `Y8
.888   .d88'     .8"888.          888           888       888          888   .d88'  8 `88b.    8  Y88bo.
.888ooo88P'     .8' `888.         888           888       888oooo8     888ooo88P'   8   `88b.  8   `"Y8888o.
.888           .88ooo8888.        888           888       888    "     888`88b.     8     `88b.8       `"Y88b
.888          .8'     `888.       888           888       888       o  888  `88b.   8       `888  oo     .d8P
o888o        o88o     o8888o     o888o         o888o     o888ooooood8 o888o  o888o o8o        `8  8""88888P'
*/

(
~delayfx = Pmono(
	\delay,
	\delaytime, 0.4,
	\dur, Pseq([16], 1),
	\feedback, 0.7,
	\reverb, 0.2,
	\pitchratio, 1,
	\gain, 1,
);

~delayfx01 = Pmono(
	\delay,
	\delaytime, 0.4,
	\dur, Pseq([4], 1),
	\feedback, 0.7,
	\reverb, 0.2,
	\pitchratio, 1,
	\gain, 1,
);

~delayfx02 = Pmono(
	\delay,
	\delaytime, Pseg([0.4, 0.1, 0.1], Pseq([16, 8], inf), 5), // Pseries(0.4, -0.01, 64),
	\dur, Pseq([1/4], inf),
	\feedback, 0.95,
	\reverb, 0.5,
	\pitchratio, Pseg([1, 1, 0.5], Pseq([16, 8], inf)),
	\gain, Pseg([1, 5, 6, 7], Pseq([8, 8, 8], inf)),
);

~delayfx02b = Pmono(
	\delay,
	\delaytime, Pseg([0.4, 0.1, 0.1], Pseq([16, 16], inf), 5), // Pseries(0.4, -0.01, 64),
	\dur, Pseq([1/4], inf),
	\feedback, 0.9,
	\reverb, 0.5,
	\pitchratio, Pseg([1, 1, 0.5], Pseq([16, 16], inf)),
	\gain, Pseg([1, 5, 6, 7], Pseq([8, 8, 16], inf)),
);

~delayfx03 = Pmono(
	\delay,
	\delaytime, 0.4,
	\dur, Pseq([4], 1),
	\feedback, 0.9,
	\reverb, 0.5,
	\pitchratio, Pseg([1, 1, 0.5], Pseq([1, 1], inf)),
	\gain, 1,
);

~delayfx03b = Pmono(
	\delay,
	\delaytime, 0.4,
	\dur, Pseq([1/4], inf),
	\feedback, 0.9,
	\reverb, 0.5,
	\pitchratio, Pseg([1, 1, 0.5], Pseq([2, 1], inf)),
	\gain, 3,
);


// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

// DROP I

~fatboy01 = Pbind(
	\instrument, \fatboy,
	\midinote, Pseq([30, \rest, \rest, \rest], 1),
	\amp, 1,
	\dur, Pseq([1/2, 1, 1/2, 2], inf),
);

~snare01 = Pbind(
	\instrument, \snare,
	\midinote, Pseq([\rest, 42] ++ Pshuf([54, 53, 54], 1), 1),
	\amp, Pseq([0.5, 0.2, 0.2, 0.2, 0.2], inf),
	\sustain, Pseq([0.5, 0.5] ++ Pwhite(0.01, 0.1, 3), inf),
	\release, 0,
	\dur, Pseq([1, 1, 1/2, 1/2, 1], inf),
);

~bass01 = Pbind(
	\instrument, \basspluck,
	\midinote, Pseq([\rest] ++ Pshuf([30, 30, 42, 45, 49], 2) ++ [42], 1),
	\amp, Pshuf([0.3, 0.5, 0.75, 0.75], inf),
	\dur, Pseq([1, Pseq([1/4], 10), 1/2], inf),
	\filter, Pwhite(2, 16),
	\noise, 0,
);

~plok01 = Pbind(
	\instrument, \drum1,
	\midinote, Pseq([\rest, 42, 42, 42, 42], 1),
	\amp, 0.9 * Pshuf([0.3, 0.3, 0.5], inf),
	\dur, Pseq([1/2, 1/4, 1/4, 1/4, 1/4], inf),
	\verbtime, Pseq([0, 0, 0.5], inf),
);

~hh01 = Pbind(
	\instrument, \hh,
	\midinote, Pseq([\rest, 10], 4),
	\amp, 0.1,
	\dur, 1/2,
);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

// DROP II

~fatboy02 = Pbind(
	\instrument, \fatboy,
	\midinote, Pseq([30, \rest], 1),
	\amp, 1,
	\dur, Pseq([1, 2], inf),
);

~alarm01 = Pbind(
	\instrument, \alarm,
	\midinote, Pseq([\rest], 1) ++ Prand([42, 54, 66], 8),
	\dur, Pseq([1], 1) ++ Pseq([1/4], 8),
	\amp, 0.8 * Prand([0.05, 0.1, 0.2], inf),
);

~bass02 = Pbind(
	\instrument, \basspluck,
	\midinote, Pseq([\rest] ++ Prand([30, 30, 42, 45, 49], 6), 1),
	\amp, Pshuf([0.3, 0.5, 0.75, 0.75], inf),
	\dur, Pseq([1, Pseq([1/3], 6) ], inf),
	\filter, Pwhite(4, 12),
	\noise, 1,
);

~plok02 = Pbind(
	\instrument, \drum1,
	\midinote, Pseq([\rest, 54, 42, 42, 54], 1),
	\amp, Prand([0.3, 0.3, 0.5], inf),
	\dur, Pseq([1/4, 1/4, 1, 3/4, 3/4], inf)
);

~yoy01 = Pbind(
	\instrument, \yoy,
	\midinote, Pseq([\rest, 42], 1),
	\amp, 0.13,
	\dur, Pseq([1, 2], inf),
);

~horn01 = Pbind(
	\instrument, \horn,
	\midinote, Pseq([42, 42], 1),
	\amp, 0.1,
	\dur, Pseq([1.5], inf),
);

~horn02 = Pbind(
	\instrument, \horn,
	\midinote, Pseq([49, 49, 49], 1),
	\amp, 0.1,
	\dur, Pseq([1], inf),
);

~horn03 = Pbind(
	\instrument, \horn,
	\midinote, Pseq([54, 54, 54, 54, 54], 1),
	\amp, 0.1,
	\dur, Pseq([0.6], inf),
);

~horn04 = Pbind(
	\instrument, \horn,
	\midinote, Pseq([66, 66, 66, 66, 66, 66], 1),
	\amp, 0.1,
	\dur, Pseq([0.5], inf),
);

~drone02 = Pbind(
	\instrument, \bassdrone,
	\midinote, Pseq([\rest, 30], 1),
	\amp, 0.3,
	// \sustain, 2,
	\dur, Pseq([1, 2], inf),
);

// ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== //

// BREAK

~hh02 = Pbind(
	\instrument, \hh,
	\midinote, Pseq([\rest, 10], 16),
	\amp, 0.05,
	\dur, 1/2,
);

~drone01 = Pbind(
	\instrument, \bassdrone,
	\midinote, Pseq([30, 33, 28, 29], 1),
	\amp, 0.3,
	\sustain, 4,
	\dur, Pseq([4], inf),
);

~arp01 = Pbind(
	\instrument, \superpulse,
	\midinote, Pseq([54, 57, 61, 64, 66, 64, 61, 57], 6) ++ ( Pseq([54, 58, 61, 65, 66, 65, 61, 58], 2) - 1),
	\legato, 0.5,
	\fmod, 250,
	\delayfx, 0.2,
	\amp, 0.7 * Prand([0.05, 0.1, 0.1, 0.2, 0.2, 0.25, 0.25, 0.3, 0.3], inf),
	\dur, 1/4,
);

~arp01b = Pbind(
	\instrument, \superpulse,
	\midinote, (7 + Pseq([54, 57, 61, 64, 66, 64, 61, 57], 6)) ++ (12 + ( Pseq([54, 58, 61, 65, 66, 65, 61, 58], 2) - 1)),
	\legato, 0.5,
	\fmod, 3000,
	\delayfx, 0.5,
	\amp, 0.25 * Prand([0.05, 0.1, 0.1, 0.2, 0.2, 0.25, 0.25, 0.3, 0.3], inf),
	\dur, 1/4,
);

~arp02 = Pbind(
	\instrument, \superpulse,
	\midinote, Pseq([54, 57, 61, 64, 66, 64, 61, 57], 6) ++ ( Pseq([54, 58, 61, 65, 66, 65, 61, 58], 2) - 1),
	\legato, 0.5,
	\fmod, Pseg([250, 5000], 16),
	\delayfx, Pseg([0.2, 1.5], 16, 10),
	\amp, 0.7 * Prand([0.05, 0.1, 0.1, 0.2, 0.2, 0.25, 0.25, 0.3, 0.3], inf),
	\dur, 1/4,
);

~arp03 = Pbind(
	\instrument, \superpulse,
	\midinote, Pseq([54, 57, 61, 64, 66, 64, 61, 57], 1) ++ (12 + Pseq([54, 57, 61, 64, 66, 64, 61, 57], 1)),
	\legato, 0.5,
	\fmod, Pseg([250, 10000], 4),
	\delayfx, 1,
	\amp, 0.7 * ( Pseq([0.3], 8) ++ Pseq([0.1], 8)),
	\dur, 1/4,
);

~lead01 = Pbind(
	\instrument, \lead,
	\midinote, (12 + Pseq([
		54, \rest, 66, 54,
		54, \rest, 57, 57,
		61, \rest, 61, \rest,
		\rest, \rest, \rest, 66,

		62, \rest, 61, \rest,
		54, \rest, \rest, \rest,
		56, 57, \rest, \rest,
		57, 59, \rest, \rest,


		54, \rest, 66, 54,
		54, \rest, 57, 57,
		61, \rest, 61, \rest,
		\rest, \rest, 62, 56,

	], 1)) ++ (11 + Pseq([
		58
	], 1)),

	\amp, 0.16,
	\dur, Pseq([1/4], 48) ++ Pseq([4], 1),
	\sustain, Pseq([1/4], 48) ++ Pseq([4], 1),
);

~lead02 = Pbind(
	\instrument, \lead,
	\midinote, (24 + Pseq([
		54, \rest, 66, 54,
		54, \rest, 57, 57,
		61, \rest, 61, \rest,
		\rest, \rest, \rest, 66,

		62, \rest, 61, \rest,
		54, \rest, \rest, \rest,
		56, 57, \rest, \rest,
		57, 59, \rest, \rest,


		54, \rest, 66, 54,
		54, \rest, 57, 57,
		61, \rest, 61, \rest,
		\rest, \rest, 62, 56,

	], 1)) ++ (23 + Pseq([
		58
	], 1)),

	\amp, 0.14,
	\dur, Pseq([1/4], 48) ++ Pseq([4], 1),
	\sustain, Pseq([1/4], 48) ++ Pseq([4], 1),
);
)