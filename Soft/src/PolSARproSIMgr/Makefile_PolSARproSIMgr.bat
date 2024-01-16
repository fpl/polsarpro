echo "PolSARproSIMgr"

IF NOT EXIST "..\..\bin\PolSARproSIMgr" mkdir "..\..\bin\PolSARproSIMgr"

gcc -o ..\..\bin\PolSARproSIMgr\PolSARproSim_gr.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -o ..\..\bin\PolSARproSIMgr\PolSARproSimGR_ImgSize.exe PolSARproSimGR_ImgSize.c -lm -static -lcomdlg32 -lole32 -fopenmp
gcc -o ..\..\bin\PolSARproSIMgr\PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm -static -lcomdlg32 -lole32 -fopenmp
del *.o
