// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Agent {
    float radius;
    PVector currentPosition;
    //PVector initialPosition;
    PVector finalPosition;
    
    
    // immediate point the character is after (or at)
    int currentPoint;
    // how far along the edge after currentPoint the character currently is
    float scalarDistanceFromCurrentPoint = 0;   
    // indicates when at the end of the path
    boolean isAtEnd = false;                
    
    
    SampledPoint startPoint;
    SampledPoint endPoint;
    
    int startPointIndex;
    int endPointIndex;
    
    // here so the distance from start can be properly set
    void setStartPointIndex(int value) {
        startPointIndex = value;
        distancesFromStart[startPointIndex] = 0;
    }
    
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
        //this.initialPosition = initialPosition;
        this.finalPosition = finalPosition;
        
        startPoint = new SampledPoint(initialPosition);
        endPoint = new SampledPoint(finalPosition);
        
        this.shortestPathColor = shortestPathColor;
        
        // the problem is the start/end nodes aren't being taken into account - but because we don't know how many agents there'll be until they're added,
        // we don't know how many agents are needed (unless I have a hardcoded value)
        // there are 3 agents, therefore 6 start/end points (3 of each)
        distancesFromStart = new float[currentPointsCount + 6];
        predecessors = new int[currentPointsCount + 6];
        successors = new int[currentPointsCount + 6];
        scalarDistancesToSuccessors = new float[currentPointsCount + 6];
        directionsToSuccessors = new PVector[currentPointsCount + 6];
        
        // set up initial distances and other initial values
        for(int i = 0; i < currentPointsCount; i++) {
            distancesFromStart[i] = Float.MAX_VALUE;
            predecessors[i] = -1;
            successors[i] = -1;
        }
    }
    
    
    void findShortestPath() {
        ArrayList<SampledPoint> q = new ArrayList();
        q.add(sampledPoints.get(startPointIndex));    // add starting node
        boolean endNodeHasBeenInQueue = false;    // the end node needs to end up in the queue at least once to know that it's been processed
        
        // while the end node isn't fully processed
        while((q.contains(endPoint) || !endNodeHasBeenInQueue) && !q.isEmpty()) {
            SampledPoint u = getSmallestDistance(q);
            q.remove(u);
            
            // crashes with null pointer on line below; looks like it never enters the loop
            // adjacent nodes are fine; could be from getSamllestDistance
            // appeared to be fixed but now is crashing again on this line
            // another null pointer crash - still
            // u must be null - but why would getSmallestDistance be returning null? Right now, it's just that the crashes are fixed (so really, I need to look at
            // that method more closely)
            for(int i = 0; i < u.adjacentNodes.size(); i++) {
                println(i);
                float distanceToAdjacentNodeFromStart = PVector.dist(u.position, sampledPoints.get(u.adjacentNodes.get(i)).position) + distancesFromStart[sampledPoints.indexOf(u)];
                
                // crashes on line below with out of bounds (56, 58)
                if (distanceToAdjacentNodeFromStart < distancesFromStart[u.adjacentNodes.get(i)]) {
                    distancesFromStart[u.adjacentNodes.get(i)] = distanceToAdjacentNodeFromStart;
                    if (!q.contains(sampledPoints.get(u.adjacentNodes.get(i)))) {
                        q.add(sampledPoints.get(u.adjacentNodes.get(i)));
                    }
                    predecessors[u.adjacentNodes.get(i)] = sampledPoints.indexOf(u);
                    
                    // may need to update if the end node has been in the queue
                    if (sampledPoints.get(u.adjacentNodes.get(i)) == sampledPoints.get(1) && !endNodeHasBeenInQueue) {
                        endNodeHasBeenInQueue = true;
                    }
                }
            }
        }
    }
    
    
    void setUpSuccessors() {
        // only hit 5 points on one run - obviously not all of them
        while (predecessors[currentPoint] != -1) {
            println("setupsuccessors");
            successors[predecessors[currentPoint]] = currentPoint;
            directionsToSuccessors[predecessors[currentPoint]] = PVector.sub(sampledPoints.get(currentPoint).position, sampledPoints.get(predecessors[currentPoint]).position).normalize();
            // this still seems like a mess
            println(directionsToSuccessors[predecessors[currentPoint]]);
            println(predecessors[currentPoint]);
            scalarDistancesToSuccessors[predecessors[currentPoint]] = PVector.dist(sampledPoints.get(predecessors[currentPoint]).position, sampledPoints.get(currentPoint).position);
            currentPoint = predecessors[currentPoint];
        }
    }
    
    // per-frame character movement; call in draw
    void handleMovingCharacter() {        
        if (!isAtEnd) {
            // how much distance remains until reaching the next point on the path
            float scalarDistanceToNextPoint = scalarDistancesToSuccessors[currentPoint] - scalarDistanceFromCurrentPoint;
            
            // when close to the next point
            if (scalarDistanceToNextPoint < distanceToTravelPerFrame) {
                // get to the end of the current edge
                println(directionsToSuccessors[currentPoint]);
                
                // directionsToSuccessors has no values in it
                // crashing on the first time in this
                currentPosition.add(PVector.mult(directionsToSuccessors[currentPoint], scalarDistanceToNextPoint));
                
                currentPoint = successors[currentPoint];
                
                
                // once at end point, nothing more needs to be done
                println("currentPoint: " + currentPoint);
                if (currentPoint == endPointIndex) {
                    isAtEnd = true;
                    return;
                }
                
                // how much distance to move from the new point
                float scalarDistanceFromNewCurrentPoint = distanceToTravelPerFrame - scalarDistanceToNextPoint;
                
                currentPosition.add(PVector.mult(directionsToSuccessors[currentPoint], scalarDistanceFromNewCurrentPoint));
                scalarDistanceFromCurrentPoint = scalarDistanceFromNewCurrentPoint;
                
            // normally...    
            } else {
                currentPosition.add(PVector.mult(directionsToSuccessors[currentPoint], distanceToTravelPerFrame));
                scalarDistanceFromCurrentPoint += distanceToTravelPerFrame;
            }
        }
    }
    
    SampledPoint getSmallestDistance(ArrayList<SampledPoint> q) {
        float smallestDistance = Float.MAX_VALUE;
        SampledPoint pointWithSmallestDistance = null;
        
        for(int i = 0; i < q.size(); i++) {
            if (distancesFromStart[sampledPoints.indexOf(q.get(i))] < smallestDistance) {
                pointWithSmallestDistance = q.get(i);
                smallestDistance = distancesFromStart[i];
            }
        }
        
        return pointWithSmallestDistance;
    }
}
