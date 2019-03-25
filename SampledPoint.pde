// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class SampledPoint {
    PVector position;
    ArrayList<SampledPoint> adjacentNodes;
    float distance;
    SampledPoint predecessor;
    
    SampledPoint(PVector position, float distance) {
        this.position = position;
        adjacentNodes = new ArrayList();
        this.distance = distance;
        predecessor = null;
    }
}
