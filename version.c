#if defined(FUNCPROTO) || defined(__STDC__) || defined(__cplusplus) || defined(c_plusplus)
#ifndef ARGS
#define ARGS(args) args
#endif
#else
#ifndef ARGS
#define ARGS(args) (/*args*/)
#endif
#endif

#include <stdio.h>
#include "config.h"

static char *cercs_env_version = "cercs_env Version 1.0.45 rev. 13595  -- 2013-03-01 14:08:08 -0500 (Fri, 01 Mar 2013)\n";

#if defined (__INTEL_COMPILER)
//  Allow extern declarations with no prior decl
#  pragma warning (disable: 1418)
#endif
void cercs_env_print_version(){
    printf("%s",cercs_env_version);
}

