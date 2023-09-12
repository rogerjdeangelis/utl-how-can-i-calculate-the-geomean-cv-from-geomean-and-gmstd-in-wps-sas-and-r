%let pgm=utl-how-can-i-calculate-the-geomean-cv-from-geomean-and-gmstd-in-wps-sas-and-r;

How can I calculate the Geomean CV from GeoMEAN and GMStd in wps sas and r

 Two solutions
     1. WPS R
     2. WPS SQL

 Not sure but I think the stderr is just (n-1)/n times geostd?

 All can be computed from the random variable log(x)

github
https://tinyurl.com/3d3j3k3a
https://github.com/rogerjdeangelis/utl-how-can-i-calculate-the-geomean-cv-from-geomean-and-gmstd-in-wps-sas-and-r

see
https://blogs.sas.com/content/iml/2019/10/02/geometric-mean-deviation-cv-sas.html

/*
/ |   __      ___ __  ___   _ __  _ __ ___   ___   _ __
| |   \ \ /\ / / `_ \/ __| | `_ \| `__/ _ \ / __| | `__|
| |_   \ V  V /| |_) \__ \ | |_) | | | (_) | (__  | |
|_(_)   \_/\_/ | .__/|___/ | .__/|_|  \___/ \___| |_|
               |_|         |_|
*/

%utl_submit_wps64x('
libname sd1 "d:/sd1";
%let N = 100;
data sd1.Have;
call streaminit(12345);
do i = 1 to &N;
   x = round( rand("LogNormal", 3, 0.8), 0.1);
   output;
end;
run;
libname sd1 "d:/sd1";
proc r;
export data=sd1.have r=have;
submit;
library(PKNCA);
have;
geomean(have$X);
geosd(have$X);
geocv(have$X)/100;
endsubmit;
run;quit;
');


[1] 20.21026
[1] 2.141628
[1] 0.8865714

/*___                                   _
|___ \  __      ___ __  ___   ___  __ _| |
  __) | \ \ /\ / / `_ \/ __| / __|/ _` | |
 / __/   \ V  V /| |_) \__ \ \__ \ (_| | |
|_____|   \_/\_/ | .__/|___/ |___/\__, |_|
                 |_|                 |_|
*/

%utl_submit_wps64x("
 libname sd1 'd:/sd1';
 options validvarname=any;
 proc sql;
   create
      table stats as
   select
     'geomean' as stat
     ,exp(logw) as val
   from
     (select mean(log(x)) as logw from sd1.have)
   union
     corr
   select
     'geostd'   as stat
     ,exp(logw) as val
   from
     (select std(log(x)) as logw from sd1.have)
   union
     corr
   select
     'geocv'   as stat
     ,sqrt(exp(logw**2) - 1) as val
   from
     (select std(log(x)) as logw from sd1.have)
;quit;
proc print data=stats;
run;quit;
");

The WPS System

Obs     stat        val

 1     geocv       0.8866
 2     geomean    20.2103
 3     geostd      2.1416

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
