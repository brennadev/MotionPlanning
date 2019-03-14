// Copyright 2019 Brenna Olson. You may download this code for informational purposes only.

final float roomSize = 20;
final float obstacleRadius = 2;
final Position2D obstaclePosition = new Position2D(0, 0);

// how many times bigger to make everything when rendering so it can be easily seen
final float scale = 30;

// character starts here
final Position2D characterInitialPosition = new Position2D(-9, -9);

// character's goal
final Position2D characterFinalPosition = new Position2D(9, 9);

// where character currently is located on map
Position2D characterCurrentPosition = new Position2D(characterInitialPosition);

void setup() {
    size(600, 600, P2D);
}


void draw() {
    background(0);
    
    circle(obstaclePosition.x * scale, obstaclePosition.y * scale, obstacleRadius * scale);
    
    
}
