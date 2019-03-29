// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

/// A single node in the graph of potential paths
class SampledPoint {
    PVector position;
    ArrayList<Integer> adjacentNodes;
    
    SampledPoint(PVector position) {
        this.position = position;
        adjacentNodes = new ArrayList();
    } 
}
