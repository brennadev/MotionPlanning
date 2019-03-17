// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

enum NodeColor {
    white,
    gray, 
    black
}

class SampledPoint {
    
    
    
    PVector position;
    Edge[] edges;
    NodeColor nodeColor;
    int distance;
    SampledPoint predecessor;
    
    SampledPoint(PVector position, Edge[] edges, NodeColor nodeColor, int distance) {
        this.position = position;
        this.edges = edges;
        this.nodeColor = nodeColor;
        this.distance = distance;
    }
}
