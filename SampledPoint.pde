// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class SampledPoint {
    PVector position;
    ArrayList<Integer> adjacentNodes;
    //SampledPoint predecessor;    // for working backward through path
    SampledPoint successor;      // for working forward through path
    
    float scalarDistanceToSuccessor;
    PVector directionToSuccessor;
    
    SampledPoint(PVector position) {
        this.position = position;
        adjacentNodes = new ArrayList();
        //predecessor = null;
        successor = null;
        
        scalarDistanceToSuccessor = 0;
        directionToSuccessor = null;
    } 
}
