#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *coord3, *z;
    mwSize ncols, index;
    
    ncols = mxGetN(prhs[0]);
    
    coord3 = mxGetPr(prhs[0]);
    
    plhs[0] = mxCreateDoubleMatrix(1,ncols,mxREAL);
    z = mxGetPr(plhs[0]);
        
    for ( index = 0; index < ncols; index++ ) {
        z[index] = sqrt(coord3[3*index]*coord3[3*index] + coord3[3*index+1]*coord3[3*index+1] + coord3[3*index+2]*coord3[3*index+2]);
    }
    
    return;
}