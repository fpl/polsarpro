#define _CRT_SECURE_NO_DEPRECATE

#ifndef WINBOX_H
#define WINBOX_H

#define GLEW_STATIC

#include <GL/glew.h>
#include <GL/freeglut.h>
#include <math.h>
#include <stdio.h>
#include <list>
#include <vector>
#include <memory>
#include "shaders.h"
#include "textures.h"
#include "polygons.h"
#include "utils.h"
#include "vmenu.h"   
#include "textures.h"
#include "algebra.h"

#ifdef __WIN32
#define THREADRETV void
#include <windows.h>
#include <process.h>    /* _beginthread, _endthread */
#else
#include <pthread.h> /* pthread */
#include <unistd.h> 
#define THREADRETV void*
#endif

#ifndef _MAX_PATH
#define _MAX_PATH 1024
#endif

#ifndef M_PI
#define M_PI 3.141597
#endif

#define ONOFF(x) ((x) ? "ON" : "OFF")

#ifndef max
#define max(x,y) (x)>(y) ? (x) : (y)
#define min(x,y) (x)<(y) ? (x) : (y)
#endif


typedef unsigned int uint;

//predefinitions
void showGlutWindow(int , char**);
void initOpenGL();
void initShader();
void runOpenGL();
void timerEvent(int value);
void draw_func( void );
void close_func( void );
void key_func(unsigned char, int, int);
void keySpec_func(int key, int x, int z);
void mouse_func(int button, int state, int x, int y);
void motion_func(int x, int y);
void passiveMotion_func(int x,int y);
void reshape(int w, int h);
void setCamera();
void setCamera(int c);
void resetViz();

void setCenterPoint();
void drawTexts();
void drawFrames();
void drawGrid(POINT );
void drawTextNumber(int i, ImageTex *it);
void drawTextureMap(ImageTex*, int i);
void drawMagnifications(FPOINT pos, int slice);
/*Modif EP - start*/
void drawTexts_EP(ImageTex *it, int ii);
/*Modif EP - end*/

void updateMenuChanges();
void menuCallback(int v);
void grabScreen();
void getPoint(int x, int y);
void warningOn();
void toggleFilterMode(); 
extern void memoryUsage();
void zoomView(int screenX, int screenY, float f);
void propagateSliceView(int src);

//input method
void inputConfirmed();
void performPendingOperation(int newSlice); 
void openFile();

THREADRETV openThread(void * parg);
THREADRETV saveThread(void * parg);
THREADRETV savePolygons();
THREADRETV savePolygonsThread(void * parg);
THREADRETV savePolygons_OPCE();
THREADRETV savePolygonsThread_OPCE(void * parg);
THREADRETV savePolygons_StatHistoROI();
THREADRETV savePolygonsThread_StatHistoROI(void * parg);
THREADRETV savePolygons_MaskArea();
THREADRETV savePolygonsThread_MaskArea(void * parg);
THREADRETV savePolygons_TrainingArea();
THREADRETV savePolygonsThread_TrainingArea(void * parg);
void runInThread(THREADRETV(*_StartAddress) (void *));

#endif
