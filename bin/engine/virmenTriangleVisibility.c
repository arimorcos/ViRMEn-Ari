#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *vertexArray, *outVisible;
    bool *isVisible;
    mwSize *tria, ncols, index, row;
    
    ncols = mxGetN(prhs[0]);
    
    tria = mxGetPr(prhs[0]);
    vertexArray = mxGetPr(prhs[1]);
    isVisible = mxGetPr(prhs[2]);
    
    plhs[0] = mxCreateDoubleMatrix(1,ncols,mxREAL);
    outVisible = mxGetPr(plhs[0]);
        
    for ( index = 0; index < ncols; index++ ) {
        outVisible[index] = 0;
        if (isVisible[index]==1 && (vertexArray[3*tria[3*index]+2]==1 || vertexArray[3*tria[3*index+1]+2]==1 || vertexArray[3*tria[3*index+2]+2]==1)) {
            outVisible[index] = 1;
        }
    }
    
    return;
}