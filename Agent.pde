// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Agent {
    float radius;
    PVector currentPosition;
    PVector initialPosition;
    PVector finalPosition;
    // immediate point the character is after (or at)
    SampledPoint currentPoint = null;
    // how far along the edge after currentPoint the character currently is
    float scalarDistanceFromCurrentPoint = 0;   
    // indicates when at the end of the path
    boolean isAtEnd = false;                
    
    Agent(float radius, PVector initialPosition, PVector finalPosition) {
        this.radius = radius;
        currentPosition = new PVector(initialPosition.x, initialPosition.y);   // need a copy here since this will get modified as the program runs
        this.initialPosition = initialPosition;
        this.finalPosition = finalPosition;
    }
}
