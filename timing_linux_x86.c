#include "config.h"
#include "stdlib.h"
#include "cercs_env.h"

#include <sys/time.h>
#include <stdio.h>
#include <string.h>

typedef union rdtsc_union {
    long long t;
    struct {
	int low;
	int high;
    } ints;
} *rdtsc_time;

extern void
chr_get_time( chr_time *time)
{
    rdtsc_time t = (rdtsc_time) time;
    __asm__ __volatile__ ("rdtsc" : "=a" (t->ints.low), "=d" (t->ints.high));
}

static int
get_resolution()
{
    register int tick1;
    register int tick2;
    int junk;
    __asm__ __volatile__ ("rdtsc" : "=a" (tick1), "=d" (junk));
    __asm__ __volatile__ ("rdtsc" : "=a" (tick2), "=d" (junk));
    return tick2 - tick1;
}

extern void
chr_timer_start( chr_time *time)
{
    chr_get_time(time);
}

extern void
chr_timer_stop( chr_time *time)
{
    long long now;
    long long duration;

    chr_get_time((chr_time*)&now);
    chr_timer_diff((chr_time*)&duration, (chr_time*)&now, time);
    ((rdtsc_time) time)->t = duration;
}

extern int
chr_timer_eq_zero (chr_time *time)
{
    struct rdtsc_time *t = (struct rdtsc_time *) time; 
    return (((rdtsc_time)t)->t == 0);
}

extern void
chr_timer_diff( chr_time *diff, chr_time *src1, chr_time *src2)
{
    long long d;
    rdtsc_time s1 = (rdtsc_time)src1;
    rdtsc_time s2 = (rdtsc_time)src2;
    d = s1->t - s2->t;
    ((rdtsc_time)diff)->t = d;
}

extern void
chr_timer_sum( chr_time *sum, chr_time *src1, chr_time *src2)
{
    long long s;
    rdtsc_time s1 = (rdtsc_time)src1;
    rdtsc_time s2 = (rdtsc_time)src2;
    s = s1->t + s2->t;
    ((rdtsc_time)sum)->t = s;
}


static double clock_frequency = 0.0;

static void
frequency_init()
{
    FILE *f;
    char line[128];
    if (clock_frequency == 0.0) {
	clock_frequency = -1.0;
	f = fopen("/proc/cpuinfo", "r");
	if (!f) return;

	while(fgets(line, sizeof(line), f)) {
	    if (strncasecmp(line, "cpu mhz", 7) == 0) {
		char *colon = strchr(line, ':');
		double mhz;
		colon++;
		if (sscanf(colon, "%lf", &mhz) == 1) {
		    clock_frequency = mhz * 1000000.0 ;
		    fclose(f);
		    return;
		}
	    }
	}
	fclose(f);
    }
}

extern double
chr_time_to_secs(chr_time *time)
{
    double ticks = (double) (*(long long *)time);
    if (clock_frequency == 0.0) {
	frequency_init();
    }
    return ticks / clock_frequency;
}

extern double
chr_time_to_millisecs(chr_time *time)
{
    return chr_time_to_secs(time) * 1000.0;
}

extern double
chr_time_to_microsecs(chr_time *time)
{
    return chr_time_to_secs(time) * 1000000.0;
}

extern double
chr_time_to_nanosecs(chr_time *time)
{
    return chr_time_to_secs(time) * 1000000000.0;
}

extern double
chr_approx_resolution()
{
    long long res = get_resolution();
    int i;
    for (i=0; i < 5; i++) {
	if ((res < 0) || (res > 1024)) {
	    res = get_resolution();
	}
    }
    if (clock_frequency == 0.0) {
	frequency_init();
    }
    return chr_time_to_secs(&res);
}
