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
//final int edgeCount = 190;    // based on 20 points
int edgeCount = 190;
//final int edgeCount = 10;

// points from random sampling to create potential paths
PVector[] sampledPoints = new PVector[samplePointsCount];
Edge[] edges = new Edge[edgeCount];


// TODO: probably need a limit on how many edges to travel (what goes as the size of edgesToTravel since I just stuck a value in for now)
int edgesToTravelCount = 0;    // TODO: of course this value needs to be changed (and it'll get set at a later point anyway, so the value here may not matter)
Edge[] edgesToTravel = new Edge[10];


void setup() {
    size(600, 600, P2D);
    noStroke();
    
    generateSamplePoints();
    connectSamplePoints();
    
}


void draw() {
    // TODO: code for moving character along path here
    
    
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
            float t = 9e9;
            // only want to include the edge if it's not colliding with the obstacle
            if (!edgeHitsObstacle(sampledPoints[i], PVector.sub(sampledPoints[j], sampledPoints[i]), t)) {
                edges[index] = new Edge(i, j);
                index++;
            }
            
        }
    }
    
    edgeCount = index;
}

// ray-object intersection test to check for edges that intersect the obstacle; adapted from my 5607 ray tracer
boolean edgeHitsObstacle(PVector origin, PVector direction, Float t) {
    float a = 1;
    float b = 2 * PVector.dot(direction, PVector.sub(origin, obstaclePosition));
    float c = pow(PVector.sub(origin, obstaclePosition).mag(), 2) - pow(obstacleRadius, 2);
    
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
