@echo off
REM ==========================================================
REM  build_sumo_network.bat
REM  Converts OSM -> SUMO network, generates random trips/routes,
REM  and creates a SUMO configuration file (map.sumocfg)
REM ==========================================================

REM --- Configuration ----------------------------------------
set MAPNAME=%1
set END_TIME=6000
set TRIP_PERIOD=1.0
set SEED=42
set SUMO_DIR=%2
REM ----------------------------------------------------------
echo sumo dir: %SUMO_DIR%
echo.
echo === Building SUMO network from %MAPNAME%.osm ===
if not exist "%MAPNAME%.osm" (
    echo [ERROR] File "%MAPNAME%.osm" not found!
    pause
    exit /b 1
)

REM --- Step 2: Convert OSM to SUMO network ------------------
echo [1/3] Converting OSM to SUMO network...
%SUMO_DIR%\bin\netconvert ^
    --osm-files "%MAPNAME%.osm" ^
    -o "%MAPNAME%.net.xml" ^
    --remove-edges.isolated true ^
	--ramps.guess ^
	--tls.guess ^
	--tls.discard-simple

if errorlevel 1 (
    echo [ERROR] netconvert failed!
    pause
    exit /b 1
)

REM --- Step 3: Generate trips and routes --------------------
echo [2/3] Generating random trips and routes...
python %SUMO_DIR%\tools\randomTrips.py ^
    -n "%MAPNAME%.net.xml" ^
    --route-file "%MAPNAME%.rou.xml" ^
    -e %END_TIME% -p %TRIP_PERIOD% --seed %SEED%

if errorlevel 1 (
    echo [ERROR] randomTrips failed!
    pause
    exit /b 1
)

REM --- Step 4: Create SUMO config file ----------------------
echo [3/3] Creating SUMO config file...
(
echo ^<configuration^>
echo   ^<input^>
echo     ^<net-file value="%MAPNAME%.net.xml"/^>
echo     ^<route-files value="%MAPNAME%.rou.xml"/^>
echo   ^</input^>
echo   ^<time^>
echo     ^<begin value="0"/^>
echo     ^<end value="%END_TIME%"/^>
echo     ^<step-length value="0.1"/^>
echo   ^</time^>
echo ^</configuration^>
) > "%MAPNAME%.sumocfg"

if errorlevel 1 (
    echo [ERROR] Failed to write %MAPNAME%.sumocfg
    pause
    exit /b 1
)

echo.
echo === Done! Generated files: ===============================
echo %MAPNAME%.net.xml
echo %MAPNAME%.rou.xml
echo %MAPNAME%.sumocfg
echo ==========================================================
pause
