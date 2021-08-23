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
  
  world = new byte[WIDTH*HEIGHT]; 
  
  //Set a floor for elements to land on
  int y = HEIGHT-1; //Bottom Row
  for(int x=0; x<WIDTH; ++x)
  {  
    //Set our world boundarys
    world[coord(x,y)] = ROCK; 
  }
} 

void draw()
{  
  //Draw our world
  //worldGfx.beginDraw(); 
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
  //worldGfx.endDraw(); 
  
  scale(SCALE_FACTOR); 
  image(worldGfx, 0, 0);
  
} 

//Set our world array 
int coord(int x, int y)
{ 
  return x + y*WIDTH; 
} 
