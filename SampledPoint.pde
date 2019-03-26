// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class SampledPoint {
    PVector position;
    ArrayList<SampledPoint> adjacentNodes;
    float distance;
    SampledPoint predecessor;    // for working backward through path
    SampledPoint successor;      // for working forward through path
    float scalarDistanceToSuccessor;
    PVector directionToSuccessor;
    
    SampledPoint(PVector position, float distance) {
        this.position = position;
        adjacentNodes = new ArrayList();
        this.distance = distance;
        predecessor = null;
        successor = null;
        scalarDistanceToSuccessor = 0;
        directionToSuccessor = null;
    }
}
