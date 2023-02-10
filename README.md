# GlassyMirror
  - Use PlayerOnlyMirror as if it is a reflection on a smooth surface.
  - Demo World: https://vrch.at/7mc2xvc5
# v0.1.4+ for VRCSDK3-WORLD-2022.08.29.20.48_Public

  - Removes requirement of "TransparentBackground" mask, as VRCMirror now supports custom camera clear flags
  - Please make sure you use VRCSDK3-WORLD-2022.08.29.20.48_Public or newer for this version or later

Please make sure your "VRC Mirror Reflection" component looks like this if the background is still visible in the mirror
![vrcmirrorreflection](https://cdn.nyanpa.su/i/PiMX2EB0.jpg)

# VRCPlayersOnlyMirror

Tired of having to choose between admiring the scenery in a nice map or staring at your own reflection? Now you can do both at the same time!
VRCPlayersOnlyMirror is a simple mirror prefab that shows players only without any background.
This is NOT a 2D camera cut out, it is a full 3D mirror.

  - Player reflections in mirrors without any background
  - Adjustable mirror transparency
  - Simple distance fade
  - Works on both PC and Quest worlds
  - Performance cost more or less the same as a LQ mirror

# Requirements
  - VRChat SDK3
  - **!!! SDK3 VRCSDK3-WORLD-2022.08.29.20.48_Public or newer for v0.1.4 !!!**
  - Unity 2019 or later (This shader use **local** shader keywords.)

# How to

  - Import either the SDK3 unitypackage depending on your project
  - Example scene is provided as well as a prefab

# Shader Types

  - **PlayersOnlyMirror** - Regular version with transparency and distance fade
  - **PlayersOnlyMirrorCutout** - Variant with just cutout, no transparency or distance fade.
  - **GlassyPlayersOnlyMirror** - Moddification of the regular one. It blend reflections and the background like a shiney glass. (technically speaking, it blends them by BlendOp Max.)
  - **SoftAddPlayersOnlyMirror** - a little mutation of Glassy one. This is more visible, but less realistic. (UsesSoftAdd blending.)

# Shader Settings

  - **Base (RBG)** - Overlays a texture onto the reflection, same behavior as the default mirror shader
  - **Hide Background** - Hides the background, requires the TransparentBackground shader acting as a fake background for the mirror for this to work
  - **Ignore Effects** - Attempts to Ignore effects like particles, lens flare. Will still show up if they are in front of your character however. 
  - **CutOut Mode** - Toggle CutOut Mode
  - **Transparency** - Adjust transparency of the mirror
 
  - **Transparency Mask** - Texture mask that adjusts the transparency of the mirror, goes from white for fully opauque, to fully transparent with black. Mainly used to adjust the transparency of the entire mirror in real time for SDK2 as you can't animate mirror material properties on SDK2. See Next section for more details.
  - **Distance Fade** - Distance before the mirror starts fading to zero alpha. Disabled at 0.
  - **Distance Fade Length** - The length of distance traveled needed to fade to zero alpha.
  - **Smooth Edge** - Make edge smoother and avoid transparent object will be rendered opaque.
  - **Alpha Tweak Level** - Adjust smooth edge power.
  
  - RenderingTweaks are provided for Users who know about blending.
  
 # Work in progress issues
  - After Switching platform, rendering may go wrong.
  
 Credits appreciated but not required.

