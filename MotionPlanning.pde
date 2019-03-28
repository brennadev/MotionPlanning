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


/////////////// Obstacles ///////////////

ArrayList<Obstacle> obstacles = new ArrayList();


/////////////// Character ///////////////

ArrayList<Agent> agents = new ArrayList();

// character starts here
final PVector characterInitialPosition = new PVector(-9, -9);

// character's goal
final PVector characterFinalPosition = new PVector(9, 9);

// where character currently is located on map
PVector characterCurrentPosition = new PVector(characterInitialPosition.x, characterInitialPosition.y);


/////////////// Motion Planning ///////////////
final int samplePointsCount = 55;    // even though ArrayList is used, this is still needed so it's known how many points need to be initially generated


// points from random sampling to create potential paths
ArrayList<SampledPoint> sampledPoints = new ArrayList();

float distanceToTravelPerFrame = 0.05;

float largestAgentRadius;    // make sure the largest agent can safely move along the path; this means the other agents will also be able to move along the path fine


void setup() {
    size(600, 600, P2D);
    
    // add obstacles
    Obstacle first = new Obstacle(new PVector(0, 0), 2);
    obstacles.add(first);
    
    Obstacle second = new Obstacle(new PVector(6, 4), 1);
    obstacles.add(second);
    
    Obstacle third = new Obstacle(new PVector(-4, -7), 2);
    obstacles.add(third);
    
    Obstacle fourth = new Obstacle(new PVector(7, 7), 1);
    obstacles.add(fourth);
    
    Obstacle fifth = new Obstacle(new PVector(-7, 7), 1);
    obstacles.add(fifth);
    
    Obstacle sixth = new Obstacle(new PVector(8, -6), 2);
    obstacles.add(sixth);
    
    Obstacle seventh = new Obstacle(new PVector(-6, 2), 1);
    obstacles.add(seventh);
    
    Obstacle eighth = new Obstacle(new PVector(0, 4), 2);
    obstacles.add(eighth);
    
    
    // add agents
    Agent agent1 = new Agent(0.5, new PVector(-9, -9), new PVector(9, 9), color(0, 255, 0));
    agents.add(agent1);
    
    Agent agent2 = new Agent(0.5, new PVector(0, -7), new PVector(9, 9), color(255, 0, 255));
    agents.add(agent2);
    
    Agent agent3 = new Agent(0.5, new PVector(9, 0), new PVector(9, 8), color(255, 255, 0));
    agents.add(agent3);
    
    
    // largest agent radius - for determining the path so all agent radii are accounted for
    largestAgentRadius = agents.get(0).radius;
    
    for(int i = 0; i < agents.size(); i++) {
        if (agents.get(i).radius > largestAgentRadius) {
            largestAgentRadius = agents.get(i).radius;
        }
    }
    

    generateSamplePoints();
    connectSamplePoints();
    
    
    // set the successors once we know all predecessors - will make it possible to get through the path from start to end rather than from end to start
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
    
    // obstacles
    for(int i = 0; i < obstacles.size(); i++) {
        circle(obstacles.get(i).position.x * scale + originToCenterTranslation, 
               obstacles.get(i).position.y * scale * -1 + originToCenterTranslation, 
               obstacles.get(i).radius * 2 * scale);
    }
    
    
    // initial/final positions for agents
    for(int i = 0; i < agents.size(); i++) {
        circle(agents.get(i).initialPosition.x * scale + originToCenterTranslation, agents.get(i).initialPosition.y * scale * -1 + originToCenterTranslation, 15);
        circle(agents.get(i).finalPosition.x * scale + originToCenterTranslation, agents.get(i).finalPosition.y * scale * -1 + originToCenterTranslation, 15);
    }
    
    
    // all sampled points
    fill(255, 0, 0);
    
    for(int i = 0; i < samplePointsCount; i++) {
        circle(sampledPoints.get(i).position.x * scale + originToCenterTranslation, sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation, 15);
    }
    
    
    // all possible paths
    stroke(0, 200, 255);
    
    for(int i = 0; i < samplePointsCount; i++) {
        for(int j = 0; j < sampledPoints.get(i).adjacentNodes.size(); j++) {
            line(sampledPoints.get(i).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes.get(j).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).adjacentNodes.get(j).position.y * scale * -1 + originToCenterTranslation);
        }
    }
     
    
    // shortest path    
    for(int i = 0; i < agents.size(); i++) {
        stroke(agents.get(i).shortestPathColor);
        
        for(int j = 0; j < agents.get(i).shortestPath.size() - 1; j++) {
            line(agents.get(i).shortestPath.get(j).position.x * scale + originToCenterTranslation,
                 agents.get(i).shortestPath.get(j).position.y * scale * -1 + originToCenterTranslation,
                 agents.get(i).shortestPath.get(j + 1).position.x * scale + originToCenterTranslation,
                 agents.get(i).shortestPath.get(j + 1).position.y * scale * -1 + originToCenterTranslation);
        }
    }
    
    noStroke();
    
    // agents
    for(int i = 0; i < agents.size(); i++) {
        fill(agents.get(i).shortestPathColor);
        circle(agents.get(i).currentPosition.x * scale + originToCenterTranslation,
               agents.get(i).currentPosition.y * scale * -1 + originToCenterTranslation,
               agents.get(i).radius * 2 * scale);
    }
}


// get the sample points for the path
void generateSamplePoints() {
    for(int i = 0; i < samplePointsCount; i++) {
        PVector newPoint;
        
        do {
            newPoint = new PVector(random(-roomSize / 2, roomSize / 2), random(-roomSize / 2, roomSize / 2));
        } while(pointIsInsideObstacles(newPoint));
        
        sampledPoints.add(new SampledPoint(newPoint, Integer.MAX_VALUE));
    }
}


// Helper for generateSamplePoints
boolean pointIsInsideObstacles(PVector point) {
    for(int i = 0; i < obstacles.size(); i++) {
        
        if (point.dist(obstacles.get(i).position) <= obstacles.get(i).radius + largestAgentRadius) {
            return true;
        }
    }
    return false;
}


// find where the lines between the sample points should go
void connectSamplePoints() {
    for(int i = 0; i < sampledPoints.size(); i++) {
        for(int j = i + 1; j < sampledPoints.size(); j++) {
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
    
    for(int i = 0; i < obstacles.size(); i++) {
    
        PVector directionNormalized = direction.normalize(null);
        
        float a = 1;
        float b = 2 * PVector.dot(directionNormalized, PVector.sub(origin, obstacles.get(i).position));
        float c = pow(abs(PVector.sub(origin, obstacles.get(i).position).mag()), 2) - pow(obstacles.get(i).radius + largestAgentRadius, 2);
        
        float discriminant = pow(b, 2) - 4 * a * c;
        
        if (discriminant < 0) {
            continue;
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
                continue;
            }
        }
    }
    return false;    // if there aren't any obstacles, there obviously isn't any edge-obstacle intersection (or it falls out of loop)
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
