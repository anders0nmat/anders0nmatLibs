# anders0nmatLibs
## Including
* **ColorControl.pas**  
	Quite dirty written color controls for Vcl-Delphi. Also has RGB and RGBW Color types  
* **DesktopHelper.pas**  
	For aquiring paint control of the windows desktop background (actually, you just get the HWND)  
* **dglOpenGL.pas**  
	A very good OpenGL implementation for Delphi by [these guys](https://delphigl.com/)  
* **djson.pas**  
	A simple JSON parser by [this guy](https://github.com/thomaserlang/delphi-json)  
* **FMX.WinFeatures.pas**  
	TrayIcon class for FMX (Windows only)  
* **FreetypeDelphi.pas (along with FreetypeDelphi.dllImports.pas and freetype32.dll and freetype64.dll)**  
	A **very** incomplete implementation of the [FreeType2 Library](https://www.freetype.org/) currently bound to the use of DLLs. Also some Delphi OOP Wrapper for easy use. Can load Chars with placement and image data from ttf (and all other freetype supported file types) file or stream.  
* **lz4d.pas (and some other lz4 files)**  
	[LZ4](https://lz4.github.io/lz4/) implementation from [this guy](https://github.com/Hugie/lz4-delphi)  
* **NeoControl.pas**  
	For controlling an [ESP8266](https://en.wikipedia.org/wiki/ESP8266) with some custom code via WiFi Network (Including LED effects :O)  
* **ObjectGL.pas**  
  Condensing OpenGL into object oriented programming (as far as possible)
* **OpenMath.pas**  
  Math library for OpenGL. Not particulary fast, but it does what it's suppoed to do
* **Parser.pas (including Parser.Operators.pas)**  
  My own parser project. Works with all four basic operators, self declarable functions (e.g. sin(x), min(x, y)) and variables (b, xs, afg, ...). also supports
  implicit multiplication notation: 2x. Does not work in front of parenthesis (2(x+5)) because that could be a function.  
* **StringHelper.pas**  
  All that missing String features. `Path(['c:\users\', currUser, 'desktop\files\', '\file.ini'])`, get list of files in dictionary, file hash SHA256, System Paths, Path file compare, etc.  
* **SunPredictions.pas**  
  Prediction sunrise and sunset times (Official, Civil, Nautic, Astronimical) for given Date and Coordinates  
* **TCPSocket.pas**  
  Very simple WinSock TCP Socket with send queue  
* **xxHash.pas**  
  Needed by and included in [lz4-delphi](https://github.com/Hugie/lz4-delphi)
