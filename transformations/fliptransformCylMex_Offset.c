#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    mwSize ncols, index;
    double *coord3new, *coord3;
    double r, rinv, rnew, x, y, z;
    double offset, offsetInd, nRows;
    
    //define vertical offset
    offset = 10;
    
    ncols = mxGetN(prhs[0]);
    nRows = mxGetN(plhs[0]);
    plhs[0] = mxCreateDoubleMatrix(3,ncols,mxREAL);

    coord3new = mxGetPr(plhs[0]);
    coord3 = mxGetPr(prhs[0]);
    
    for ( index = 0; index < ncols; index++ ) {
        coord3new[3*index+2] = 1;
    //    r = sqrt(coord3[3*index]*coord3[3*index]+coord3[3*index+1]*coord3[3*index+1]);
    //    rnew = 1/(2.0349*r-0.98988*coord3[3*index+2]);
    //    rinv = 1/r;
    //    if ( rnew < 0 || rnew > rinv ) {
    //        rnew = rinv;
    //        coord3new[3*index+2] = 0;
    //    }
		if ( coord3[3*index] < 0 ) {
			coord3new[3*index+2] = 0;
			}
		x = coord3[3*index];
		y = coord3[3*index+1];
		z = coord3[3*index+2];

        coord3new[3*index] = -(y / sqrt( x*x + y*y ));
        coord3new[3*index+1] = -(z / sqrt( x*x + y*y + z*z ));

		//		coord3new[3*index] = ... ;
		//		coord3new[3*index+1] = rnew*coord3[3*index+1];
        
    }
    
    
    //shift rows based on vertical offset
    for ( offsetInd = 0; offsetInd < nRows; offsetInd++ ) {
        
       coord3new[3*offsetInd + 1] = coord3new[3*offsetInd + 1] + 10;
//         if ( offsetInd <= 500 ) {
//             
//             coord3new[2*offsetInd] = 0;
//         }
        
    }
    return;
}