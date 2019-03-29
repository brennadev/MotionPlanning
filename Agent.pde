// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Agent {
    float radius;
    PVector currentPosition;
    PVector initialPosition;
    PVector finalPosition;
    
    
    // immediate point the character is after (or at)
    SampledPoint currentPoint = null;
    // how far along the edge after currentPoint the character currently is
    float scalarDistanceFromCurrentPoint = 0;   
    // indicates when at the end of the path
    boolean isAtEnd = false;                
    
    
    SampledPoint startPoint;
    SampledPoint endPoint;
    
    // shortest path from start to end; order of points in array is the order to traverse the path
    ArrayList<SampledPoint> shortestPath = new ArrayList();
    color shortestPathColor;
    
    float[] distancesFromStart;        // per-point distance from start along shortest path to that point
    int[] predecessors;
    int[] successors;
    float[] scalarDistancesToSuccessors;
    PVector[] directionsToSuccessors;    // direction of the edge after a given point
    
    Agent(float radius, PVector initialPosition, PVector finalPosition, color shortestPathColor) {
        this.radius = radius;
        currentPosition = new PVector(initialPosition.x, initialPosition.y);   // need a copy here since this will get modified as the program runs
        this.initialPosition = initialPosition;
        this.finalPosition = finalPosition;
        
        startPoint = new SampledPoint(initialPosition, 0);
        endPoint = new SampledPoint(finalPosition, Float.MAX_VALUE);
        
        this.shortestPathColor = shortestPathColor;
        
        distancesFromStart = new float[currentPointsCount];
        predecessors = new int[currentPointsCount];
        successors = new int[currentPointsCount];
        scalarDistancesToSuccessors = new float[currentPointsCount];
        directionsToSuccessors = new PVector[currentPointsCount];
    }
    
    
    void findShortestPath() {
        ArrayList<SampledPoint> q = new ArrayList();
        q.add(startPoint);    // add starting node
        boolean endNodeHasBeenInQueue = false;    // the end node needs to end up in the queue at least once to know that it's been processed
        
        // while the end node isn't fully processed
        while((q.contains(endPoint) || !endNodeHasBeenInQueue) && !q.isEmpty()) {
            SampledPoint u = getSmallestDistance(q);
            q.remove(u);
            
            for(int i = 0; i < u.adjacentNodes.size(); i++) {
                float distanceToAdjacentNodeFromStart = PVector.dist(u.position, sampledPoints.get(u.adjacentNodes.get(i)).position) + distancesFromStart[sampledPoints.indexOf(u)];
                
                if (distanceToAdjacentNodeFromStart < distancesFromStart[u.adjacentNodes.get(i)]) {
                    distancesFromStart[u.adjacentNodes.get(i)] = distanceToAdjacentNodeFromStart;
                    q.add(sampledPoints.get(u.adjacentNodes.get(i)));
                    sampledPoints.get(u.adjacentNodes.get(i)).predecessor = u;
                    
                    // may need to update if the end node has been in the queue
                    if (sampledPoints.get(u.adjacentNodes.get(i)) == sampledPoints.get(1) && !endNodeHasBeenInQueue) {
                        endNodeHasBeenInQueue = true;
                    }
                }
            }
        }
    }
    
    
    // per-frame character movement; call in draw
    void handleMovingCharacter() {
        if (!isAtEnd) {
            // how much distance remains until reaching the next point on the path
            float scalarDistanceToNextPoint = currentPoint.scalarDistanceToSuccessor - scalarDistanceFromCurrentPoint;
            
            // when close to the next point
            if (scalarDistanceToNextPoint < distanceToTravelPerFrame) {
                // get to the end of the current edge
                characterCurrentPosition.add(PVector.mult(currentPoint.directionToSuccessor, scalarDistanceToNextPoint));
                
                currentPoint = currentPoint.successor;
                
                // once at end point, nothing more needs to be done
                if (currentPoint == sampledPoints.get(1)) {
                    isAtEnd = true;
                    return;
                }
                
                // how much distance to move from the new point
                float scalarDistanceFromNewCurrentPoint = distanceToTravelPerFrame - scalarDistanceToNextPoint;
                
                characterCurrentPosition.add(PVector.mult(currentPoint.directionToSuccessor, scalarDistanceFromNewCurrentPoint));
                scalarDistanceFromCurrentPoint = scalarDistanceFromNewCurrentPoint;
                
            // normally...    
            } else {
                characterCurrentPosition.add(PVector.mult(currentPoint.directionToSuccessor, distanceToTravelPerFrame));
                scalarDistanceFromCurrentPoint += distanceToTravelPerFrame;
            }
        }
    }
    
    SampledPoint getSmallestDistance(ArrayList<SampledPoint> q) {
        float smallestDistance = Float.MAX_VALUE;
        SampledPoint pointWithSmallestDistance = null;
        
        for(int i = 0; i < q.size(); i++) {
            if (distancesFromStart[i] < smallestDistance) {
                pointWithSmallestDistance = q.get(i);
                smallestDistance = distancesFromStart[i];
            }
        }
        
        return pointWithSmallestDistance;
    }
}
