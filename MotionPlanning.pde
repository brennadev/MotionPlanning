// Copyright 2019 Brenna Olson. You may download this code for informational purposes only.

/////////////// Room ///////////////

// x and y dimensions of room (same dimensions along each axis)
final float roomSize = 20;
// how many times bigger to make everything when rendering so it can be easily seen
final float scale = 30;

/////////////// Obstacle ///////////////
final float obstacleRadius = 2;
final Position2D obstaclePosition = new Position2D(0, 0);


/////////////// Character ///////////////

// character starts here
final Position2D characterInitialPosition = new Position2D(-9, -9);

// character's goal
final Position2D characterFinalPosition = new Position2D(9, 9);

// where character currently is located on map
Position2D characterCurrentPosition = new Position2D(characterInitialPosition);

/////////////// Motion Planning ///////////////

final int samplePointsCount = 20;
// points from random sampling to create potential paths
Position2D[] sampledPoints = new Position2D[samplePointsCount];


void setup() {
    size(600, 600, P2D);
}


void draw() {
    background(0);
    
    circle(obstaclePosition.x * scale, obstaclePosition.y * scale, obstacleRadius * scale);
    
    
}

void generateSamplePoints() {
    for(int i = 0; i < samplePointsCount; i++) {
        
    }
}

// find where the lines between the sample points should go
void connectSamplePoints() {
    
}
