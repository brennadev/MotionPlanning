// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Matrix {
     int nodeCount;
    
     float[][] matrix;
     
     float get(int x, int y) {
         return matrix[x][y];
     }
     
     void set(int x, int y, float value) {
         matrix[x][y] = value;
     }
     
     Matrix(int nodeCount) {
         matrix = new float[nodeCount][nodeCount];
         this.nodeCount = nodeCount;
     }
     
     void enlarge(int newNodeCount) {
         // temporarily store values elsewhere
         float[][] temp = new float[nodeCount][nodeCount];
         
         for(int i = 0; i < nodeCount; i++) {
             for(int j = 0; j < nodeCount; j++) {
                 temp[i][j] = matrix[i][j];
             }
         }
         
         // make the original matrix bigger
         matrix = new float[newNodeCount][newNodeCount];
         
         // copy back to the original matrix that now has more space
         for(int i = 0; i < nodeCount; i++) {
             for(int j = 0; j < nodeCount; j++) {
                 matrix[i][j] = temp[i][j];
             }
         }
         
         nodeCount = newNodeCount;
     }
}
