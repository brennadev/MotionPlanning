// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

class Agent {
    float radius;
    PVector currentPosition;
    PVector initialPosition;
    PVector finalPosition;
    
    Agent(float radius, PVector initialPosition, PVector finalPosition) {
        this.radius = radius;
        currentPosition = new PVector(initialPosition.x, initialPosition.y);   // need a copy here since this will get modified as the program runs
        this.initialPosition = initialPosition;
        this.finalPosition = finalPosition;
    }
}
