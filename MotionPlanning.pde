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


/////////////// Motion Planning ///////////////
final int samplePointsCount = 50;    // even though ArrayList is used, this is still needed so it's known how many points need to be initially generated
final int agentsCount = 3;

// points from random sampling to create potential paths
ArrayList<SampledPoint> sampledPoints = new ArrayList();

Matrix distanceMatrix;
float distanceToTravelPerFrame = 0.05;
float largestAgentRadius;    // make sure the largest agent can safely move along the path; this means the other agents will also be able to move along the path fine


/////////////// User Interaction ///////////////
// with the user interaction in there, there's more state to keep track of
enum SimulationState { 
    addAgentStartEnds, 
    addObstacles, 
    setUpMap, 
    runSimulation
}

// current mode for the simulation
SimulationState mode = SimulationState.addAgentStartEnds;


void setup() {
    size(600, 600, P2D);
    
    // add obstacles
    /*Obstacle first = new Obstacle(new PVector(0, 0), 2);
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
    */
    // add agents
    
    // agent start and end positions - used later for initializing the Agent instances
   /* PVector[] start = new PVector[agentsCount];
    PVector[] end = new PVector[agentsCount];
    color[] agentColors = new color[agentsCount];
    
    start[0] = new PVector(-9, -9);
    start[1] = new PVector(0, -7);
    start[2] = new PVector(9, 0);
    end[0] = new PVector(9, 9);
    end[1] = new PVector(9, 9);
    end[2] = new PVector(9, 8);
    agentColors[0] = color(0, 255, 0);
    agentColors[1] = color(255, 0, 255);
    agentColors[2] = color(255, 255, 0);
    
    for(int i = 0; i < agentsCount; i++) {
        sampledPoints.add(new SampledPoint(start[i]));
        sampledPoints.add(new SampledPoint(end[i]));
        agents.add(new Agent(0.5, sampledPoints.size() - 2, sampledPoints.size() - 1, agentColors[i]));
    }
    
    */
    // largest agent radius - for determining the path so all agent radii are accounted for
    /*largestAgentRadius = agents.get(0).radius;
    
    for(int i = 0; i < agents.size(); i++) {
        if (agents.get(i).radius > largestAgentRadius) {
            largestAgentRadius = agents.get(i).radius;
        }
    }*/
    
    // the only way we know how many points are needed at the most is with the fixed initial amount of sampled points and the start/end points for the agents
    distanceMatrix = new Matrix(samplePointsCount + agentsCount * 2);

    /*generateSamplePoints();
    connectSamplePoints();
    
    */
    
    /*
    for(int i = 0; i < agents.size(); i++) {
        agents.get(i).findShortestPathNew();
        
        for(int j = 0; j < agents.get(i).shortestPath.size(); j++) {
            println("shortest path");
            println(agents.get(i).shortestPath.get(j));
        }
    }*/
}


void draw() {
    if (mode == SimulationState.setUpMap) {
        
        largestAgentRadius = agents.get(0).radius;
    
        for(int i = 0; i < agents.size(); i++) {
            if (agents.get(i).radius > largestAgentRadius) {
                largestAgentRadius = agents.get(i).radius;
            }
        }
        
        generateSamplePoints();
        connectSamplePoints();
        
        for(int i = 0; i < agents.size(); i++) {
            agents.get(i).findShortestPathNew();
        }
        mode = SimulationState.runSimulation;
    }
    
    background(0);
    fill(255);
    noStroke();
    
    // obstacles
    for(int i = 0; i < obstacles.size(); i++) {
        circle(obstacles.get(i).position.x * scale + originToCenterTranslation, 
               obstacles.get(i).position.y * scale * -1 + originToCenterTranslation, 
               obstacles.get(i).radius * 2 * scale);
    }
    
    // all sampled points
    fill(255, 0, 0);
    
    for(int i = 0; i < sampledPoints.size(); i++) {
        circle(sampledPoints.get(i).position.x * scale + originToCenterTranslation, sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation, 15);
    }
    
    
    // all possible paths
    stroke(0, 200, 255);
    
    for(int i = 0; i < sampledPoints.size(); i++) {
        for(int j = 0; j < sampledPoints.get(i).adjacentNodes.size(); j++) {
            line(sampledPoints.get(i).position.x * scale + originToCenterTranslation,
                sampledPoints.get(i).position.y * scale * -1 + originToCenterTranslation,
                sampledPoints.get(sampledPoints.get(i).adjacentNodes.get(j)).position.x * scale + originToCenterTranslation,
                sampledPoints.get(sampledPoints.get(i).adjacentNodes.get(j)).position.y * scale * -1 + originToCenterTranslation);
        }
    }
     
    
    // shortest path    
    for(int i = 0; i < agents.size(); i++) {
        stroke(agents.get(i).shortestPathColor);
        
        for(int j = 0; j < agents.get(i).shortestPath.size() - 1; j++) {
            line(sampledPoints.get(agents.get(i).shortestPath.get(j)).position.x * scale + originToCenterTranslation,
                 sampledPoints.get(agents.get(i).shortestPath.get(j)).position.y * scale * -1 + originToCenterTranslation,
                 sampledPoints.get(agents.get(i).shortestPath.get(j + 1)).position.x * scale + originToCenterTranslation,
                 sampledPoints.get(agents.get(i).shortestPath.get(j + 1)).position.y * scale * -1 + originToCenterTranslation);
        }
    }
    
    noStroke();
    
    for(int i = 0; i < agents.size(); i++) {
        agents.get(i).findNeighbors();
    }
    
    // agents
    for(int i = 0; i < agents.size(); i++) {
        fill(agents.get(i).shortestPathColor);
        
        if (mode == SimulationState.runSimulation) {
            agents.get(i).handleMovingCharacter();
        }
        
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
        
        sampledPoints.add(new SampledPoint(newPoint));
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


// sampled points - for sure, nothing is getting added to 
// find where the lines between the sample points should go
void connectSamplePoints() {
    for(int i = 0; i < sampledPoints.size() - 1; i++) {
        for(int j = i + 1; j < sampledPoints.size(); j++) {
            float t = 9e9;
            // only want to include the edge if it's not colliding with the obstacle
            if (!edgeHitsObstacle(sampledPoints.get(i).position, PVector.sub(sampledPoints.get(j).position, sampledPoints.get(i).position), t)) {
                sampledPoints.get(i).adjacentNodes.add(j);
                sampledPoints.get(j).adjacentNodes.add(i);
                
                float distance = PVector.dist(sampledPoints.get(i).position, sampledPoints.get(j).position);
                distanceMatrix.matrix[i][j] = distance;
                distanceMatrix.matrix[j][i] = distance;
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


void keyPressed() {
    // when the simulation is ready to start - after agent start/end points are in and (optionally) obstacles are in
    if (mode == SimulationState.addObstacles && key == ' ') {
        mode = SimulationState.setUpMap;
    }
}



// mouse position adjusted for coordinates being used in this program
PVector mousePosition() {
    return new PVector((mouseX - originToCenterTranslation) / scale, (mouseY - originToCenterTranslation) / scale * -1);
}


// hold the position between mouse clicks - after the start point is added but before the end point is added
PVector nextStartPoint;

void mouseClicked() {
    if (mode == SimulationState.addAgentStartEnds) {
        
        // it's a start node
        if (sampledPoints.size() % 2 == 0) {
            nextStartPoint = mousePosition();
            sampledPoints.add(new SampledPoint(nextStartPoint));
            
        // it's an end node    
        } else {
            sampledPoints.add(new SampledPoint(mousePosition()));
            agents.add(new Agent(0.5, sampledPoints.size() - 2, sampledPoints.size() - 1, color(random(256), random(256), random(256))));
            
            
            // last agent added - so move to the add obstacles state
            if (sampledPoints.size() == agentsCount * 2) {
                mode = SimulationState.addObstacles;
            }
        }
        
    } else if (mode == SimulationState.addObstacles) {
        obstacles.add(new Obstacle(mousePosition(), 1));
    }
}


PVector mouseDownPosition;
Obstacle currentlyMovedObstacle = null;

void mousePressed() {
    if (mode == SimulationState.addObstacles) {
        
        PVector mouse = mousePosition();
        
        for(int i = 0; i < obstacles.size(); i++) {
            if (PVector.dist(obstacles.get(i).position, mouse) < obstacles.get(i).radius) {
                mouseDownPosition = mousePosition();
                currentlyMovedObstacle = obstacles.get(i);
                break;
            }
        }
    }
}

void mouseDragged() {
    if (mode == SimulationState.addObstacles && currentlyMovedObstacle != null) {
        PVector positionDifference = PVector.sub(mousePosition(), currentlyMovedObstacle.position);
    }
}


void mouseReleased() {
    if (mode == SimulationState.addObstacles && currentlyMovedObstacle != null) {
        currentlyMovedObstacle = null;
    }
}
