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

//final int samplePointsCount = 20;
final int samplePointsCount = 5;


// points from random sampling to create potential paths
//SampledPoint[] sampledPoints = new SampledPoint[samplePointsCount + 2];    // need to account for start and end points in here too
ArrayList<SampledPoint> sampledPoints = new ArrayList();

//PVector[] sampledPoints = new PVector[samplePointsCount];
ArrayList<SampledPoint> shortestPath = new ArrayList();
int shortestPathEdgeCount = 0;    // will get incremented once the path is found


// TODO: probably need a limit on how many edges to travel (what goes as the size of edgesToTravel since I just stuck a value in for now)
int edgesToTravelCount = 0;    // TODO: of course this value needs to be changed (and it'll get set at a later point anyway, so the value here may not matter)
Edge[] edgesToTravel = new Edge[10];


void setup() {
    size(600, 600, P2D);
    noStroke();
    
    sampledPoints.add(new SampledPoint(characterInitialPosition, 0));                   // start node
    sampledPoints.add(new SampledPoint(characterFinalPosition, Integer.MAX_VALUE));    // end node
    
    generateSamplePoints();
    connectSamplePoints();
    findShortestPath();
    
    for(int i = 0; i < samplePointsCount + 2; i++) {
        //println(sampledPoints[i].nodeColor);
    }
    
    println(shortestPathEdgeCount);
}


void draw() {
    background(0);
    fill(255);
    noStroke();
    circle(obstaclePosition.x * scale + originToCenterTranslation, obstaclePosition.y * scale * -1 + originToCenterTranslation, obstacleRadius * scale);
    circle(characterInitialPosition.x * scale + originToCenterTranslation, characterInitialPosition.y * scale * -1 + originToCenterTranslation, 15);
    circle(characterFinalPosition.x * scale + originToCenterTranslation, characterFinalPosition.y * scale * -1 + originToCenterTranslation, 15);
    
    
    fill(255, 0, 0);
    
    for(int i = 0; i < samplePointsCount; i++) {
        circle(sampledPoints.get(i + 2).position.x * scale + originToCenterTranslation, sampledPoints.get(i + 2).position.y * scale * -1 + originToCenterTranslation, 15);
    }
    
    stroke(0, 200, 255);
    
    for(int i = 0; i < samplePointsCount; i++) {
        for(int j = 0; j < sampledPoints.get(i).adjacentNodeCount; j++) {
            line(sampledPoints.get(i).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes[j].position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes[j].position.y * scale * -1 + originToCenterTranslation);
        }
    }
    
    noStroke();
    for(int i = 0; i < shortestPath.size(); i++) {
        fill(i * 40);
        circle(shortestPath.get(i).position.x * scale + originToCenterTranslation, shortestPath.get(i).position.y * scale * -1 + originToCenterTranslation, 9);
    }
    
    fill(0, 255, 0);
    
    // TODO: character position update (update characterCurrentPosition)
    
    //circle(characterCurrentPosition.x * scale + originToCenterTranslation, characterCurrentPosition.y * scale * -1 + originToCenterTranslation, 20); 
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
                sampledPoints.get(i).addAdjacentNode(sampledPoints.get(j));
                sampledPoints.get(j).addAdjacentNode(sampledPoints.get(i));
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


void findShortestPath() {
    
    ArrayList<SampledPoint> qNewAgain = new ArrayList(sampledPoints);

    
    while (!qNewAgain.isEmpty()) { 
        float shortestDistance = Float.MAX_VALUE;
        SampledPoint u = null;
        
        for(int i = 0; i < qNewAgain.size(); i++) {
            // TODO: needs to be aware of the removed edges
            if (qNewAgain.get(i).distance < shortestDistance) {
                u = qNewAgain.get(i);
                qNewAgain.remove(i);
                break;
            }
        }
        
        
        // add to shortest path if necessary
        shortestPathEdgeCount++;    // needs to go in the if
        
        if (!shortestPath.contains(u)) {
            shortestPath.add(u);
        }
        
        for(int i = 0; i < u.adjacentNodeCount; i++) {
            relax(u, u.adjacentNodes[i]);
        }
    }
    
}


void relax(SampledPoint from, SampledPoint to) {
    
    float distance = abs(PVector.dist(from.position, to.position));
    
    if (to.distance > from.distance + distance) {
        to.distance = from.distance + distance;
        to.predecessor = from;
    }
}
