// Copyright 2019 Brenna Olson. You may download this code for informational purposes only.

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

final int samplePointsCount = 20;
//final int samplePointsCount = 5;
final int edgeCount = 190;    // based on 20 points
//final int edgeCount = 10;

// points from random sampling to create potential paths
PVector[] sampledPoints = new PVector[samplePointsCount];
Edge[] edges = new Edge[edgeCount];


void setup() {
    size(600, 600, P2D);
    noStroke();
    
    generateSamplePoints();
    connectSamplePoints();
    
}


void draw() {
    background(0);
    fill(255);
    noStroke();
    circle(obstaclePosition.x * scale + originToCenterTranslation, obstaclePosition.y * scale * -1 + originToCenterTranslation, obstacleRadius * scale);
    
    fill(255, 0, 0);
    
    for(int i = 0; i < samplePointsCount; i++) {
        circle(sampledPoints[i].x * scale + originToCenterTranslation, sampledPoints[i].y * scale * -1 + originToCenterTranslation, 15);
    }
    
    stroke(0, 200, 255);
    for(int i = 0; i < edgeCount; i++) {
        line(sampledPoints[edges[i].point1].x * scale + originToCenterTranslation, 
             sampledPoints[edges[i].point1].y * scale * -1 + originToCenterTranslation, 
             sampledPoints[edges[i].point2].x * scale + originToCenterTranslation, 
             sampledPoints[edges[i].point2].y * scale * -1 + originToCenterTranslation);
    }
}


// get the sample points for the path
void generateSamplePoints() {
    for(int i = 0; i < samplePointsCount; i++) {
        PVector newPoint;
        
        do {
            newPoint = new PVector(random(-roomSize / 2, roomSize / 2), random(-roomSize / 2, roomSize / 2));
        } while (newPoint.dist(obstaclePosition) <= obstacleRadius);
        
        sampledPoints[i] = newPoint;
    }
}


// find where the lines between the sample points should go
void connectSamplePoints() {
    int index = 0;
    for(int i = 0; i < samplePointsCount; i++) {
        for(int j = i + 1; j < samplePointsCount; j++) {
            println(i);
            println(j);
            println();
            edges[index] = new Edge(i, j);
            index++;
        }
    }
}
