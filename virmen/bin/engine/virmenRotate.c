#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *coord3, *coord3new, *angl;
    mwSize ncols, index;
    double c, s;
    
    ncols = mxGetN(prhs[0]);
    
    coord3 = mxGetPr(prhs[0]);
    angl = mxGetPr(prhs[1]);
        
    c = cos(-angl[0]);
    s = sin(-angl[0]);
    
    plhs[0] = mxCreateDoubleMatrix(3, ncols, mxREAL);
    coord3new = mxGetPr(plhs[0]);
    
    for ( index = 0; index < ncols; index++ ) {
        coord3new[3*index] = c*coord3[3*index] - s*coord3[3*index+1];
        coord3new[3*index+1] = s*coord3[3*index] + c*coord3[3*index+1];
        coord3new[3*index+2] = coord3[3*index+2];
    }
    
    return;
}