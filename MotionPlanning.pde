// Copyright 2019 Brenna Olson. You may download this code for informational purposes only.

import java.util.LinkedList;
import java.util.ArrayList;
import java.util.Collections;

/////////////// Room ///////////////

// x and y dimensions of room (same dimensions along each axis)
final float roomSize = 20;


/////////////// Viewing adjustments ///////////////

// how many times bigger to make everything when rendering so it can be easily seen
final float scale = 30;

final float originToCenterTranslation = 300;

/////////////// Obstacle ///////////////
final float obstacleRadius = 2;
final PVector obstaclePosition = new PVector(0, 0);


/////////////// Character ///////////////

// character starts here
final PVector characterInitialPosition = new PVector(-9, -9);

// character's goal
final PVector characterFinalPosition = new PVector(9, 9);

// where character currently is located on map
PVector characterCurrentPosition = new PVector(characterInitialPosition.x, characterInitialPosition.y);


/////////////// Motion Planning ///////////////
final int samplePointsCount = 5;    // even though ArrayList is used, this is still needed so it's known how many points need to be initially generated


// points from random sampling to create potential paths
ArrayList<SampledPoint> sampledPoints = new ArrayList();

float distanceToTravelPerFrame = 0.1;    // TODO: may need to adjust this
SampledPoint currentPoint;               // immediate point the character is after (or at)


void setup() {
    size(600, 600, P2D);
    noStroke();
    
    sampledPoints.add(new SampledPoint(characterInitialPosition, 0));                   // start node
    sampledPoints.add(new SampledPoint(characterFinalPosition, Integer.MAX_VALUE));    // end node
    
    generateSamplePoints();
    connectSamplePoints();
    findShortestPathNew();
    
    currentPoint = sampledPoints.get(0);    // of course, the simulation needs to start at the starting point
    
    // set the successors once we know all predecessors
    SampledPoint current = sampledPoints.get(1);
    
    while (current.predecessor != null) {
        current.predecessor.successor = current;
        current.predecessor.directionToSuccessor = PVector.sub(current.position, current.predecessor.position).normalize();
        current.predecessor.scalarDistanceToSuccessor = PVector.dist(current.predecessor.position, current.position);
        current = current.predecessor;
    }
}


void draw() {
    background(0);
    fill(255);
    noStroke();
    circle(obstaclePosition.x * scale + originToCenterTranslation, obstaclePosition.y * scale * -1 + originToCenterTranslation, obstacleRadius * 2 * scale);
    circle(characterInitialPosition.x * scale + originToCenterTranslation, characterInitialPosition.y * scale * -1 + originToCenterTranslation, 15);
    circle(characterFinalPosition.x * scale + originToCenterTranslation, characterFinalPosition.y * scale * -1 + originToCenterTranslation, 15);
    
    
    fill(255, 0, 0);
    
    for(int i = 0; i < samplePointsCount; i++) {
        circle(sampledPoints.get(i + 2).position.x * scale + originToCenterTranslation, sampledPoints.get(i + 2).position.y * scale * -1 + originToCenterTranslation, 15);
    }
    
    stroke(0, 200, 255);
    
    for(int i = 0; i < samplePointsCount; i++) {
        for(int j = 0; j < sampledPoints.get(i).adjacentNodes.size(); j++) {
            line(sampledPoints.get(i).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes.get(j).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes.get(j).position.y * scale * -1 + originToCenterTranslation);
        }
    }
     
     stroke(0, 255, 0);
     SampledPoint current = sampledPoints.get(0);
    
    while (current.successor != null) {
        line(current.position.x * scale + originToCenterTranslation,
        current.position.y * scale * -1 + originToCenterTranslation,
        current.successor.position.x * scale + originToCenterTranslation,
        current.successor.position.y * scale * -1 + originToCenterTranslation);
        current = current.successor;
    }
    
    
}


// get the sample points for the path
void generateSamplePoints() {
    for(int i = 0; i < samplePointsCount; i++) {
        PVector newPoint;
        
        do {
            newPoint = new PVector(random(-roomSize / 2, roomSize / 2), random(-roomSize / 2, roomSize / 2));
        } while (newPoint.dist(obstaclePosition) <= obstacleRadius);
        
        sampledPoints.add(new SampledPoint(newPoint, Integer.MAX_VALUE));
    }
}


// find where the lines between the sample points should go
void connectSamplePoints() {
    for(int i = 0; i < samplePointsCount + 2; i++) {
        for(int j = i + 1; j < samplePointsCount + 2; j++) {
            float t = 9e9;
            // only want to include the edge if it's not colliding with the obstacle
            if (!edgeHitsObstacle(sampledPoints.get(i).position, PVector.sub(sampledPoints.get(j).position, sampledPoints.get(i).position), t)) {
                sampledPoints.get(i).adjacentNodes.add(sampledPoints.get(j));
                sampledPoints.get(j).adjacentNodes.add(sampledPoints.get(i));
            } 
        }
    }
}


// ray-object intersection test to check for edges that intersect the obstacle; adapted from my 5607 ray tracer
boolean edgeHitsObstacle(PVector origin, PVector direction, Float t) {
    
    PVector directionNormalized = direction.normalize(null);
    
    float a = 1;
    float b = 2 * PVector.dot(directionNormalized, PVector.sub(origin, obstaclePosition));
    float c = pow(abs(PVector.sub(origin, obstaclePosition).mag()), 2) - pow(obstacleRadius, 2);
    
    float discriminant = pow(b, 2) - 4 * a * c;
    
    if (discriminant < 0) {
        return false;
    } else {
        float firstT = (-1 * b + sqrt(discriminant)) / (2 * a);
        float secondT = (-1 * b - sqrt(discriminant)) / (2 * a);
        
        if (firstT > 0.001) {
            if (secondT > 0.001) {
                t = min(min(firstT, secondT), t);
            } else {
                t = min(t, firstT);
            }
            return true;
            
        } else if (secondT > 0.001) {
            t = min(t, secondT);
            return true;
            
        } else {
            return false;
        }
    }
}


// Uniform cost search
void findShortestPathNew() {
    ArrayList<SampledPoint> q = new ArrayList();
    q.add(sampledPoints.get(0));    // add starting node
    boolean endNodeHasBeenInQueue = false;    // the end node needs to end up in the queue at least once to know that it's been processed
    
    // while the end node isn't fully processed
    while((q.contains(sampledPoints.get(1)) || !endNodeHasBeenInQueue) && !q.isEmpty()) {
        SampledPoint u = getSmallestDistance(q);
        q.remove(u);
        
        for(int i = 0; i < u.adjacentNodes.size(); i++) {
            float distanceToAdjacentNodeFromStart = PVector.dist(u.position, u.adjacentNodes.get(i).position) + u.distance;
            
            if (distanceToAdjacentNodeFromStart < u.adjacentNodes.get(i).distance) {
                u.adjacentNodes.get(i).distance = distanceToAdjacentNodeFromStart;
                q.add(u.adjacentNodes.get(i));
                u.adjacentNodes.get(i).predecessor = u;
                //u.successor = u.adjacentNodes.get(i);
                
                // may need to update if the end node has been in the queue
                if (u.adjacentNodes.get(i) == sampledPoints.get(1) && !endNodeHasBeenInQueue) {
                    endNodeHasBeenInQueue = true;
                }
            }
        }
    }
}


// Returns the SampledPoint with the smallest distance value in the queue; will return null if the queue is empty (helper for shortest path function)
SampledPoint getSmallestDistance(ArrayList<SampledPoint> q) {
    float smallestDistance = Float.MAX_VALUE;
    SampledPoint pointWithSmallestDistance = null;
    
    for(int i = 0; i < q.size(); i++) {
        if (q.get(i).distance < smallestDistance) {
            pointWithSmallestDistance = q.get(i);
            smallestDistance = q.get(i).distance;
        }
    }
    
    return pointWithSmallestDistance;
}
