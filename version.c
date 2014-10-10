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

static char *cercs_env_version = "cercs_env Version 1.0.52 rev. 18758  -- 2014-10-09 08:45:33 -0400 (Thu, 09 Oct 2014)\n";

#if defined (__INTEL_COMPILER)
//  Allow extern declarations with no prior decl
#  pragma warning (disable: 1418)
#endif
void cercs_env_print_version(){
    printf("%s",cercs_env_version);
}

