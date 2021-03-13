declare name "MBdistortion";
declare author "Bart Brouns (bart@magnetophon.nl";
declare copyright "Bart Brouns";
declare version "1.1.1";
declare license "GPLv2";

import("stdfaust.lib");

MS = (checkbox("[0] mid/side
        [tooltip: When this is checked, process mid-side, otherwise process stereo]"));

freq_group(x) = (hgroup("[1] crossover frequencies", x));
  fc1 = freq_group(vslider("[1] L/LM [unit:Hz] [style:knob]
         [tooltip: Crossover frequency (Hz) separating low and  low middle frequencies]",
         120 , 20, 1000, 1)):si.smooth(0.999);
  fc2 = freq_group(vslider("[2] LM/HM [unit:Hz] [style:knob]
         [tooltip: Crossover frequency (Hz) separating low middle and high middle frequencies]",
         1000, 100, 3000, 1)):si.smooth(0.999);
  fc3 = freq_group(vslider("[3] HM/H [unit:Hz] [style:knob]
         [tooltip: Crossover frequency (Hz) separating high middle and high frequencies]",
         6000, 500, 10000, 1)):si.smooth(0.999);

bands_group(x)  = (hgroup("[2] frequency bands", x));
  low_group(x)    = bands_group(hgroup("[1] low", x));
  lowmid_group(x) = bands_group(hgroup("[2] low mid", x));
  himid_group(x)  = bands_group(hgroup("[3] high mid", x));
  high_group(x)   = bands_group(hgroup("[4] high", x));

drive1A = low_group(vslider("[1] Drive A
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive1B = low_group(vslider("[2] Drive B
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset1A = low_group(vslider("[3] Offset A
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset1B = low_group(vslider("[4] Offset B
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive2A = lowmid_group(vslider("[1] Drive A
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive2B = lowmid_group(vslider("[2] Drive B
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset2A = lowmid_group(vslider("[3] Offset A
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset2B = lowmid_group(vslider("[4] Offset B
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive3A = himid_group(vslider("[1] Drive A
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive3B = himid_group(vslider("[2] Drive B
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset3A = himid_group(vslider("[3] Offset A
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset3B = himid_group(vslider("[4] Offset B
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive4A = high_group(vslider("[1] Drive A
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
drive4B = high_group(vslider("[2] Drive B
                       [tooltip: Amount of distortion]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset4A = high_group(vslider("[3] Offset A
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);
offset4B = high_group(vslider("[4] Offset B
                       [tooltip: Brings in even harmonics]",
                       0, 0, 1, 0.01)):si.smooth(0.999);

outgain_group(x)  = (vgroup("[3] output gain", x));
drygain = outgain_group(hslider("[1] Dry gain
                       [unit:dB][tooltip: ]",
                       -144, -144, 0, 0.01)):ba.db2linear:si.smooth(0.999);
wetgain = outgain_group(hslider("[2] Wet gain
                       [unit:dB][tooltip: ]",
                       0, -144, 0, 0.01)):ba.db2linear:si.smooth(0.999);

MBdist( drive1,offset1, drive2,offset2, drive3,offset3, drive4,offset4)=
fi.filterbank(3,(fc1,fc2,fc3)):
(
  ef.cubicnl(drive4,offset4),
  ef.cubicnl(drive3,offset3),
  ef.cubicnl(drive2,offset2),
  ef.cubicnl(drive1,offset1)
) :>fi.dcblocker;

stereo2MS(MS, x,y) = (x+(MS*y)), ((MS*x) + ((MS*-2)+1)*y);
MS2stereo(MS, m,s) = ((m+(MS*s))/(MS+1)), (((MS*m) + ((MS*-2)+1)*s)/(MS+1));

MSMBdist(x,y) =
  (
    stereo2MS(MS, x,y) :
      (MBdist( drive1A,offset1A, drive2A,offset2A, drive3A,offset3A, drive4A,offset4A)*wetgain,
       MBdist( drive1B,offset1B, drive2B,offset2B, drive3B,offset3B, drive4B,offset4B)*wetgain) :
    MS2stereo(MS)
  )
  ,
  ((x:fi.filterbank(3,(fc1,fc2,fc3)):>_)*drygain,(y:fi.filterbank(3,(fc1,fc2,fc3)):>_)*drygain)
:>(_,_);

process(x,y) = MSMBdist(x,y);
