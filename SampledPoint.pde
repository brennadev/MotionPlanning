// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

enum NodeColor {
    white,
    gray, 
    black
}

class SampledPoint {
    PVector position;
    SampledPoint[] adjacentNodes;
    int adjacentNodeCount;
    NodeColor nodeColor;
    int distance;
    SampledPoint predecessor;
    
    SampledPoint(PVector position, NodeColor nodeColor, int distance) {
        this.position = position;
        adjacentNodeCount = 0;
        adjacentNodes = new SampledPoint[samplePointsCount - 1];
        this.nodeColor = nodeColor;
        this.distance = distance;
    }
    
    void addAdjacentNode(SampledPoint node) {
        adjacentNodes[adjacentNodeCount] = node;
        adjacentNodeCount++;
    }
    

}
