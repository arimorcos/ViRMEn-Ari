#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *ptr;
    double *lptr;
    int val;
    
    ptr = mxGetPr(prhs[0]);
    val = &ptr[0];
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    lptr = mxGetPr(plhs[0]);
    lptr[0] = val;
}