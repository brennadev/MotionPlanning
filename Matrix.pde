// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Matrix {
     float[][] matrix;
     
     float get(int x, int y) {
         return matrix[x][y];
     }
     
     void set(int x, int y, float value) {
         matrix[x][y] = value;
     }
     
     Matrix(int nodeCount) {
         matrix = new float[nodeCount][nodeCount];
     }
}
