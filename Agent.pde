// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Agent {
    float radius;
    PVector currentPosition;
    
    // immediate point the character is after (or at)
    int currentPoint;
    // how far along the edge after currentPoint the character currently is
    float scalarDistanceFromCurrentPoint = 0;   
    // indicates when at the end of the path
    boolean isAtEnd = false;                
    
    
    int startPointIndex;
    int endPointIndex;
    
    
    // shortest path from start to end; order of points in array is the order to traverse the path
    ArrayList<Integer> shortestPath = new ArrayList();
    color shortestPathColor;
    
    float[] distancesFromStart;        // per-point distance from start along shortest path to that point
    
    ArrayList<Float> scalarDistancesToSuccessors = new ArrayList();    // how far you have to travel to get to the next point
    ArrayList<PVector> directionsToSuccessors = new ArrayList();    // direction of the edge after a given point
    
    
    Agent(float radius, int initialPositionIndex, int finalPositionIndex, color shortestPathColor) {
        this.radius = radius;
        
        // indices
        startPointIndex = initialPositionIndex;
        endPointIndex = finalPositionIndex;
        
        currentPosition = new PVector(sampledPoints.get(startPointIndex).position.x, sampledPoints.get(startPointIndex).position.y);
        currentPoint = startPointIndex;
        
        // distancesFromStart
        distancesFromStart = new float[samplePointsCount + agentsCount * 2];
        
        distancesFromStart[startPointIndex] = 0;
        
        for(int i = 1; i < samplePointsCount; i++) {
            distancesFromStart[i] = Float.MAX_VALUE;
        }
        
        this.shortestPathColor = shortestPathColor;
    }
    
    
    void findShortestPathNew() {
        ArrayList<Integer> q = new ArrayList();
        
        for(int i = 0; i < sampledPoints.size(); i++) {
            q.add(i);
        }
        
        while (!q.isEmpty()) {
            SampledPoint u = getSmallestDistance(q);
            q.remove(sampledPoints.indexOf(u));
            
            for(int i = 0; i < u.adjacentNodes.size(); i++) {
                
            }
            
        }
    }
    
    
    void findShortestPath() {
        ArrayList<Integer> q = new ArrayList();
        q.add(startPointIndex);    // add starting node
        //boolean endNodeHasBeenInQueue = false;    // the end node needs to end up in the queue at least once to know that it's been processed
        
        // something is causing the loop below to get stuck in an infinite loop
        //shortestPath.add(startPointIndex);
        // while the end node isn't fully processed
        
        // the loop condition seems way complex
        
        // while q not empty; once you take end point out, you can break (simplifying
        
       /*while((q.contains(endPointIndex) || !endNodeHasBeenInQueue) && !q.isEmpty()) {
            SampledPoint u = getSmallestDistance(q);
            q.remove(u);
            
            // forcing the left half of the loop condition to be true gets the loop to exit - so something must be incorrect in the handling of
            // the end point or endNodeHasBeenInQueue being set
            // for some reason, putting this in makes it crash on the next line (the shortestPath add thing)
            //endNodeHasBeenInQueue = true;
            
            shortestPath.add(u.adjacentNodes.get(0));    // have to start with something for the adjacent node to travel through
            
            // crashes with null pointer on line below; looks like it never enters the loop
            // adjacent nodes are fine; could be from getSamllestDistance
            // appeared to be fixed but now is crashing again on this line
            // another null pointer crash - still
            // u must be null - but why would getSmallestDistance be returning null? Right now, it's just that the crashes are fixed (so really, I need to look at
            // that method more closely)
            for(int i = 0; i < u.adjacentNodes.size(); i++) {
                //println(i);
                float distanceToAdjacentNodeFromStart = PVector.dist(u.position, sampledPoints.get(u.adjacentNodes.get(i)).position) + distancesFromStart[sampledPoints.indexOf(u)];
                
                // crashes on line below with out of bounds (56, 58)
                if (distanceToAdjacentNodeFromStart < distancesFromStart[u.adjacentNodes.get(i)]) {
                    distancesFromStart[u.adjacentNodes.get(i)] = distanceToAdjacentNodeFromStart;
                    // not sure if having the statement below in an if statement makes any difference (as it's not in an if statement in the checkin - but then,
                    // the if statement above is what seems to be never true
                    if (!q.contains(sampledPoints.get(u.adjacentNodes.get(i)))) {
                        q.add(u.adjacentNodes.get(i));
                    }
                    //predecessors[u.adjacentNodes.get(i)] = sampledPoints.indexOf(u);
                    
                    if (distancesFromStart[u.adjacentNodes.get(i)] < distancesFromStart[shortestPath.get(shortestPath.size() - 1)]) {
                        shortestPath.set(shortestPath.size() - 1, u.adjacentNodes.get(i));
                    }
                    
                    // may need to update if the end node has been in the queue
                    if (u.adjacentNodes.get(i) == endPointIndex && !endNodeHasBeenInQueue) {
                        endNodeHasBeenInQueue = true;
                    }
                }
            }
        }*/
    }
    
    
    /*void setUpSuccessors() {
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
    }*/
    
    // per-frame character movement; call in draw
    /*void handleMovingCharacter() {        
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
    }*/
    
    
    SampledPoint getSmallestDistance(ArrayList<Integer> q) {
        float smallestDistance = Float.MAX_VALUE;
        
        SampledPoint pointWithSmallestDistance = null;
        //SampledPoint pointWithSmallestDistance = sampledPoints.get(q.get(0));
        
        for(int i = 0; i < q.size(); i++) {
            //println(q.get(i));
            //println(sampledPoints.indexOf(q.get(i)));
            if (distancesFromStart[q.get(i)] < smallestDistance) {
                pointWithSmallestDistance = sampledPoints.get(q.get(i));
                smallestDistance = distancesFromStart[i];
            }
        }
        
        return pointWithSmallestDistance;
    }
}
