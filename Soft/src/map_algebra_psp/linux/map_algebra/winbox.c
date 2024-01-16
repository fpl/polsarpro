#include "winbox.h"	  

#define REFRESH_DELAY 30
#define XYZ_SIZE 42


	//variables
	int tick = 0;
	unsigned int fpsCount = 0;

	int grid=0;
	int help=0;
	int quit = 0;
	int warning = 0;
	float textColor = 0;

	int cameraMoving = 0;

	int saveToClipboard = 0;

	int equalSizes = 0;
	//0 for vertical 1 for horizontal
	int orientation = 0;
	

	std::vector<FPOINT3> ct;
	std::vector<POINT3> cr;
	std::vector<POINT3> c;
	int linked=1;

	int slice = 0;
	//
	int nrObrazka=0;
	//new view
	std::vector<FPOINT3> t;
	std::vector<POINT3> r;
    int menuChanged=1;

	MOUSE_EVENT_RECORD mer;
	std::vector<FPOINT> zoomPoint;
	FPOINT world;
	POINT mscreen;

	unsigned int ScreenWidth = 768;
	unsigned int ScreenHeight = 768;
	float aspect = 1;//(float)ScreenWidth/(float)ScreenHeight;
	int allocated=0; 
	//----


	int numberOfSlices = 0;
	int updatePoint = 1;

	float* tmp=NULL;
	GLUquadric* glutmp=NULL;

	//input
	int inputMode=0;
	int inputCount=0;
	char _string[128];
	char prompt[128];
	int pendingOperation;
    float pixel_color[3];

    int removeMode=0;

	//polygon mode
	//GLuint polygonlistid;
	std::vector<GLuint> polygonlistids;
	int polygonMode = 0;
	std::vector<std::list<FPOINT> > polygons;

	//polygon mode OPCE
	//GLuint polygonlistid;
	std::vector<GLuint> polygonlistids_OPCE_TGT;
	std::vector<GLuint> polygonlistids_OPCE_CLT;
	int polygonMode_OPCE_TGT = 0;
	int polygonMode_OPCE_CLT = 0;
	std::vector<std::list<FPOINT> > polygons_OPCE_TGT;
	std::vector<std::list<FPOINT> > polygons_OPCE_CLT;

	//polygon mode Stat Histo ROI
	//GLuint polygonlistid;
	std::vector<GLuint> polygonlistids_StatHistoROI;
	int polygonMode_StatHistoROI = 0;
	std::vector<std::list<FPOINT> > polygons_StatHistoROI;

	//polygon mode Mask Area
	//GLuint polygonlistid;
	std::vector<GLuint> polygonlistids_MaskArea;
	int polygonMode_MaskArea = 0;
	std::vector<std::list<FPOINT> > polygons_MaskArea;

	//polygon mode Training Area
	//GLuint polygonlistid;
	std::vector<GLuint> polygonlistids_TrainingArea;
	int polygonMode_TrainingArea = 0;
	std::vector<std::list<FPOINT> > polygons_TrainingArea;

	//Textures	
	std::vector<ImageTex*> imageTexs;  

	// operations
	int selectedSlice[2] = { -1 };
	int selectMode = 0;
	int sliceOver = -1;
	int opParam;

	volatile int semaphore = 0;
	int errortest=0; 
	int showMagnification = 0;
	//shader stuff
	GLuint g_program = 0;
	static GLuint g_programBrightness;
	static GLuint g_programBSize;
	static GLuint g_programTexSize;
	static GLuint g_programRGB;
	//for shader on cpu
	float g_brightness = 0;
	int g_bsize = 0;
	int g_TexSize[3] = {0};
	float g_RGB[3] = { 1, 1, 1 };
	//backgroundCheck
	volatile int backgroundChecking = 0;
	extern char* tempDir;	 
	extern char* appPath;
    
/*Modif EP - start*/
	extern char PSPtmpFile[MAX_PATH];
	extern char PSPtmpFileOPCE[MAX_PATH];
	extern char PSPtmpFileStatHistoROI[MAX_PATH];
	extern char PSPtmpFileMaskArea[MAX_PATH];
	extern char PSPtmpFileTrainingArea[MAX_PATH];
    extern char PSPMapAlgebraMode[100];
    extern int PSPScreenWidth;
    extern int PSPScreenHeight;
    extern int PSPScreenWidthOffset;
    extern int PSPScreenHeightOffset;
    extern int ScreenWidthPSP;
    extern int ScreenHeightPSP;
	extern int TrainingAreaClass;
	extern int TrainingAreaClassArray[20];
/*Modif EP - end*/    

	//----------------------------------------------------------

	void addImageTex(ImageTex *tmpImageTex)
	{ 
/*Modif EP - start*/
        if (numberOfSlices != 0)
        {
            if (orientation == 0)
            {
                glutReshapeWindow(ScreenWidthPSP + numberOfSlices*ScreenWidthPSP/2, ScreenHeightPSP);
            } else {
                glutReshapeWindow(ScreenWidthPSP, ScreenHeightPSP + numberOfSlices*ScreenHeightPSP/2);
            }
        }
/*Modif EP - end*/
		imageTexs.push_back(tmpImageTex);
		if (t.size() == 0)
		{
			t.resize(t.size() + 1);
			r.resize(r.size() + 1);
			ct.resize(ct.size() + 1);
			cr.resize(cr.size() + 1);
			c.resize(c.size() + 1);
			zoomPoint.resize(zoomPoint.size() + 1);
		}
		else
		{
			t.push_back(t.back());
			r.push_back(r.back());
			ct.push_back(ct.back());
			cr.push_back(cr.back());
			c.push_back(c.back());
			zoomPoint.push_back(zoomPoint.back());
		}
		numberOfSlices++; 
	}
	void removeImageTex(int i)
	{
		if (imageTexs.size() == 1)
		{
			tinyfd_messageBox("Image closing", "Cannot close last image.\n", "ok", "info", 1);
			return;
		}
		delete imageTexs[i];

		imageTexs.erase(imageTexs.begin() + i);
		t.erase(t.begin() + i);
		r.erase(r.begin() + i);
		ct.erase(ct.begin() + i);
		cr.erase(cr.begin() + i);
		c.erase(c.begin() + i);
		zoomPoint.erase(zoomPoint.begin() + i);
		numberOfSlices--;
/*Modif EP - start*/
        if (orientation == 0)
        {
            glutReshapeWindow(ScreenWidthPSP + (numberOfSlices-1)*ScreenWidthPSP/2, ScreenHeightPSP);
        } else {
            glutReshapeWindow(ScreenWidthPSP, ScreenHeightPSP + (numberOfSlices-1)*ScreenHeightPSP/2);
        }
/*Modif EP - end*/
	}
	void backgroundCheck()
	{
		unsigned int i = 0;
        int AlreadyLoaded = 0;
        int SliceRemove;
		FILE *f;
		char buf[_MAX_PATH];
		char buf2[_MAX_PATH];
        
/*Modif EP - start*/
        strcpy(buf,PSPtmpFile);
/*Modif EP - end*/
        
		if (fileExists(buf))
		{
			backgroundChecking = 1;
			if ((f = fopen(buf, "rt")) != NULL)
			{
				while (!feof(f))
				{
					buf2[0] = '\0';
					fgets(buf2, _MAX_PATH, f);
/*Modif EP - start*/                  
                    if (strcmp(buf2,"quit\n") == 0) 
                    {
                        fclose(f);
                        unlink(buf);
                        exit(1);
                    }
                    if (strcmp(buf2,"load\n") == 0) 
                    {
                        fgets(buf2, _MAX_PATH, f);
                        PSP_check_file(buf2);
                        AlreadyLoaded = 0;
                        for (i = 0; i < imageTexs.size(); i++)
                        {
                            if (strncmp(imageTexs[i]->path, buf2, strlen(imageTexs[i]->path)) == 0) AlreadyLoaded = 1;
                        }
                        if (AlreadyLoaded == 0 && fileExists(buf2))
                        {
                            addImageTex(ImageTex::loadImage(buf2));
                        }
                    }

                    if (strcmp(buf2,"remove\n") == 0) 
                    {
                        fscanf(f, "%i\n", &SliceRemove);
                        SliceRemove--;
                        if (imageTexs.size() > 1 && SliceRemove <= (int)imageTexs.size()) 
                        {
                            removeImageTex(SliceRemove);
                        }
                    }
                    
/*Modif EP - end*/    
				}
			}		
			fclose(f);
			unlink(buf);
			backgroundChecking = 0;
		}
	}
	void showGlutWindow(int v, char** args)
	{ 
		int i = 0; 
		_string[0] = '\0'; 
        
        FILE *fileinput;
        char path_hdr[_MAX_PATH];
        char Buf[65536];
        char Tmp[65536];
        char *p1;
        int ImageWidth;
        int ImageHeight;
        
        sprintf(path_hdr, "%s.hdr", args[1]);
        fileinput = fopen(path_hdr,"r");
        rewind(fileinput);
        while( !feof(fileinput) )
        {
            fgets(&Buf[0], 65536, fileinput); 
            if (strstr(Buf,"samples") != NULL)
            {
                p1 = strstr(Buf," = ");
                strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
                ImageWidth = atoi(Tmp);
            }
            if (strstr(Buf,"lines") != NULL)
            {
                p1 = strstr(Buf," = ");
                strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
                ImageHeight = atoi(Tmp);
            }
        }
        fclose(fileinput);

		//check sizes:
		ImageTex::checkImagesSizes(args + 1, v - 1, &orientation);
				
		//Load textures 
		for (i = 0; i < v - 1; i++)
		{
			if (fileExists(args[i + 1]))
			{
				addImageTex(ImageTex::loadImage(args[i + 1]));
			}
			else
			{
				char message[128];
				sprintf(message, "File not found:\n%s\n\n", args[i + 1]);
				tinyfd_messageBox("File opening", message, "ok", "info", 1);
				exit(-1);
			}
		}

        ScreenWidth  = PSPScreenWidth;
        ScreenHeight  = PSPScreenHeight;        
        if (ImageHeight > ImageWidth)
        {
            ScreenWidthPSP = floor(PSPScreenHeight * ImageWidth / ImageHeight);
            ScreenHeightPSP = PSPScreenHeight;
        } else {
            ScreenHeightPSP = floor(PSPScreenWidth * ImageHeight / ImageWidth);
            ScreenWidthPSP = PSPScreenWidth;
        }
        ScreenWidth  = ScreenWidthPSP;
        ScreenHeight  = ScreenHeightPSP;    
        
		initOpenGL();
		initShader();
		runOpenGL();
        
		//exiting...
		tempFileRemove();
	}
	void initShader()
	{
		GLint result;
		char tmp[MAX_PATH];
		/* create program object and attach shaders */
		g_program = glCreateProgram();
		sprintf(tmp, "%s%c%s", appPath, PATH_SEPARATOR, "shaders/cs_vertex.glsl");
		shaderAttachFromFile(g_program, GL_VERTEX_SHADER, tmp);
		sprintf(tmp, "%s%c%s", appPath, PATH_SEPARATOR, "shaders/cs_fragment.glsl");
		shaderAttachFromFile(g_program, GL_FRAGMENT_SHADER, tmp);

		/* link the program and make sure that there were no errors */
		glLinkProgram(g_program);
		glGetProgramiv(g_program, GL_LINK_STATUS, &result);
		if (result == GL_FALSE) {
			GLint length;
			char *log;

			/* get the program info log */
			glGetProgramiv(g_program, GL_INFO_LOG_LENGTH, &length);
			log = (char*)malloc(length);
			glGetProgramInfoLog(g_program, length, &result, log);

			/* print an error message and the info log */
			fprintf(stderr, "sceneInit(): Program linking failed: %s\n", log);
			sprintf(tmp, "sceneInit(): Program linking failed: %s\n", log);
			tinyfd_messageBox("Shader error", tmp, "ok", "error", 1);
			free(log);

			/* delete the program */
			glDeleteProgram(g_program);
			g_program = 0;
			exit(-1);
		}

		/* get uniform locations */
		g_programBrightness = glGetUniformLocation(g_program, "brightness");
		g_programBSize = glGetUniformLocation(g_program, "bsize");
		g_programTexSize = glGetUniformLocation(g_program, "texSize");
		g_programRGB = glGetUniformLocation(g_program, "rgbvalues");
	}
	void initOpenGL()
	{
	    int c=1;
		char appname[100];
		const char *foo = "name";
		sprintf((char*)appname, "MapAlgebra v%d.%d", MAJORVERSION, MINORVERSION);			

		glutInit(&c, (char**)&foo);
		glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH );
		glutInitWindowSize(ScreenWidth, ScreenHeight);
		glutInitWindowPosition(PSPScreenWidthOffset, PSPScreenHeightOffset);
		glutCreateWindow(appname);

		glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_GLUTMAINLOOP_RETURNS);

		//extensions GLEW
		GLenum err = glewInit();
		if (GLEW_OK != err)
		{
			return;
		}

		glutCloseFunc(close_func);		
		glutKeyboardFunc(key_func);
		glutSpecialFunc(keySpec_func);		
		glutMouseFunc(mouse_func);
		glutMotionFunc(motion_func);
		glutPassiveMotionFunc(passiveMotion_func);
		glutReshapeFunc(reshape);

		glutDisplayFunc(draw_func); 
		glutTimerFunc(REFRESH_DELAY, timerEvent, 0);

		if (strcmp(PSPMapAlgebraMode, "original") == 0) initMenu_Original(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "display") == 0) initMenu_Display(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "process") == 0) initMenu_Process(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "OPCE") == 0) initMenu_OPCE(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0) initMenu_StatHistoROI(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0) initMenu_MaskArea(menuCallback);
		if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) initMenu_TrainingArea(menuCallback);

		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);

		glEnable(GL_NORMALIZE);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_BLEND);
		//glEnable(GL_LINE_SMOOTH);
		glEnable(GL_SCISSOR_TEST);

		glColor4d(0.0, 0.0, 0.0, 1.0);
		glPointSize(5.0);
		
		glViewport(0, 0, (GLsizei)ScreenWidth, (GLsizei)ScreenHeight);
	}
	void runOpenGL()
	{
		resetViz();
		glutMainLoop();		
	}
	void resetViz()
	{
		uint i = 0;
	    fpsCount = 0;
		errortest=0; 
		quit = 0;

		for (i = 0; i < imageTexs.size(); i++)
		{
			t[i].x = t[i].y = 0;
			r[i].x = r[i].y = r[i].z = 0;
			ct[i].x = ct[i].y = 0;
			cr[i].x = cr[i].y = cr[i].z = 0;
			r[i].x = cr[i].x = 0;
			r[i].y = cr[i].y = 0;
			t[i].z = 1;


			if (orientation == 0)
			{
				do
				{
					t[i].z /= 1.2f;
				} while (t[i].z * imageTexs[i]->texSize.x > ScreenWidthPSP / numberOfSlices && t[i].z > 0.001);
			}
			else
			{
				do
				{
					t[i].z /= 1.2f;
				} while (t[i].z * imageTexs[i]->texSize.y > ScreenHeightPSP / numberOfSlices && t[i].z > 0.001);
			}
			ct[i].z = t[i].z;

			zoomPoint[i].x = 0;;
			zoomPoint[i].y = 0;;
		}  
		grid=0;
		help=0;
		slice = 0;   
		mer.dwButtonState=-1;
		mer.dwControlKeyState=0;
/*Modif EP - start*/
        ScreenWidthPSP = 1 + t[0].z * imageTexs[0]->texSize.x * numberOfSlices;
        ScreenHeightPSP = 1 + t[0].z * imageTexs[0]->texSize.y * numberOfSlices;
        glutReshapeWindow(ScreenWidthPSP, ScreenHeightPSP);
        ScreenWidth  = ScreenWidthPSP;
        ScreenHeight  = ScreenHeightPSP;               
/*Modif EP - end*/
	}    
	void close_func(void)
	{
		quit = 1;

		//clean stuff
		if (tmp)
			free(tmp);		

		imageTexs.clear();
	}
	float interpolate(float a, float b, int slices, int i)
	{
		float t = (float)(i/(float)slices*M_PI-M_PI/2.0f); // [-pi/2 ; pi/2]
		float f = sinf(t)/2.0f+0.5f;

		return a+f*(b-a);
	}
	void setCamera(int c)
	{
		float col = 0.5f+(c % 2)/4.0f;

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		if (orientation == 0) //vertical
		{
			glViewport(c * ScreenWidth / numberOfSlices + 1 , 0, ScreenWidth / numberOfSlices + 1, ScreenHeight);
			glOrtho(0, ScreenWidth / numberOfSlices, ScreenHeight-1, 0, 0.1f, 10.0f);
			glMatrixMode(GL_MODELVIEW);
			glScissor(c * ScreenWidth / numberOfSlices  + 1, 0, ScreenWidth / numberOfSlices + 1, ScreenHeight);
		}
		else
		{
			glViewport(0, (numberOfSlices-1-c) * ScreenHeight / numberOfSlices, ScreenWidth, ScreenHeight / numberOfSlices);
			glOrtho(0, ScreenWidth, (ScreenHeight -1)/ numberOfSlices,0, 0.1f, 10.0f);
			glMatrixMode(GL_MODELVIEW);
			glScissor(0, (numberOfSlices-1-c) * ScreenHeight / numberOfSlices , ScreenWidth,   ScreenHeight / numberOfSlices);
		}
		glClearColor(col,col,col, 1 );

		glLoadIdentity();
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/*	Matrix4 mv;
		mv.translate(0, 0, -1);
		mv.translate(-t[c].x, -t[c].y, 0);
		mv.translate(zoomPoint[c].x, zoomPoint[c].y, 0);
		mv.scale(t[c].z, t[c].z, 1);
		mv.translate(-zoomPoint[c].x, -zoomPoint[c].y, 0);
		*/
		glTranslated(0, 0, -1);

		glTranslated(-t[c].x, -t[c].y, 0);

		glTranslated(zoomPoint[c].x, zoomPoint[c].y, 0);

		glScalef(t[c].z, t[c].z, 1);

		glTranslated(-zoomPoint[c].x, -zoomPoint[c].y, 0);
	}
	void draw_func( void )
	{
		uint loop = 0;
		float  wx, wy;

		if(quit)
			return;
		GLenum error = glGetError();
		if(error!=0)
		{
			char tmp[100];
            fprintf(stderr,"OpenGL problem: %s\nExiting...", gluErrorString(error));
			sprintf(tmp, "OpenGL problem: %s\nExiting...", gluErrorString(error));
			tinyfd_messageBox("OpenGL error", tmp, "ok", "error", 1);

			quit = 1; 
			glutLeaveMainLoop();
			return;
		}
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 


		//x = (float)(orientation == 0 ? mer.dwMousePosition.X % (ScreenWidth / numberOfSlices) : mer.dwMousePosition.X);
		//y = (float)(orientation == 1 ? mer.dwMousePosition.Y % (ScreenHeight / numberOfSlices) : mer.dwMousePosition.Y);


		wx = world.x;// (x + t[sliceOver].x) / t[sliceOver].z + (zoomPoint[sliceOver].x - zoomPoint[sliceOver].x / t[sliceOver].z);
		wy = world.y;// (y + t[sliceOver].y) / t[sliceOver].z + (zoomPoint[sliceOver].y - zoomPoint[sliceOver].y / t[sliceOver].z);


		if (linked && sliceOver >= 0)
			propagateSliceView(sliceOver);

		for (loop = 0; loop < imageTexs.size(); loop++)
		{
			setCamera(loop);            
            drawGrid(imageTexs[loop]->texSize);

			//shade when selecting
			if (selectMode == 1)
				glColor4f(1, 1, 1, loop == sliceOver ? 1 : 0.5f);
			else
				glColor4f(1, 1, 1, 1);

			drawTextureMap(imageTexs[loop], loop);
			drawTextNumber(loop, imageTexs[loop]);	    
            drawTexts_EP(imageTexs[loop], loop);
            if (strcmp(PSPMapAlgebraMode, "original") == 0) 
		    {
				for (int i = 0; i < (int)polygonlistids.size();i++)
				{
					drawPolygon(polygonlistids.at(i), polygons.at(i), world, polygonMode && i == (int)polygons.size()-1);
				}
			}
            if (strcmp(PSPMapAlgebraMode, "OPCE") == 0) 
		    {
				for (int i = 0; i < (int)polygonlistids_OPCE_TGT.size();i++)
				{
					drawPolygon(polygonlistids_OPCE_TGT.at(i), polygons_OPCE_TGT.at(i), world, polygonMode_OPCE_TGT && i == (int)polygons_OPCE_TGT.size()-1);
				}
				for (int i = 0; i < (int)polygonlistids_OPCE_CLT.size();i++)
				{
					drawPolygon(polygonlistids_OPCE_CLT.at(i), polygons_OPCE_CLT.at(i), world, polygonMode_OPCE_CLT && i == (int)polygons_OPCE_CLT.size()-1);
				}
			}
            if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0) 
		    {
				for (int i = 0; i < (int)polygonlistids_StatHistoROI.size();i++)
				{
					drawPolygon(polygonlistids_StatHistoROI.at(i), polygons_StatHistoROI.at(i), world, polygonMode_StatHistoROI && i == (int)polygons_StatHistoROI.size()-1);
				}
			}
            if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0) 
		    {
				for (int i = 0; i < (int)polygonlistids_MaskArea.size();i++)
				{
					drawPolygon(polygonlistids_MaskArea.at(i), polygons_MaskArea.at(i), world, polygonMode_MaskArea && i == (int)polygons_MaskArea.size()-1);
				}
			}
			if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
		    {
				for (int i = 0; i < (int)polygonlistids_TrainingArea.size();i++)
				{
					drawPolygon(polygonlistids_TrainingArea.at(i), polygons_TrainingArea.at(i), world, polygonMode_TrainingArea && i == (int)polygons_TrainingArea.size()-1);
				}
			}

			if(grid)//over grid
				drawGrid(imageTexs[loop]->texSize); 
			//big cross
			glLineWidth(1);
			glPushAttrib(GL_ENABLE_BIT);
			glLineStipple(1, 0x0fff);//
			glEnable(GL_LINE_STIPPLE);
			glBegin(GL_LINES);
			glColor4f(textColor, textColor, textColor, 0.8f); 
			glVertex2d(wx - 10000 / t[loop].z, wy);
			glVertex2d(wx + 10000 / t[loop].z, wy);
			glVertex2d(wx, wy - 10000 / t[loop].z);
			glVertex2d(wx, wy + 10000 / t[loop].z);
			glEnd();
			glPopAttrib();

			//zoom point
			glBegin(GL_LINES);
			glVertex2d(zoomPoint[loop].x - 10 / t[loop].z, zoomPoint[loop].y);
			glVertex2d(zoomPoint[loop].x + 10 / t[loop].z, zoomPoint[loop].y);
			glVertex2d(zoomPoint[loop].x, zoomPoint[loop].y - 10 / t[loop].z);
			glVertex2d(zoomPoint[loop].x, zoomPoint[loop].y + 10 / t[loop].z);
			glEnd(); 
			
		}
		
		drawFrames();
		if (showMagnification)
		{
			for (loop = 0; loop < imageTexs.size(); loop++)
			{
				if (sliceOver >= 0 && sliceOver < (int)imageTexs.size() )
				{
					drawMagnifications(world, loop);
				}
			}
		}

/*Modif EP - start*/
		//drawTexts();
/*Modif EP - end*/

		glutSwapBuffers();
		glutReportErrors();
	}
	void timerEvent(int value)
	{
		if(quit)
		{
			glutLeaveMainLoop();
		}
		else
		{
			tick = tick + 1;

			if(semaphore) 
			{
				glutSetCursor(GLUT_CURSOR_WAIT);	  		
			}
			else if (selectMode)
			{
				glutSetCursor(GLUT_CURSOR_INFO);
			}
			else
			{
				glutSetCursor(GLUT_CURSOR_LEFT_ARROW);
			}

			if(semaphore == 2)
			{
				imageTexs[numberOfSlices - 1]->reloadTextures();
				semaphore = 0;
			}

			if (tick % 10 == 0 && backgroundChecking == 0)
				backgroundCheck();

			//updateMenuChanges();
			glutPostRedisplay();
			memoryUsage();
			glutTimerFunc(REFRESH_DELAY, timerEvent,0);
		}
	}
	void setCenterPoint()
	{
	}
	void propagateSliceView(int src)
	{
		int i = 0;
		for (i = 0; i < (int)imageTexs.size(); i++)
		{
			if (i != src)
			{
				zoomPoint[i].x = zoomPoint[src].x;
				zoomPoint[i].y = zoomPoint[src].y;
				t[i].x = t[src].x;
				t[i].y = t[src].y;
				t[i].z = t[src].z;
				ct[i].x = ct[src].x;
				ct[i].y = ct[src].y;
			}
		}
	}
	void key_func(unsigned char c, int x, int y)
	{		
		if (selectMode)
		{
			if (c == 27)
			{
				selectMode = 0;
				return;
			}
			return;
		}
		//----------------
	    if(inputMode)
        {
            if(c == 27)
            {
                inputMode = 0;
                return;
            }
            if(c==13)
            {
                inputMode = 0;
                inputConfirmed();
                return;
            }
            if(c==32)
                c='_';

            if(inputCount<127 && c!=8)
            {
                _string[inputCount] = c;
                inputCount++;
            }
            if(c == 8 && inputCount > 0)
                inputCount--;


            _string[inputCount] = '\0';

            return;
        }
		//---------------
		if (strcmp(PSPMapAlgebraMode, "original") == 0)
		{
			if (polygonMode)
			{
				switch (c)
				{
				case 27:
					polygonMode = 0;
					break;
				case 13:
					polygonMode = 0; 
					break;
				case 8:
					if (polygons.back().size() > 0)
					{
					polygons.back().pop_back();
					tesselatePolygon(polygons.back(), &(polygonlistids.back()));
					}
					break;	
				case 127:
					if (polygons.back().size() > 0)
					{
					polygons.back().pop_front();
					tesselatePolygon(polygons.back(), &(polygonlistids.back()));
					}
					break;
				}
				return;
			}
		}
		if (strcmp(PSPMapAlgebraMode, "OPCE") == 0)
		{
			if (polygonMode_OPCE_TGT)
			{
				switch (c)
				{
				case 27:
					polygonMode_OPCE_TGT = 0;
					break;
				case 13:
					polygonMode_OPCE_TGT = 0; 
					break;
				case 8:
					if (polygons_OPCE_TGT.back().size() > 0)
					{
					polygons_OPCE_TGT.back().pop_back();
					tesselatePolygon(polygons_OPCE_TGT.back(), &(polygonlistids_OPCE_TGT.back()));
					}
					break;	
				case 127:
					if (polygons_OPCE_TGT.back().size() > 0)
					{
					polygons_OPCE_TGT.back().pop_front();
					tesselatePolygon(polygons_OPCE_TGT.back(), &(polygonlistids_OPCE_TGT.back()));
					}
					break;
				}
				return;
			}
			if (polygonMode_OPCE_CLT)
			{
				switch (c)
				{
				case 27:
					polygonMode_OPCE_CLT = 0;
					break;
				case 13:
					polygonMode_OPCE_CLT = 0; 
					break;
				case 8:
					if (polygons_OPCE_CLT.back().size() > 0)
					{
					polygons_OPCE_CLT.back().pop_back();
					tesselatePolygon(polygons_OPCE_CLT.back(), &(polygonlistids_OPCE_CLT.back()));
					}
					break;	
				case 127:
					if (polygons_OPCE_CLT.back().size() > 0)
					{
					polygons_OPCE_CLT.back().pop_front();
					tesselatePolygon(polygons_OPCE_CLT.back(), &(polygonlistids_OPCE_CLT.back()));
					}
					break;
				}
				return;
			}
		}
		if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0)
		{
			if (polygonMode_StatHistoROI)
			{
				switch (c)
				{
				case 27:
					polygonMode_StatHistoROI = 0;
					break;
				case 13:
					polygonMode_StatHistoROI = 0; 
					break;
				case 8:
					if (polygons_StatHistoROI.back().size() > 0)
					{
					polygons_StatHistoROI.back().pop_back();
					tesselatePolygon(polygons_StatHistoROI.back(), &(polygonlistids_StatHistoROI.back()));
					}
					break;	
				case 127:
					if (polygons_StatHistoROI.back().size() > 0)
					{
					polygons_StatHistoROI.back().pop_front();
					tesselatePolygon(polygons_StatHistoROI.back(), &(polygonlistids_StatHistoROI.back()));
					}
					break;
				}
				return;
			}
		}
		if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0)
		{
			if (polygonMode_MaskArea)
			{
				switch (c)
				{
				case 27:
					polygonMode_MaskArea = 0;
					break;
				case 13:
					polygonMode_MaskArea = 0; 
					break;
				case 8:
					if (polygons_MaskArea.back().size() > 0)
					{
					polygons_MaskArea.back().pop_back();
					tesselatePolygon(polygons_MaskArea.back(), &(polygonlistids_MaskArea.back()));
					}
					break;	
				case 127:
					if (polygons_MaskArea.back().size() > 0)
					{
					polygons_MaskArea.back().pop_front();
					tesselatePolygon(polygons_MaskArea.back(), &(polygonlistids_MaskArea.back()));
					}
					break;
				}
				return;
			}
		}		
		if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0)
		{
			if (polygonMode_TrainingArea)
			{
				switch (c)
				{
				case 27:
					polygonMode_TrainingArea = 0;
					break;
				case 13:
					polygonMode_TrainingArea = 0; 
					break;
				case 8:
					if (polygons_TrainingArea.back().size() > 0)
					{
					polygons_TrainingArea.back().pop_back();
					tesselatePolygon(polygons_TrainingArea.back(), &(polygonlistids_TrainingArea.back()));
					}
					break;	
				case 127:
					if (polygons_TrainingArea.back().size() > 0)
					{
					polygons_TrainingArea.back().pop_front();
					tesselatePolygon(polygons_TrainingArea.back(), &(polygonlistids_TrainingArea.back()));
					}
					break;
				}
				return;
			}
		}		
		
		switch(c)
		{

		case 27 : quit=1; return;//break;
		case 'f': glutFullScreenToggle();break;
		case 'F': toggleFilterMode(); break;
		case ' ':
				break;
		case 'g': grid = !grid;break;
		case 'h': help = !help;break;
		case 'i': textColor = ((int)(textColor*2 + 1) % 3)/2.0f; break;
		case 'z': 
			showMagnification = !showMagnification ;
			break;
		case 'r':
			resetViz();
			break;
		case '-':
			g_brightness -= 0.01;
			break;
		case '=':
			g_brightness += 0.01;
			break;
		case '1':
			g_RGB[0] += 0.01;
			break;
		case '2':
			g_RGB[1] += 0.01;
			break;
		case '3':
			g_RGB[2] += 0.01;
			break;
		case '!':
			g_RGB[0] -= 0.01;
			break;
		case '@':
			g_RGB[1] -= 0.01;
			break;
		case '#':
			g_RGB[2] -= 0.01;
			break;
		case 'D':
			removeImageTex(sliceOver);
			break;
			
			//default://printf("%d\n",c);
		} 

		glutPostRedisplay();
	}
	void keySpec_func(int key, int x, int y)
	{
		int mod;
		switch(key)
		{
		case GLUT_KEY_F12:
			grabScreen();
			break;		
		case GLUT_KEY_PAGE_UP:
			zoomView(x, y, 1.2f);
			break;
		case GLUT_KEY_PAGE_DOWN:
			zoomView(x, y, 1 / 1.2f);
			break;
		case GLUT_KEY_DOWN:
			t[sliceOver].y += ScreenHeight / 10;	    
			break;
		case GLUT_KEY_UP:
			t[sliceOver].y -= ScreenHeight / 10;	   
			break;
		case GLUT_KEY_LEFT:
			mod = glutGetModifiers();
			//f = (mod == GLUT_ACTIVE_SHIFT) ? 10 : 1;
			t[sliceOver].x -= ScreenWidth / 10;	    
			break;
		case GLUT_KEY_RIGHT:
			t[sliceOver].x += ScreenWidth / 10;		    
			break;
		case GLUT_KEY_F1:
			g_bsize = g_bsize - 1;
			g_bsize = max(0, g_bsize);
			break;
		case GLUT_KEY_F2:
			g_bsize = g_bsize + 1;
			g_bsize = min(100, g_bsize);
			break;
		}

		glutPostRedisplay();
	}
    
	void passiveMotion_func(int x,int y)
	{ 
		if (x > 0 && y > 0 && x < (int)ScreenWidth && y < (int)ScreenHeight  )
		{
			mer.dwMousePosition.X = x;
			mer.dwMousePosition.Y = y;

			sliceOver = orientation == 0 ? x / (ScreenWidth / numberOfSlices) : y / (ScreenHeight / numberOfSlices);

			mscreen.x = orientation == 0 ? mer.dwMousePosition.X % (ScreenWidth / numberOfSlices) : mer.dwMousePosition.X;
			mscreen.y = orientation == 1 ? mer.dwMousePosition.Y % (ScreenHeight / numberOfSlices) : mer.dwMousePosition.Y;
			world.x = (mscreen.x + t[sliceOver].x) / t[sliceOver].z + (zoomPoint[sliceOver].x - zoomPoint[sliceOver].x / t[sliceOver].z);
			world.y = (mscreen.y + t[sliceOver].y) / t[sliceOver].z + (zoomPoint[sliceOver].y - zoomPoint[sliceOver].y / t[sliceOver].z);
		}
		
		glutPostRedisplay();
	}
    
	void zoomView(int screenX, int screenY, float f)
	{
		int i = sliceOver;
		float wx, wy;
		float x = (float)( orientation == 0 ? screenX % (ScreenWidth / numberOfSlices) : screenX);
		float y = (float)( orientation == 1 ? screenY % (ScreenHeight / numberOfSlices) : screenY);
		
	
		wx = (x + t[i].x - zoomPoint[i].x) / t[i].z;
		wy = (y + t[i].y - zoomPoint[i].y) / t[i].z;
		t[i].x += wx * (1.0f - t[i].z);
		t[i].y += wy * (1.0f - t[i].z);
		zoomPoint[i].x += wx;
		zoomPoint[i].y += wy;

		if (t[i].z*f > 0.01 && t[i].z * f < 100)
			t[i].z *= f;							 
	}
	
	void mouse_func(int button, int state, int x, int y)
	{   
		mer.dwButtonState = button;
		mer.dwControlKeyState = state; 
		
		if (selectMode)
		{	 
			if (state == GLUT_DOWN)
			{
				selectMode--;
				selectedSlice[selectMode] = sliceOver;				

				if (selectMode == 0)
				{					
					performPendingOperation(1);
				}
			}			
			return;
		}	
		
		if (strcmp(PSPMapAlgebraMode, "original") == 0)	
		{
			if (polygonMode)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons.back().push_back(p);
				tesselatePolygon(polygons.back(), &(polygonlistids.back()));
				return;
				}
			}
		}
		if (strcmp(PSPMapAlgebraMode, "OPCE") == 0)	
		{
			if (polygonMode_OPCE_TGT)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons_OPCE_TGT.back().push_back(p);
				tesselatePolygon(polygons_OPCE_TGT.back(), &(polygonlistids_OPCE_TGT.back()));
				return;
				}
			}
			if (polygonMode_OPCE_CLT)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons_OPCE_CLT.back().push_back(p);
				tesselatePolygon(polygons_OPCE_CLT.back(), &(polygonlistids_OPCE_CLT.back()));
				return;
				}
			}
		}
		if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0)	
		{
			if (polygonMode_StatHistoROI)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons_StatHistoROI.back().push_back(p);
				tesselatePolygon(polygons_StatHistoROI.back(), &(polygonlistids_StatHistoROI.back()));
				return;
				}
			}
		}
		if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0)	
		{
			if (polygonMode_MaskArea)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons_MaskArea.back().push_back(p);
				tesselatePolygon(polygons_MaskArea.back(), &(polygonlistids_MaskArea.back()));
				return;
				}
			}
		}
		if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
		{
			if (polygonMode_TrainingArea)
			{
				if (state == GLUT_UP && button == GLUT_LEFT_BUTTON && fabs(ct[sliceOver].x - t[sliceOver].x) < 5 && fabs(ct[sliceOver].y - t[sliceOver].y) < 5)
				{
				FPOINT p;
				p.x = world.x;
				p.y = world.y;
				polygons_TrainingArea.back().push_back(p);
				tesselatePolygon(polygons_TrainingArea.back(), &(polygonlistids_TrainingArea.back()));
				return;
				}
			}
		}

		switch (button)
		{
		case GLUT_MIDDLE_BUTTON:
			if (state == GLUT_UP)
			{
			//	removeImageTex(sliceOver);
			}
			break;
		case 4:
			if (state == GLUT_DOWN)
				zoomView(x,y,1.2f);
			break;
		case 3:
			if (state == GLUT_DOWN)
				zoomView(x,y,1 / 1.2f);
			break; 

		default:
			break;
		}

		if(state == 0 && button == GLUT_LEFT_BUTTON)
		{
			 
			ct[sliceOver].x = t[sliceOver].x;
			ct[sliceOver].y = t[sliceOver].y;
			ct[sliceOver].z = t[sliceOver].z;   
			 
			cameraMoving=0;
		}

		glutPostRedisplay();
	}
	void motion_func(int x, int y)
	{ 
		switch (mer.dwButtonState)
		{
		case 0:
			if (mer.dwControlKeyState == 0)
			{
				t[sliceOver].x = ct[sliceOver].x + (mer.dwMousePosition.X - x);
				t[sliceOver].y = ct[sliceOver].y + (mer.dwMousePosition.Y - y);
			}
			break;
		case GLUT_MIDDLE_BUTTON:
			
			break;
			 
		}
		
		cameraMoving=1;		
	}	
	void reshape(int w, int h)
	{
		ScreenWidth = w;
		ScreenHeight = h;
		aspect = (float)w/(float)h;
		glViewport(0, 0, w, h);

	}
	
	int lastScale = 1;
	void drawTextureMap(ImageTex* it, int s)
	{
		int x,y,i;
		int scale = 1;
		POINT showCnt;
		POINT m;
		  			
		if (it->ready == 0)
			return;

		glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_DEPTH_TEST);
		glEnable(GL_TEXTURE_2D);
		glDepthMask(GL_TRUE);
		
		
		if (t[s].z >= 1)
			scale = 1;
		else
			scale = 1 << (int)(log(1 + 1/t[s].z));

		scale = max(1,min(scale, 64));
				

		//TODO: poprawic ilsoc wyswietlanych
		m.x = orientation == 1 ? ScreenWidth / 2 : ScreenWidth / numberOfSlices / 2;
		m.y = orientation == 1 ? ScreenHeight / numberOfSlices / 4 : ScreenHeight / 2;
		m.x = (long)((m.x + t[s].x) / t[s].z + (zoomPoint[s].x - zoomPoint[s].x / t[s].z));
		m.y = (long)((m.y + t[s].y) / t[s].z + (zoomPoint[s].y - zoomPoint[s].y / t[s].z));
		
		m.x = (m.x )/ 512;
		m.y = (m.y +256)/ 512;

		showCnt.x = orientation == 1 ? (int)(ScreenHeight / t[s].z / 512) : (int)(ScreenHeight / numberOfSlices / t[s].z / 512) + 1;
		showCnt.y = orientation == 1 ? (int)(ScreenWidth / numberOfSlices / t[s].z / 512) : (int)(ScreenWidth / t[s].z / 512);

		showCnt.x = max(1, showCnt.x);
		showCnt.y = max(1, showCnt.y);

		//sp = (int)( max(1, 1 / tz) );
		
		for (y = 0; y < it->mipDim.y; y++)
		{
			for (x = 0; x < it->mipDim.x; x++)
			{
				i = y * it->mipDim.x + x;

				if (abs(y - m.y) > showCnt.y || abs(x - m.x) >  showCnt.x)
				{
					if (it->texIds[i] != 0)
					{
						it->deleteMipTexture(i); 			
					}
					continue;
				}
				else
				{  
					if (it->texIds[i] == 0)
					{
						it->createTextureMip(i, scale);						
					}
					else if (scale != it->ready)
					{						
						it->reloadTextures();
						it->createTextureMip(i, scale);												
					}

					glActiveTexture(GL_TEXTURE0);
					/* enable program and set uniform variables */
					glUseProgram(g_program);
					glUniform1f(g_programBrightness, g_brightness);
					glUniform1i(g_programBSize, g_bsize);
					glUniform3f(g_programRGB, g_RGB[0], g_RGB[1], g_RGB[2]);

					g_TexSize[0] = it->texSize.x;
					g_TexSize[1] = it->texSize.y;
						
					glUniform2f(g_programTexSize, g_TexSize[0], g_TexSize[1]);
                         
					/* render  */
					it->drawMip(i);

					/* disable program */
					glUseProgram(0);
					
				}
				 
				//float dx = it.mipCoord[i].x + it.mipSize[i].x / 2 - world.x;
				//float dy = it.mipCoord[i].y + it.mipSize[i].y / 2 - world.y;

				//float d = sqrt(dx*dx + dy*dy);

				
			}
		}
		glPopAttrib();

	}
	void drawMagnifications(FPOINT pos, int slice)
	{
		glDisable(GL_SCISSOR_TEST);
		glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_DEPTH_BUFFER_BIT);

		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		glViewport(0, 0, ScreenWidth, ScreenHeight);
		glOrtho(0, ScreenWidth, 0, ScreenHeight, 0, 10000);

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glTranslated(0.0, 0.0, -1);
		
		if (orientation == 1)
		{ 

			if (imageTexs[slice]->magSize.y != (int)( 128 ) || imageTexs[slice]->magSize.x != (int)( 128 * 2 ))
			{
				imageTexs[slice]->magSize.y = 128;
				imageTexs[slice]->magSize.x = 128 * 2;
				imageTexs[slice]->createMagnificationTexture(imageTexs[slice]->magSize);
			}
			imageTexs[slice]->drawMagnification(pos, 1.0f / t[slice].z, (float)(ScreenWidth - imageTexs[slice]->magSize.x),
				(float)(imageTexs[slice]->magSize.y * (imageTexs.size() - slice)));
		}
		else
		{ 

			if (imageTexs[slice]->magSize.y != (int)(128*2) || imageTexs[slice]->magSize.x != (int)(128))
			{
				imageTexs[slice]->magSize.y = 128*2;
				imageTexs[slice]->magSize.x = 128;
				imageTexs[slice]->createMagnificationTexture(imageTexs[slice]->magSize);
			}
			
			imageTexs[slice]->drawMagnification(pos, 1.0f / t[slice].z,
				(float)(ScreenWidth - imageTexs[slice]->magSize.x * (imageTexs.size() - slice )),
				(float)(imageTexs[slice]->magSize.y));
		}

		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();

		glPopAttrib();

		glEnable(GL_SCISSOR_TEST);
	}
	
	void drawTextNumber(int i, ImageTex* it)
	{
		char info[512] = { 0 };
		//sprintf(info, "-%d- %dx%d\n%s", i+1, it->texSize.x, it->texSize.y, it->name);
/*Modif EP - start*/
		sprintf(info, "-%d- %s (%dx%d)", i+1, it->name, it->texSize.x, it->texSize.y);
/*Modif EP - end*/    

		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();

		//TODO:ORIENTATION!?
		if (orientation == 0)
			glOrtho(0, ScreenWidth / numberOfSlices, 0, ScreenHeight, 0, 10000);
		else
			glOrtho(0, ScreenWidth, 0, ScreenHeight / numberOfSlices, 0, 10000);

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glTranslated(0.0, 0.0, -1);

		//background 
		glColor4f(1, 1, 1, 0.9f);
		glBegin(GL_QUADS);
		if (orientation == 0)
		{
			glVertex3d(10, ScreenHeight - 10, -1);
			glVertex3d(ScreenWidth / numberOfSlices - 10, ScreenHeight - 10, -1);
			glVertex3d(ScreenWidth / numberOfSlices - 10 , ScreenHeight - 40, -1);
			glVertex3d(10, ScreenHeight - 40, -1);
		}
		else
		{
			glVertex3d(10, ScreenHeight / numberOfSlices - 10, -1);
			glVertex3d(ScreenWidth-10, ScreenHeight / numberOfSlices - 10, -1);
			glVertex3d(ScreenWidth-10, ScreenHeight / numberOfSlices - 40, -1);
			glVertex3d(10, ScreenHeight / numberOfSlices - 40, -1);
		}
		glEnd();

		glColor4f(textColor, textColor, textColor, 1.0f);
		if (orientation == 0)
			glRasterPos2d(20, ScreenHeight - 30);
		else
			glRasterPos2d(20, ScreenHeight / numberOfSlices - 30);

		glClear(GL_DEPTH_BUFFER_BIT);
		glutBitmapString(GLUT_BITMAP_8_BY_13, (const unsigned char*)info);

		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	}
    
/*Modif EP - start*/
	void drawTexts_EP(ImageTex* it, int ii)
	{
        float pick_col[3];
        int IndCol, IndPix, i;
        unsigned int rgb, r, g, b;
        unsigned int PixX, PixY;
        unsigned int Xmscreen, Ymscreen;
        float Value;
        
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		if (orientation == 0)
        {
            glOrtho(0, ScreenWidth / numberOfSlices, 0, ScreenHeight, 0, 10000);
        } else {
            glOrtho(0, ScreenWidth, 0, ScreenHeight / numberOfSlices, 0, 10000);
        }

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glTranslated( 0.0, 0.0,-1);
		 
		char info[512]={0};
		
        IndPix = 0;
        if (world.x < 0.) {world.x = 0.; IndPix = 1;} if (world.x > (float)it->texSize.x) {world.x = (float)it->texSize.x; IndPix = 1;}
        if (world.y < 0.) {world.y = 0.; IndPix = 1;} if (world.y > (float)it->texSize.y) {world.y = (float)it->texSize.y; IndPix = 1;} 
        PixX = (unsigned)floor(world.x); PixY = (unsigned)floor(world.y);
        
        if (it->NColor == 256)
        {
            if (IndPix == 0)
            {
                Xmscreen = floor((((float)PixX + 0.5) - (zoomPoint[0].x - zoomPoint[0].x / t[0].z)) * t[0].z -  t[0].x);
                Ymscreen = floor((((float)PixY + 0.5)- (zoomPoint[0].y - zoomPoint[0].y / t[0].z)) * t[0].z -  t[0].y);
                if (Xmscreen < 0) Xmscreen = 0; if (Xmscreen > ScreenWidth) Xmscreen = ScreenWidth;
                if (Ymscreen < 0) Ymscreen = 0; if (Ymscreen > ScreenHeight) Ymscreen = ScreenHeight;   
                if (orientation == 0)
                {
                    Xmscreen += ii*(ScreenWidth / numberOfSlices);
                } else {
                    Ymscreen += ii*(ScreenHeight / numberOfSlices);               
                }
                glReadPixels(Xmscreen, ScreenHeight - Ymscreen, 1, 1, GL_RGB, GL_FLOAT, pick_col);
                r = (unsigned)floor(pick_col[0]*255.0); g = (unsigned)floor(pick_col[1]*255.0); b = (unsigned)floor(pick_col[2]*255.0); 
                rgb = 1000000*r + 1000*g + b; 
                IndCol = -1;
                for (i = 0; i < it->NColor; i++) 
                {
                    if (rgb == it->PalCol[i]) IndCol = i;
                }
                if (IndCol != -1 && IndCol != 0)
                {
                    Value = it->ValMin + (IndCol - 1)*(it->ValMax - it->ValMin)/it->NColor;
					if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
						sprintf(info, "zoom : %2.0f %%    Class Num : %i    pixel : %i %i \nvalue = %.2f < %.2f < %.2f",
							sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, TrainingAreaClass, PixX, PixY, it->ValMin, Value, it->ValMax);
					else
						sprintf(info, "zoom : %2.0f %%    pixel : %i %i \nvalue = %.2f < %.2f < %.2f",
							sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, PixX, PixY, it->ValMin, Value, it->ValMax);
                } else {
					if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
						sprintf(info, "zoom : %2.0f %%    Class Num : %i    pixel : %i %i \nvalue = %.2f < ---- < %.2f",
							sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, TrainingAreaClass, PixX, PixY, it->ValMin, it->ValMax);
					else
						sprintf(info, "zoom : %2.0f %%    pixel : %i %i \nvalue = %.2f < ---- < %.2f",
							sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, PixX, PixY, it->ValMin, it->ValMax);
                }
            } else {
				if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
					sprintf(info, "zoom : %2.0f %%    Class Num : %i    pixel : %i %i \nvalue = %.2f < ---- < %.2f",
						sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, TrainingAreaClass, PixX, PixY, it->ValMin, it->ValMax);
				else
					sprintf(info, "zoom : %2.0f %%    pixel : %i %i \nvalue = %.2f < ---- < %.2f",
						sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, PixX, PixY, it->ValMin, it->ValMax);
            }
        } else {
			if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
				sprintf(info, "zoom : %2.0f %%    Class Num : %i    pixel : %i %i \nvalue = ----",
					sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, TrainingAreaClass, PixX, PixY);
			else
				sprintf(info, "zoom : %2.0f %%    pixel : %i %i \nvalue = ----",
					sliceOver >= 0 ? (100. * t[sliceOver].z) : 0, PixX, PixY);
        }

		//background 
		/*
		glColor4f(1, 1, 1, 0.9f);
		glBegin(GL_QUADS);
		glVertex3d(10, 50, -1);
		if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
		{
			glVertex3d(400, 50, -1);
			glVertex3d(400, 10, -1);
		}
		else
		{
			glVertex3d(300, 50, -1);
			glVertex3d(300, 10, -1);
		}
		glVertex3d(10, 10, -1);
		glEnd();
		*/
		//background 
		glColor4f(1, 1, 1, 0.9f);
		glBegin(GL_QUADS);
		if (orientation == 0)
		{
			glVertex3d(10, 10, -1);
			glVertex3d(ScreenWidth / numberOfSlices - 10, 10, -1);
			glVertex3d(ScreenWidth / numberOfSlices - 10 , 50, -1);
			glVertex3d(10, 50, -1);
		}
		else
		{
			glVertex3d(10, 10, -1);
			glVertex3d(ScreenWidth - 10, 10, -1);
			glVertex3d(ScreenWidth - 10, 50, -1);
			glVertex3d(10, 50, -1);
		}
		glEnd();
		
        glColor4f(0, 0, 0, 1.0f);
        glRasterPos2d(20, 35);
        glClear(GL_DEPTH_BUFFER_BIT);
            
		glutBitmapString(GLUT_BITMAP_8_BY_13, (const unsigned char*)info);

		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	}
/*Modif EP - end*/

	void drawTexts()
	{
		glDisable(GL_SCISSOR_TEST);
		glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_DEPTH_BUFFER_BIT);

		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
        glViewport(0, 0, ScreenWidth , ScreenHeight);
		glOrtho(0, ScreenWidth, 0, ScreenHeight, 0, 10000);

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glTranslated( 0.0, 0.0,-1);

		glColor4f(0, 0, 0, 1.0f);
		glRasterPos2d(20, 70);
		 
		char info[512]={0};
		
		sprintf(info, "x%.2f\nwindow: %d %d\npixel: %.2f %.2f\nbrightness [-/+]: %.2f\nrgb factor = [%.2f, %.2f, %.2f]",//\nzoom=[%.2f, %.2f]\npos=[%.1f,%.1f]",
            sliceOver >= 0 ? t[sliceOver].z : -1,//skala
            mscreen.x, mscreen.y,//pozycja w oknie
            world.x, world.y,
            g_brightness,
            g_RGB[0], g_RGB[1], g_RGB[2]

			//pozycja w swiecie
		//	zoomPoint.x, zoomPoint.y,//zoom
		//	tx,ty//przesuniecie
        );        

		//glClear(GL_DEPTH_BUFFER_BIT);

		if(inputMode)
        {
			//background 
			glColor4f(1, 1, 1, 0.9f);
			glBegin(GL_QUADS);
			glVertex3d(10, 120, -1);
			glVertex3d(250, 120, -1);
			glVertex3d(250, 90, -1);
			glVertex3d(10, 90, -1);
			glEnd();

			glColor4f(0, 0, 0, 1.0f);
            glutBitmapString(GLUT_BITMAP_8_BY_13,(const unsigned char*)prompt);
            glutBitmapString(GLUT_BITMAP_8_BY_13,(const unsigned char*)_string);
			if ( (tick % 20) < 10)
				glutBitmapString(GLUT_BITMAP_8_BY_13,(const unsigned char*)"_");
        }
		else
		{
			//background 
			glColor4f(1, 1, 1, 0.9f);
			glBegin(GL_QUADS);
			glVertex3d(10, 85, -1);
			glVertex3d(250, 85, -1);
			glVertex3d(250, 10, -1);
			glVertex3d(10, 10, -1);
			glEnd();

			glColor4f(0, 0, 0, 1.0f);
			glutBitmapString(GLUT_BITMAP_8_BY_13, (const unsigned char*)info);
		}
		//glutBitmapString(GLUT_BITMAP_HELVETICA_10,(const unsigned char*)name);

		if(help)
		{
			char helpt[1024];
			sprintf(helpt,"Help:...");

			glutBitmapString(GLUT_BITMAP_8_BY_13,(const unsigned char*)helpt);
		}
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();

		glPopAttrib();

		glEnable(GL_SCISSOR_TEST);

	}
	void drawFrames()
	{
		int i = 0;
		glDisable(GL_SCISSOR_TEST);
		glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_DEPTH_BUFFER_BIT);

		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		glViewport(0, 0, ScreenWidth, ScreenHeight);
		glOrtho(0, ScreenWidth, 0, ScreenHeight, 0, 10000);

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glTranslated(0.0, 0.0, -1);

		glLineWidth(2);
		glRasterPos2d(20, 100);

		
		for (i = 0; i < numberOfSlices; i++)
		{
			if (i == sliceOver)
			{
				if (strcmp(PSPMapAlgebraMode, "original") == 0)
				{
					if (polygonMode)
						glColor4f(0, 1, 0, 1.0f);
					else
						glColor4f(1, 1, 0, 1.0f);
				}
				if (strcmp(PSPMapAlgebraMode, "OPCE") == 0)
				{
					if (polygonMode_OPCE_TGT)
					{
						glColor4f(1, 0, 0, 1.0f);
					}
					else
					{
						if (polygonMode_OPCE_CLT)
						{
							glColor4f(0, 0, 1, 1.0f);
						}
						else
						{
							glColor4f(1, 1, 0, 1.0f);
						}
					}
				}
				if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0)
				{
					if (polygonMode_StatHistoROI)
						glColor4f(0, 1, 0, 1.0f);
					else
						glColor4f(1, 1, 0, 1.0f);
				}
				if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0)
				{
					if (polygonMode_MaskArea)
						glColor4f(0, 1, 0, 1.0f);
					else
						glColor4f(1, 1, 0, 1.0f);
				}
				if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
				{
					if (polygonMode_TrainingArea)
						glColor4f(0, 1, 0, 1.0f);
					else
						glColor4f(1, 1, 0, 1.0f);
				}

			}
			else
				glColor4f(0, 0, 0, 0.75f);

			glBegin(GL_LINE_LOOP);
			
			if (orientation == 0)
			{
				glVertex2d(i * ScreenWidth / numberOfSlices, 0);
				glVertex2d(i * ScreenWidth / numberOfSlices, ScreenHeight - 1);
				glVertex2d((i+1) * ScreenWidth / numberOfSlices - 1, ScreenHeight - 1);
				glVertex2d((i+1) * ScreenWidth / numberOfSlices - 1, 0);
			}
			else
			{
				glVertex2d(1, ScreenHeight - 0 - i * ScreenHeight / numberOfSlices);
				glVertex2d(1, ScreenHeight + 1 - (i + 1) * ScreenHeight / numberOfSlices);
				glVertex2d(ScreenWidth - 1, ScreenHeight + 1 - (i + 1) * ScreenHeight / numberOfSlices);
				glVertex2d(ScreenWidth - 1, ScreenHeight - 0 - i * ScreenHeight / numberOfSlices);
			}

			glEnd();
			
		}
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		glLineWidth(1);
		glPopAttrib();

		glEnable(GL_SCISSOR_TEST);
	}
	void drawGrid(POINT size)
	{
		//draw grid
		float v1[3];
		int i;
		v1[0]=0;
		v1[1]=0;
		v1[2]=0;

		glColor4f(0,0,0,0.5f);
		//x
		for(i= 1;i < size.x / 512+1; i++)
		{
			v1[0] = 512.0f * i ;
		    v1[1] = -100;
            glPushAttrib(GL_ENABLE_BIT);
            glLineStipple(1, 0x8888);//
            glEnable(GL_LINE_STIPPLE);
            glBegin(GL_LINES);
            glVertex3f(v1[0],v1[1],v1[2]);
            v1[1] = size.y+100.0f;
            glVertex3f(v1[0],v1[1],v1[2]);
            glEnd();
            glPopAttrib();
		}
		//y
		for(i= 1;i < size.y / 512+1; i++)
		{
			v1[1] = 512.0f * i;
		    v1[0] = -100;
            glPushAttrib(GL_ENABLE_BIT);
            glLineStipple(1, 0x8888);//
            glEnable(GL_LINE_STIPPLE);
            glBegin(GL_LINES);
            glVertex3f(v1[0],v1[1],v1[2]);
            v1[0] = size.x + 100.0f;
            glVertex3f(v1[0],v1[1],v1[2]);
            glEnd();
            glPopAttrib();
		}

	}

	void grabScreen()
	{
		int w = ScreenWidth;
		int h = ScreenHeight;
		unsigned char* imageData = (unsigned char*)calloc(w*h*4,1);

		glReadPixels(0, 0, w, h, GL_RGBA, 0x8367, imageData); //Copy the image to the array imageData
		//saveImageData(imageData);

		free(imageData);
		return;
	}

	void warningOn()
	{
		warning = 1;
	}
	int filterOn = 1;
	void toggleFilterMode()
	{
		uint i = 0;
		filterOn = !filterOn;
		for (i = 0; i < imageTexs.size(); i++)
			ImageTex::changeFilterMode(imageTexs[i]->texIds, imageTexs[i]->texCount, filterOn ? GL_LINEAR : GL_NEAREST);
			
	}	
	extern void memoryUsage()
	{
#ifdef _DEBUG		
#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX 0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049
		
		GLint total_mem_kb = 0;
		glGetIntegerv(GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX, &total_mem_kb);

		GLint cur_avail_mem_kb = 0;
		glGetIntegerv(GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX, &cur_avail_mem_kb);
		
#endif
	}
	///------------
	 
	THREADRETV operationThread(void* data)
	{		
		OperationInput *oi = (OperationInput*)data;
		ImageTex* res = NULL;
		oi->result = &res;
		oi->parameters = opParam;

		semaphore = 1;				
		performMAOperation(oi);
		if ( *(oi->result) != NULL)
			addImageTex(*(oi->result));
		semaphore = 2;
		free(oi);
	}
	void performPendingOperation(int newSlice)
	{			
		int iret=-1; 

#ifndef __WIN32	
		pthread_t thread1;
#endif

		OperationInput *oi = (OperationInput*)malloc(sizeof(OperationInput));
		if (selectedSlice[1] < 0 || (uint)selectedSlice[1] >= imageTexs.size())
		{
			fprintf(stderr, "Error. Unable to select slice.\n");
			return;
		}
		
		oi->first = imageTexs[selectedSlice[1]];
		if (selectedSlice[0] == -1)
			oi->second = NULL;
		else
		{
			if ((uint)selectedSlice[0] >= imageTexs.size())
			{
				fprintf(stderr, "Error. Unable to select slice.\n");
				return;
			}
			oi->second = imageTexs[selectedSlice[0]];
		}
		oi->pendingOp = pendingOperation;

#ifdef __WIN32		 
		_beginthread(operationThread, 0, (void*)oi);
#else		
		iret = pthread_create( &thread1, NULL, &operationThread, (void*) oi);
		if(iret)
		{
			operationThread((void*)oi);
		} 	
		
#endif
		
	}
	void promptSlice(int operation)
	{
		pendingOperation = operation;
		selectedSlice[1] = sliceOver;
		selectMode = 1;		
	} 
	//in seperate threads, so it doesn't freeze the program
    
	void save()
	{
        int iret=-1;
#ifndef __WIN32
		pthread_t thread1;

		iret = pthread_create(&thread1, NULL, &saveThread, (void *)(imageTexs [sliceOver]));
		if (iret)
		{
			saveThread((void *)( (imageTexs [sliceOver]) ));
		}
		
#else
		_beginthread(saveThread, 0, (void *)( (imageTexs [sliceOver]) ));
		//saveThread( (void *)((imageTexs[sliceOver]) ) );
#endif

	}
	void openFile()
	{
		runInThread(openThread);
	}
	THREADRETV savePolygons()
	{
		runInThread(savePolygonsThread);
	}
	THREADRETV savePolygons_OPCE()
	{
		runInThread(savePolygonsThread_OPCE);
	}
	THREADRETV savePolygons_StatHistoROI()
	{
		runInThread(savePolygonsThread_StatHistoROI);
	}
	THREADRETV savePolygons_MaskArea()
	{
		runInThread(savePolygonsThread_MaskArea);
	}
	THREADRETV savePolygons_TrainingArea()
	{
		runInThread(savePolygonsThread_TrainingArea);
	}

	void runInThread(THREADRETV(*_StartAddress) (void *))
	{
        int iret = -1;
#ifndef __WIN32
		pthread_t thread1;

		iret = pthread_create(&thread1, NULL, _StartAddress, NULL);
		if (iret)
		{
			_StartAddress(0);
		}

#else
		_beginthread(_StartAddress, 0, NULL);
#endif	
	}

	void menuCallback(int v)
	{  
		std::list<FPOINT> ps;

		if (sliceOver < 0 || sliceOver > numberOfSlices - 1 )
			return;

		if (semaphore > 0)
		{
			tinyfd_messageBox("Operation in progress", "Wait until the end of the current operation.", "ok", "info", 1);
			return;
		}		

		switch (v)
		{
		case MENU_OPEN:
			openFile();
			break;
		case MENU_REMOVE:
            if (imageTexs.size() > 1 && sliceOver <= (int)imageTexs.size()) removeImageTex(sliceOver);
			break;
		case MENU_SAVE:
			save();
			break;
		case MENU_ORIENTATION:
			orientation = !orientation;
			break;
		case MENU_RESET:
			resetViz();
			break;
		case MENU_SUM:
			promptSlice(MA_SUM);
			break;
		case MENU_DIFF:
			promptSlice(MA_DIFFERENCE);
			break;
		case MENU_MULT:
			promptSlice(MA_MULTIPLICATION);
			break;
		case MENU_DIV:
			promptSlice(MA_DIVISION);
			break;
		case MENU_ADJUST:
			pendingOperation = MA_ADJUST;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(1);
			break;
		case MENU_EQUALIZE:
			pendingOperation = MA_EQUALIZE;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(1);
			break;
		case MENU_NEGATIVE:
			pendingOperation = MA_NEGATIVE;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(1);
			break;					
		case MENU_LINKED:
			linked = !linked;		
			break;
		case MENU_FLIPH:
			pendingOperation = MA_FLIPH;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_FLIPV:
			pendingOperation = MA_FLIPV;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_CREATEPOLYGON:
			polygons.push_back(ps);
			polygonlistids.push_back(0);
			polygonMode = 1;			
			break;
		case MENU_SAVEPOLYGON:
			savePolygons();			
			break;
		case MENU_DELETEPOLYGON:
			polygonMode = 0;
			if (polygonlistids.size() > 0)// && tinyfd_messageBox("Are you sure?", "Do you realy want to delete the last polygon?", "okcancel", "question", 1))
			{
				polygonlistids.pop_back();
				polygons.pop_back();
			}
			break;
			
		case MENU_OPCE_CREATEPOLYGON_TGT:
			if (polygonlistids_OPCE_TGT.size() > 0)
			{
				polygonlistids_OPCE_TGT.pop_back();
				polygons_OPCE_TGT.pop_back();
			}
			polygons_OPCE_TGT.push_back(ps);
			polygonlistids_OPCE_TGT.push_back(0);
			polygonMode_OPCE_TGT = 1;			
			polygonMode_OPCE_CLT = 0;
			break;
		case MENU_OPCE_DELETEPOLYGON_TGT:
			polygonMode_OPCE_TGT = 0;			
			if (polygonlistids_OPCE_TGT.size() > 0)
			{
				polygonlistids_OPCE_TGT.pop_back();
				polygons_OPCE_TGT.pop_back();
			}
			break;
		case MENU_OPCE_CREATEPOLYGON_CLT:
			if (polygonlistids_OPCE_CLT.size() > 0)
			{
				polygonlistids_OPCE_CLT.pop_back();
				polygons_OPCE_CLT.pop_back();
			}
			polygons_OPCE_CLT.push_back(ps);
			polygonlistids_OPCE_CLT.push_back(0);
			polygonMode_OPCE_TGT = 0;			
			polygonMode_OPCE_CLT = 1;
			break;
		case MENU_OPCE_DELETEPOLYGON_CLT:
			polygonMode_OPCE_CLT = 0;			
			if (polygonlistids_OPCE_CLT.size() > 0)
			{
				polygonlistids_OPCE_CLT.pop_back();
				polygons_OPCE_CLT.pop_back();
			}
			break;
		case MENU_OPCE_SAVEPOLYGON:
			savePolygons_OPCE();			
			break;

		case MENU_StatHistoROI_CREATEPOLYGON:
			if (polygonlistids_StatHistoROI.size() > 0)
			{
				polygonlistids_StatHistoROI.pop_back();
				polygons_StatHistoROI.pop_back();
			}
			polygons_StatHistoROI.push_back(ps);
			polygonlistids_StatHistoROI.push_back(0);
			polygonMode_StatHistoROI = 1;
			break;
		case MENU_StatHistoROI_DELETEPOLYGON:
			polygonMode_StatHistoROI = 0;			
			if (polygonlistids_StatHistoROI.size() > 0)
			{
				polygonlistids_StatHistoROI.pop_back();
				polygons_StatHistoROI.pop_back();
			}
			break;
		case MENU_StatHistoROI_SAVEPOLYGON:
			savePolygons_StatHistoROI();			
			break;
			
		case MENU_MaskArea_CREATEPOLYGON:
			polygons_MaskArea.push_back(ps);
			polygonlistids_MaskArea.push_back(0);
			polygonMode_MaskArea = 1;
			break;
		case MENU_MaskArea_DELETEPOLYGON:
			polygonMode_MaskArea = 0;			
			if (polygonlistids_MaskArea.size() > 0)
			{
				polygonlistids_MaskArea.pop_back();
				polygons_MaskArea.pop_back();
			}
			break;
		case MENU_MaskArea_SAVEPOLYGON:
			savePolygons_MaskArea();			
			break;

		case MENU_TrainingArea_ADDCLASS:
			TrainingAreaClass++;
			TrainingAreaClassArray[TrainingAreaClass] = 0;			
			break;
		case MENU_TrainingArea_CREATEPOLYGON:
			polygons_TrainingArea.push_back(ps);
			polygonlistids_TrainingArea.push_back(0);
			polygonMode_TrainingArea = 1;
			TrainingAreaClassArray[TrainingAreaClass]++;			
			break;
		case MENU_TrainingArea_DELETEPOLYGON:
			polygonMode_TrainingArea = 0;			
			if (polygonlistids_TrainingArea.size() > 0)
			{
				polygonlistids_TrainingArea.pop_back();
				polygons_TrainingArea.pop_back();
			TrainingAreaClassArray[TrainingAreaClass]--;			
			}
			break;
		case MENU_TrainingArea_SAVEPOLYGON:
			savePolygons_TrainingArea();			
			break;

		case MENU_MAGNIFY:
			showMagnification = !showMagnification;
			break;
		case MENU_RED:
		case MENU_GREEN:
		case MENU_BLUE:
		case MENU_BLUE | MENU_RED:
		case MENU_BLUE | MENU_GREEN:
		case MENU_GREEN | MENU_RED:
			opParam = 0;
			if ( (v & MENU_RED) == MENU_RED )
				opParam |= MA_RED;
			if ((v & MENU_GREEN) == MENU_GREEN)
				opParam |= MA_GREEN;
			if ((v & MENU_BLUE) == MENU_BLUE)
				opParam |= MA_BLUE;

			pendingOperation = MA_COLOR;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(1);
			break;
		case MENU_TOGRAY:
			pendingOperation = MA_TOGRAY;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_TOJET:
			pendingOperation = MA_COLORMAP;			
			opParam = 1;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_TOHOT:
			pendingOperation = MA_COLORMAP;			
			opParam = 2;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_90CW:
			pendingOperation = MA_90CW;
			opParam = 2;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;
		case MENU_90CCW:
			pendingOperation = MA_90CCW;
			opParam = 2;
			selectedSlice[1] = sliceOver;
			selectedSlice[0] = -1;
			performPendingOperation(0);
			break;

		default:
			break;
		}

		menuChanged=1;
		updateMenuChanges(); 
	}
	void updateMenuChanges()
	{ 
	}
	void inputConfirmed()
	{
	}
	 
	THREADRETV saveThread(void * parg)
	{
		ImageTex* img = (ImageTex*)parg;
		/*char const * saveResp = tinyfd_saveFileDialog("Save file as...", img->path,0,0,0);
		if (!saveResp)
		{
			return;
		}*/
		semaphore = 1;		
		if (img->saveImageTex())
		{
		}
		semaphore = 0;	
	}
	THREADRETV openThread(void * nul)
	{
		char const * aFilterPatterns[3] = { "*.bmp", "*.jpg", "*.png" };

		char const * res = tinyfd_openFileDialog("Open file...", "", 0, aFilterPatterns, "Image files", 0);
		if (res)
		{
			addImageTex(ImageTex::loadImage(res));
		}
	}
	THREADRETV savePolygonsThread(void *nul)
	{
		char const * aFilterPatterns[1] = { "*.txt" };
		savePolygonToFile(polygons, tinyfd_saveFileDialog("Save polygons as...", "polygon.txt", 1, aFilterPatterns, "Text file"));
	}
	THREADRETV savePolygonsThread_OPCE(void *nul)
	{
		savePolygonToFile_OPCE(polygons_OPCE_TGT, polygons_OPCE_CLT, PSPtmpFileOPCE);
	}
	THREADRETV savePolygonsThread_StatHistoROI(void *nul)
	{
		savePolygonToFile_StatHistoROI(polygons_StatHistoROI, PSPtmpFileStatHistoROI);
	}
	THREADRETV savePolygonsThread_MaskArea(void *nul)
	{
		savePolygonToFile_MaskArea(polygons_MaskArea, PSPtmpFileMaskArea);
	}
	THREADRETV savePolygonsThread_TrainingArea(void *nul)
	{
		savePolygonToFile_TrainingArea(polygons_TrainingArea, PSPtmpFileTrainingArea);
	}
