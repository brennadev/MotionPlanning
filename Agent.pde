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
    
    int currentGoal;
    
    // shortest path from start to end; order of points in array is the order to traverse the path
    ArrayList<Integer> shortestPath = new ArrayList();
    color shortestPathColor;
    
    float[] distancesFromStart;        // per-point distance from start along shortest path to that point
    int[] predecessors;                // index of a given node in sampledPoints
    
    ArrayList<Float> scalarDistancesToSuccessors = new ArrayList();    // how far you have to travel to get to the next point
    ArrayList<PVector> directionsToSuccessors = new ArrayList();    // direction of the edge after a given point
    
    /////////////// Neighbors ///////////////
    float sensingRadius = 5;
    ArrayList<Agent> neighbors = new ArrayList();
    
    /////////////// Goal and velocity ///////////////
    float velocity = 0.1;
    // TODO: need to actually use currentVelocity, currentDirection
    // TODO: rename velocity to speed, scalar velocity, something like that so it's more clear what's what
    PVector currentVelocity = new PVector();
    PVector currentDirection = new PVector();    // so this value only needs to be calculated once per frame (maximum) - multiply by velocity to get currentVelocity
    float goalVelocity = 0.1;
    float totalForce = 0;    // will be set in 
    // TODO: may need to tweak k
    float k = 2;            // coefficient for goal force
    
    float timeHorizon = 3;    // in seconds
    float maxAvoidanceForce = 20;    // TODO: may need to tweak
    
    
    Agent(float radius, int initialPositionIndex, int finalPositionIndex, color shortestPathColor) {
        this.radius = radius;
        
        // indices
        startPointIndex = initialPositionIndex;
        endPointIndex = finalPositionIndex;
        
        currentPosition = new PVector(sampledPoints.get(startPointIndex).position.x, sampledPoints.get(startPointIndex).position.y);
        currentPoint = startPointIndex;
        
        // distancesFromStart
        distancesFromStart = new float[samplePointsCount + agentsCount * 2];
        predecessors = new int[samplePointsCount + agentsCount * 2];

        
        this.shortestPathColor = shortestPathColor;
    }
    
    
    void findShortestPathNew() {
        
        for(int i = 0; i < samplePointsCount + agentsCount * 2; i++) {
            distancesFromStart[i] = Float.MAX_VALUE;
        }
        
        distancesFromStart[startPointIndex] = 0;
        
        for(int i = 0; i < samplePointsCount + agentsCount * 2; i++) {
            predecessors[i] = -1;    // -1 indicates that a predecessor hasn't been set/there isn't a predecessor
        }
        
        ArrayList<Integer> q = new ArrayList();
        
        for(int i = 0; i < sampledPoints.size(); i++) {
            q.add(i);
        }
        
        int endIndex = -1;
        
        while (!q.isEmpty()) {
            SampledPoint u = getSmallestDistance(q);
            q.remove(new Integer(sampledPoints.indexOf(u)));
            
            // sampledPoints index for u
            int uIndex = sampledPoints.indexOf(u);
            
            // see if we've made it to the goal
            if (uIndex == endPointIndex) {
                endIndex = uIndex;
                break;
            }
            
            for(int i = 0; i < u.adjacentNodes.size(); i++) {
                float distanceToAdjacentNodeFromStart = PVector.dist(u.position, sampledPoints.get(u.adjacentNodes.get(i)).position) + distancesFromStart[sampledPoints.indexOf(u)];
                
                if (distanceToAdjacentNodeFromStart < distancesFromStart[u.adjacentNodes.get(i)]) {
                    distancesFromStart[u.adjacentNodes.get(i)] = distanceToAdjacentNodeFromStart;
                    // set the predecessor
                    predecessors[u.adjacentNodes.get(i)] = sampledPoints.indexOf(u);
                }
            }  
        }
        
        // set up the shortest path, which goes from the end node to the beginning node
        int currentIndex = endIndex;
        
        while(predecessors[currentIndex] != -1) {
            shortestPath.add(currentIndex);
            currentIndex = predecessors[currentIndex];
        }
        
        currentGoal = shortestPath.size() - 1;
    }
    
    
    
    
    void handleMovingCharacter() {
        // the start point will be at the last index in shortestPath
        if (!isAtEnd) {
            PVector goalPosition = sampledPoints.get(shortestPath.get(currentGoal)).position;
            
            if (PVector.dist(currentPosition, goalPosition) < velocity) {
                currentGoal--;
            }
            
            // we're at the end
            if (currentGoal == -1) {
                isAtEnd = true;
                return;
            }

            currentPosition.add(PVector.sub(goalPosition, currentPosition).normalize().mult(velocity));
        }
    }
    
    
    // helper for shortest path generation
    SampledPoint getSmallestDistance(ArrayList<Integer> q) {
        float smallestDistance = distancesFromStart[q.get(0)];
        
        SampledPoint pointWithSmallestDistance = sampledPoints.get(q.get(0));

        for(int i = 1; i < q.size(); i++) {
            if (distancesFromStart[q.get(i)] < smallestDistance) {
                pointWithSmallestDistance = sampledPoints.get(q.get(i));
                smallestDistance = distancesFromStart[i];
            }
        }
        return pointWithSmallestDistance;
    }
    
    
    /////////////// Neighbors and Collision Handling ///////////////
    void findNeighbors() {
        neighbors.clear();
        
        for(int i = 0; i < agents.size(); i++) {
            // don't want to do anything to yourself
            if (agents.get(i) != this) {
                // an agent is a neighbor if it's close enough to the current agent
                if (PVector.dist(currentPosition, agents.get(i).currentPosition) < sensingRadius) {
                    neighbors.add(agents.get(i));
                }
            }
        }
    }
    
    
    void handleCollisions() {
        totalForce = k * (goalVelocity - velocity);    // calculate goal force
        
        for(int i = 0; i < neighbors.size(); i++) {
            float timeToCollision = ttc(neighbors.get(i));
            
            PVector avoidanceForce = PVector.sub(PVector.add(currentPosition, PVector.mult(currentVelocity, timeToCollision)), 
                                                 PVector.add(neighbors.get(i).currentPosition, PVector.mult(neighbors.get(i).currentVelocity, timeToCollision)));
                                                 
            if (avoidanceForce.x != 0 && avoidanceForce.y != 0) {
                avoidanceForce.normalize();
            }
            
            // force magnitude
            float magnitude = 0;
            
            if (timeToCollision >= 0 && timeToCollision <= timeHorizon) {
                magnitude = (timeHorizon - timeToCollision) / (timeToCollision + 0.001);
            }
            
            if (magnitude > maxAvoidanceForce) {
                magnitude = maxAvoidanceForce;
            }
            
            avoidanceForce.mult(magnitude);
            //totalForce.add(avoidanceForce);
            // TODO: need to modify totalForce (and fix goal force calculation) to be a vector rather than scalar
        }
    }
    
    
    float ttc(Agent neighbor) {
        float totalRadius = radius + neighbor.radius;
        PVector w = PVector.sub(neighbor.currentPosition, currentPosition);
        
        // quadradic equation
        float c = PVector.dot(w, w) - totalRadius * totalRadius;
        
        if (c < 0) {
            return 0;
        }
        
        PVector velocityDifference = PVector.sub(currentVelocity, neighbor.currentVelocity);
        float a = PVector.dot(velocityDifference, velocityDifference);
        float b = PVector.dot(w, velocityDifference);
        
        float discriminant = b * b - a * c;
        
        // make sure we don't take a sqrt of a negative value
        if (discriminant <= 0) {
            return Float.MAX_VALUE;
        }
        
        float tau = (b - sqrt(discriminant)) / a;
        
        if (tau < 0) {
            return Float.MAX_VALUE;
        }
        
        return tau;
    }
}
