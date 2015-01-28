#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *coord3, *coord3new, *pos;
    mwSize ncols, index, row;
    
    ncols = mxGetN(prhs[0]);
    
    coord3 = mxGetPr(prhs[0]);
    pos = mxGetPr(prhs[1]);
    
    plhs[0] = mxCreateDoubleMatrix(3,ncols,mxREAL);
    coord3new = mxGetPr(plhs[0]);
        
    for ( index = 0; index < ncols; index++ ) {
        for ( row = 0; row < 3; row++ ) {
            coord3new[3*index+row] = coord3[3*index+row]-pos[row];
        }
    }
    
    return;
}