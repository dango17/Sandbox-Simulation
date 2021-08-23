final int WIDTH = 526;
final int HEIGHT = 256; 
final int SCALE_FACTOR = 4;

final byte AIR = 0; 
final byte ROCK = 1; 
final byte SAND = 2; 
final byte WATER = 3; 

byte[] world; 

PGraphics worldGfx; 

//Called once at start of the program
void setup()
{ 
  size(1024, 1024, P3D); 
  
  worldGfx = createGraphics(WIDTH, HEIGHT); 
  ((PGraphicsOpenGL)g).textureSampling(2); //Stop processing applying smoothness when scaling
  
  world = new byte[WIDTH*HEIGHT]; 
  
  //Set a floor for elements to land on
  for(int y=HEIGHT-10; y<HEIGHT; ++y) {
  for(int x=0; x<WIDTH; ++x) {
    //Set our world boundary for the rock (Floor)
    world[coord(x,y)] = ROCK; 
  }
 }
 
 //Add some sand into world 
 for(int y=100; y<110; ++y) {
 for(int x=100; x<110; ++x) {
    //Set sand position in world
    world[coord(x,y)] = SAND; 
  }
 }
} 

void draw()
{  
  
  //Update our world 
  for (int y=0; y<HEIGHT; ++y){
    for (int x=0; x<WIDTH; ++x){
      int coordHere = coord(x,y); 
      //Check each pixel avaliable in world 
      byte whatHere = world[coordHere]; 
      if(whatHere == AIR || whatHere == ROCK) continue; 
      
      //Tile is free, move down 
      if(tileIsFree(x, y+1))
      {  
        move(x, y, x, y+1); 
      } 
      //next, try to move down or left
      else if(tileIsFree(x-1, y+1))
      { 
        move(x, y, x-1, y+1); 
      } 
      else if (tileIsFree(x+1, y+1))
      { 
        move(x, y, x+1, y+1); 
      } 
    }
  }
  
  //Draw our world
  worldGfx.beginDraw(); 
  worldGfx.loadPixels();
  for (int y=0; y<HEIGHT; ++y){
    for (int x=0; x<WIDTH; ++x){
      int coordHere = coord(x,y);
      
      byte whatHere = world[coordHere]; 
      color c; 
     
     //Set our Pixles
      switch(whatHere) { 
        case AIR: c = color(0, 0, 0); break; //White Colour
        case ROCK: c = color (128 ,128, 128); break; //Grey Colour
        case WATER: c = color (0, 0 ,255); break; //Blue Colour
        case SAND: c = color (225, 255, 0); break; //Yellow Colour
        default: c = color (255,0, 0); break; //Red Colour (Somethings gome wrong)
    }
    
    worldGfx.pixels[coordHere] = c; 
  }
 }
  
  worldGfx.updatePixels(); 
  worldGfx.endDraw(); 
  
  scale(SCALE_FACTOR); 
  image(worldGfx, 0, 0); 
} 


void move(int fromX, int fromY, int toX, int toY)
{ 
  int fromCoord = coord(fromX, fromY);
  int toCoord = coord(toX, toY); 
  world[toCoord] = world[fromCoord]; 
  world[fromCoord] = AIR;
} 

//Check if tiles are free for our elements to move into
boolean tileIsFree(int x, int y) 
{  
  //Dont want pixels to fall outside the boundarys of the screen
   if(x<0 || x>=WIDTH || y<0 || y>=HEIGHT) return false; 
   return world[coord(x,y)] == AIR;
}

//Set our world array 
int coord(int x, int y)
{ 
  return x + y*WIDTH; 
} 
