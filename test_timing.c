#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "cercs_env.h"

int
main()
{
    chr_time timer;
    double dtime;
    chr_timer_start(&timer);
    chr_timer_stop(&timer);
    dtime = chr_time_to_microsecs(&timer);
    printf("Start/Stop pair produce time interval of %g microsecs\n",
	   dtime);
    chr_timer_start(&timer);
    sleep(1);
    chr_timer_stop(&timer);
    dtime = chr_time_to_secs(&timer);
    printf("Approx 1 second delay produces time interval of %g secs\n",
	   dtime);
    return 0;
}
