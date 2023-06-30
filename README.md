# ddat-gpf.core

ddat-gpf.Core includes all the required singletons for all modules within the ddat-gpf (Godot Prototyping Framework).

**GlobalLog** - log management singleton

**GlobalData** - file management singleton

**GlobalDebug** - developer tools singleton

**GlobalFunc** - common method singleton

-----

The ddat-gpf consists of many optional modules. Most modules in the ddat-gpf (see their respective repositories) include at least one singleton. You can opt to use or not use whichever modules suit your project (except for .core and specified dependencies in the individual module readmes) but you should be aware of the order in which to load files when setting up the modules.

If you're not sure if a module includes a singleton or not, look for the 'autoload' directory in the module subdirectory.

i.e. the input manager autoload 'GlobalInput' is located at src/ddat-gpf/input_manager/autoload/global_input.gd)

The order of these singletons (within ProjectSetttings/AutoLoad) matters, so the correct order is included below.

**Load order last updated as of ddat-gpf.core v0.2.3**:

1 - **GlobalLog** (ddat-gpf.core) (_/src/ddat-gpf/core/autoload/_)

2 - **GlobalData** (ddat-gpf.core) (_/src/ddat-gpf/core/autoload/_)

3 - **GlobalDebug** (ddat-gpf.core) (_/src/ddat-gpf/core/autoload/_)

4 - **GlobalFunc** (ddat-gpf.core) (_/src/ddat-gpf/core/autoload/_)

5 - **GlobalDef** (ddat-gpf.moddefmgr) (_/src/ddat-gpf/mod_manager/autoload/_)

6 - **GlobalMod** (ddat-gpf.moddefmgr) (_/src/ddat-gpf/mod_manager/autoload/_)

7 - **GlobalAudio** (ddat-gpf.audio) (_/src/ddat-gpf/audiomgr/autoload/_)

8 - **GlobalInput** (ddat-gpf.input) (_/src/ddat-gpf/input_manager/autoload/_)

9 - **GlobalConfig** (ddat-gpf.gamefilemgr)* (_/src/ddat-gpf/config_manager/autoload/_)

10 - **GlobalStats** (ddat-gpf.eac) (_/src/ddat-gpf/eac/autoload/_)

11 - **GlobalPool** (ddat-gpf.eac) (_/src/ddat-gpf/eac/autoload/_)

12 - **GlobalEac** (ddat-gpf.eac) (_/src/ddat-gpf/eac/autoload/_)

13 - **GlobalProgress** (ddat-gpf.gamefilemgr) (_/src/ddat-gpf/file_manager/autoload/_)

*GlobalConfig will be moved to its own repo and module in the future.
