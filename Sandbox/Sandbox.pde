final int WIDTH = 526;
final int HEIGHT = 256; 
final int SCALE_FACTOR = 4;

final byte AIR = 0; 
final byte ROCK = 1; 
final byte SAND = 2; 
final byte WATER = 3; 

//Store our world elements 
byte[] world; 

//GPU
PGraphics worldGfx; 

//Has Moved Boolean
boolean[] hasMovedFlag; 

//Track Momentum of each pixel 
int[] momentum; 

//
int brushSize = 1;

//Called once at start of the program
void setup()
{ 
  size(1024, 1024, P3D); 
  
  worldGfx = createGraphics(WIDTH, HEIGHT); 
  ((PGraphicsOpenGL)g).textureSampling(2); //Stop processing applying smoothness when scaling
  
  world = new byte[WIDTH*HEIGHT]; 
  hasMovedFlag = new boolean[WIDTH*HEIGHT]; 
  momentum = new int[WIDTH*HEIGHT];
  
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
 
 //Slow down frame rate to 1-fps
 frameRate(30); 
} 

void draw()
{  
  
  //Mouse Button Logic
  if(mousePressed)
  { 
    int mouseXInWorld = mouseX / SCALE_FACTOR; 
    int mouseYInWorld = mouseY / SCALE_FACTOR; 
    
    //Left Click down = Sand
    if(mouseButton == LEFT)
    { 
      place(SAND, mouseXInWorld, mouseYInWorld);
    } 
    else if(mouseButton == CENTER)
    { 
      place(ROCK, mouseXInWorld, mouseYInWorld); 
    }
    //Right Click donw = water
    else if (mouseButton == RIGHT)
    { 
      place(WATER, mouseXInWorld, mouseYInWorld);
    } 
    
  } 
  
  
  //Clear hasMovedFlag 
  for (int y=0; y<HEIGHT; ++y){
    for (int x=0; x<WIDTH; ++x){
      hasMovedFlag[coord(x,y)] = false;
    }
  }
  
  
  //Update our world 
  for (int y=HEIGHT-1; y>=0; --y){
    for (int x=0; x<WIDTH; ++x){
      int coordHere = coord(x,y); 
      if(hasMovedFlag[coordHere]) continue; 
      //Check each pixel avaliable in world 
      byte SubstanceHere = world[coordHere]; 
      if(SubstanceHere == AIR || SubstanceHere == ROCK) continue; 
      
      //Tile is free, move down 
      if(canMove(SubstanceHere, x, y+1))
      {  
        move(x, y, x, y+1); 
      } 
      
      //Randomly check if down or right is free to move too
      boolean checkLeftFirst; 
      if(momentum[coordHere] == -1) {checkLeftFirst = true; }
      else if(momentum[coordHere] == 1) {checkLeftFirst = false; }
      else { checkLeftFirst = (random(1f)<0.5f); }
      
      //Sand Pixel behaviour
      if(checkLeftFirst)
      { 
         if(canMove(SubstanceHere, x-1, y+1))
         { 
         move(x, y, x-1, y+1); 
         } 
         else if (canMove(SubstanceHere, x+1, y+1))
         { 
         move(x, y, x+1, y+1); 
         } 
      }   
      else
      { 
        if(canMove(SubstanceHere, x+1, y+1))
        { 
          move(x, y, x+1, y+1);
        } 
        else if(canMove(SubstanceHere, x-1, y+1))
        { 
          move(x, y, x-1, y+1); 
        } 
      } 
      
      //Water Pixel behaviour
      if(SubstanceHere == WATER && y<HEIGHT-1 && world[coord(x,y+1)] == WATER)
      { 
        //Above layer of water, spead the pixels out across them left & right
       if(checkLeftFirst)
       { 
         if(canMove(SubstanceHere, x-1, y))
         { 
         move(x, y, x-1, y); 
         } 
         else if (canMove(SubstanceHere, x+1, y))
         { 
         move(x, y, x+1, y); 
         } 
      }  
      else 
      { 
        if(canMove(SubstanceHere, x+1, y))
        { 
          move(x, y, x+1, y); 
        }  
        else if(canMove(SubstanceHere, x+1, y))
        { 
          move(x, y, x-1, y); 
        } 
      }
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


//Paint Brush Function 
void mouseWheel(MouseEvent event)
{  
   if(event.getCount() < 0)
   { 
     ++brushSize; 
   } 
   else
   { 
     --brushSize; 
     if(brushSize <=0) { brushSize = 1; } 
   }  
    println("Brush size:" + brushSize); 
} 

void place(byte substance, int xPos, int yPos)
{  
  for(int y=max(0, yPos-brushSize); y<min(HEIGHT-1, yPos+brushSize); ++y){
    for(int x=max(0, xPos-brushSize); x<min(HEIGHT-1, xPos+brushSize); ++x){
      world[coord(x,y)] = substance; 
  }
 }
}  
  

//Move our pixels within the world
void move(int fromX, int fromY, int toX, int toY)
{ 
  int fromCoord = coord(fromX, fromY);
  int toCoord = coord(toX, toY); 
  
  byte otherSubstance = world[toCoord]; 
  
  world[toCoord] = world[fromCoord]; 
  world[fromCoord] = otherSubstance;
  
  hasMovedFlag[toCoord] = true;
  hasMovedFlag[fromCoord] = true;
  
  momentum[fromCoord] = 0; 
  
  if (toX > fromX) { momentum[toCoord] = 1; }
  else if (toX < fromX) { momentum[toCoord] = -1; }
  else { momentum[toCoord] = 0; }
} 

//Check if tiles are free for our elements to move into
boolean canMove(byte substance, int x, int y) 
{  
  //Dont want pixels to fall outside the boundarys of the screen
   if(x<0 || x>=WIDTH || y<0 || y>=HEIGHT) return false; 
   byte otherSubstance = world[coord(x,y)]; 
   if(otherSubstance == AIR) return true; 
   
   //precipitate the sand when with water 
   if(substance == SAND && otherSubstance == WATER && random(1f)<0.5f) return true; 
   return false; 
}

//Set our world array 
int coord(int x, int y)
{ 
  return x + y*WIDTH; 
} 
