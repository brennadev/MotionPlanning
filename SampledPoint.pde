// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class SampledPoint {
    PVector position;
    SampledPoint[] adjacentNodes;
    int adjacentNodeCount;
    float distance;
    SampledPoint predecessor;
    
    SampledPoint(PVector position,  float distance) {
        this.position = position;
        adjacentNodeCount = 0;
        adjacentNodes = new SampledPoint[samplePointsCount + 1];
        this.distance = distance;
        predecessor = null;
    }
    
    void addAdjacentNode(SampledPoint node) {
        adjacentNodes[adjacentNodeCount] = node;
        adjacentNodeCount++;
    }
}
