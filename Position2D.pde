class Position2D {
    
    Position2D(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    // copy constructor
    Position2D(Position2D position) {
        x = position.x;
        y = position.y;
    }
    
    float x;
    float y;
}
