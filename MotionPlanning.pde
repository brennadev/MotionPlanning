// Copyright 2019 Brenna Olson. You may download this code for informational purposes only.

import java.util.LinkedList;
import java.util.ArrayList;

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
//final int edgeCount = 190;    // based on 20 points
//int edgeCount = 190;
int edgeCount = 21;

// points from random sampling to create potential paths
//SampledPoint[] sampledPoints = new SampledPoint[samplePointsCount + 2];    // need to account for start and end points in here too
ArrayList<SampledPoint> sampledPoints = new ArrayList();

//PVector[] sampledPoints = new PVector[samplePointsCount];
Edge[] edges = new Edge[edgeCount];
Edge[] shortestPath = new Edge[edgeCount];
int shortestPathEdgeCount = 0;    // will get incremented once the path is found


// TODO: probably need a limit on how many edges to travel (what goes as the size of edgesToTravel since I just stuck a value in for now)
int edgesToTravelCount = 0;    // TODO: of course this value needs to be changed (and it'll get set at a later point anyway, so the value here may not matter)
Edge[] edgesToTravel = new Edge[10];


void setup() {
    size(600, 600, P2D);
    noStroke();
    
    sampledPoints.add(new SampledPoint(characterInitialPosition, NodeColor.gray, 0));                   // start node
    sampledPoints.add(new SampledPoint(characterFinalPosition, NodeColor.white, Integer.MAX_VALUE));    // end node
    
    generateSamplePoints();
    connectSamplePoints();
    findShortestPath();
    
    for(int i = 0; i < samplePointsCount + 2; i++) {
        //println(sampledPoints[i].nodeColor);
    }
    
    println(shortestPathEdgeCount);
    
}


void draw() {
    // TODO: code for moving character along path here
    
    
    background(0);
    fill(255);
    noStroke();
    circle(obstaclePosition.x * scale + originToCenterTranslation, obstaclePosition.y * scale * -1 + originToCenterTranslation, obstacleRadius * scale);
    circle(characterInitialPosition.x * scale + originToCenterTranslation, characterInitialPosition.y * scale * -1 + originToCenterTranslation, 15);
    circle(characterFinalPosition.x * scale + originToCenterTranslation, characterFinalPosition.y * scale * -1 + originToCenterTranslation, 15);
    
    
    fill(255, 0, 0);
    
    for(int i = 0; i < samplePointsCount; i++) {
        circle(sampledPoints.get(i + 2).position.x * scale + originToCenterTranslation, sampledPoints.get(i + 2).position.y * scale * -1 + originToCenterTranslation, 15);
        //circle(sampledPoints[i].x * scale + originToCenterTranslation, sampledPoints[i].y * scale * -1 + originToCenterTranslation, 15);
        //println("x: " + sampledPoints[i].x);
        //println("y: " + sampledPoints[i].y);
    }
    
    stroke(0, 200, 255);
    for(int i = 0; i < edgeCount; i++) {
        line(sampledPoints.get(edges[i].point1).position.x * scale + originToCenterTranslation, 
             sampledPoints.get(edges[i].point1).position.y * scale * -1 + originToCenterTranslation, 
             sampledPoints.get(edges[i].point2).position.x * scale + originToCenterTranslation, 
             sampledPoints.get(edges[i].point2).position.y * scale * -1 + originToCenterTranslation);
        /*line(sampledPoints[edges[i].point1].x * scale + originToCenterTranslation, 
             sampledPoints[edges[i].point1].y * scale * -1 + originToCenterTranslation, 
             sampledPoints[edges[i].point2].x * scale + originToCenterTranslation, 
             sampledPoints[edges[i].point2].y * scale * -1 + originToCenterTranslation);*/
             
             
        /*println("edge point 1 x: " + sampledPoints[edges[i].point1].x);
        println("edge point 1 y: " + sampledPoints[edges[i].point1].y);
        println("edge point 2 x: " + sampledPoints[edges[i].point2].x);
        println("edge point 2 y: " + sampledPoints[edges[i].point2].y);*/
    }
}


// get the sample points for the path
void generateSamplePoints() {
    for(int i = 0; i < samplePointsCount; i++) {
        PVector newPoint;
        
        do {
            newPoint = new PVector(random(-roomSize / 2, roomSize / 2), random(-roomSize / 2, roomSize / 2));
        } while (newPoint.dist(obstaclePosition) <= obstacleRadius);
        
        sampledPoints.add(new SampledPoint(newPoint, NodeColor.white, Integer.MAX_VALUE));
        //sampledPoints[i] = newPoint;
    }
}




// find where the lines between the sample points should go
void connectSamplePoints() {
    int index = 0;
    for(int i = 0; i < samplePointsCount + 2; i++) {
        for(int j = i + 1; j < samplePointsCount + 2; j++) {
            float t = 9e9;
            // only want to include the edge if it's not colliding with the obstacle
            if (!edgeHitsObstacle(sampledPoints.get(i).position, PVector.sub(sampledPoints.get(j).position, sampledPoints.get(i).position), t)) {
            //if (!edgeHitsObstacle(sampledPoints[i], PVector.sub(sampledPoints[j], sampledPoints[i]), t)) {
                edges[index] = new Edge(i, j);
                
                sampledPoints.get(i).addAdjacentNode(sampledPoints.get(j));
                sampledPoints.get(j).addAdjacentNode(sampledPoints.get(i));
                
                index++;
            }
            
        }
    }
    
    edgeCount = index;
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
    LinkedList<SampledPoint> q = new LinkedList();
    
    q.addLast(sampledPoints.get(0));
    
    
    // need to make a copy of sampledPoints (defined earlier in program) so that draw works correctly as it uses that array
    SampledPoint[] qNew = new SampledPoint[samplePointsCount + 2];
    
    // the sorted list needs to go here
    for(int i = 0; i < samplePointsCount + 2; i++) {
        qNew[i] = sampledPoints.get(i);
    }
    
    int qCurrentCount = samplePointsCount + 2;
    
    while (!q.isEmpty()) {
        SampledPoint u = q.removeFirst();
        
        // extract min - I think it looks through all the vertices; finds smallest d; seems like it probably removes it from the queue 
        // since it goes until the queue is empty (what the while condition checks)
        // need to make a copy of sampledPoints - this goes outside the loop in this function
        // how to get minimum distance - will just need to iterate over the array or whatever way the stuff is stored on each loop 
        // iteration (otherwise would need to run a sort algorithm first)
        
        float shortestDistance = Float.MAX_VALUE;
        
        
        for(int i = 0; i < qCurrentCount; i++) {
            
        }
        
        // sorted list goes above
        // now need to know which nodes have been removed - so the list might need to be sorted first (and of course, Java should have something to do that)
        // sort the list so the shortest distance nodes are last in the list so they're easy to remove
        
        qCurrentCount--;
        
        // add to shortest path if necessary
        shortestPathEdgeCount++;    // needs to go in the if
        
        for(int i = 0; i < u.adjacentNodeCount; i++) {
            
            relax(u, u.adjacentNodes[i]);
            
            /*if (u.adjacentNodes[i].nodeColor == NodeColor.white) {
                u.adjacentNodes[i].distance = u.distance + 1;
                u.adjacentNodes[i].predecessor = u;
                q.addLast(u.adjacentNodes[i]);
            }*/
        }
        
       
        
        
        u.nodeColor = NodeColor.black;
    }
    
}


void relax(SampledPoint from, SampledPoint to) {
    float distance = abs(PVector.dist(from.position, to.position));
    
    if (to.distance > from.distance + distance) {
        to.distance = from.distance + distance;
        to.predecessor = from;
    }
}
