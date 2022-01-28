/** Aspect Ratio PS, version 1.2(pixel art ed.)
original code by Fubax 2019 for ReShade
optimised for pixel art games by reddit.com/u/crt09 (2022)
*/

#include "ReShadeUI.fxh"

uniform float A < __UNIFORM_SLIDER_FLOAT1
	ui_category = "Output";
	ui_label = "Stretch";
	ui_min = 1.0; ui_max = 4.0;
> = 0.0;

uniform float samplingShift < __UNIFORM_SLIDER_FLOAT1
	ui_category = "Input"; 
	ui_label = "Alignment";
	ui_min = -0.0005; ui_max = 0.0005;
> = 0.0001;

uniform int horizontalCells < __UNIFORM_SLIDER_FLOAT1
	ui_category = "Input";
	ui_label = "Horiz. Pixels";
	ui_min = 320; ui_max = 1000;
> = 320;

//uniform bool isPixelArt
//uinform int2 pixelGameRes
#include "ReShade.fxh"

	  //////////////
	 /// SHADER ///
	//////////////

float3 AspectRatioPS(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	bool Mask = false;

	// Center coordinates
	float2 coord = texcoord-0.5;

	
	// Squeeze horizontally
	if (A<0)
	{
		coord.x *= abs(A); // Apply distortion

		// Scale to borders
		coord /= abs(A);
			}
	// Squeeze vertically
	else if (A>0)
	{
		coord.y *= A; // Apply distortion

		// Scale to borders
		coord /= abs(A);
	}

	// Coordinates back to the corner
	coord += 0.5;

	//map horizontal coord sample to grid (if pixel game)
	coord[0] = round(coord[0]*horizontalCells)/float(horizontalCells);
 	coord[0] += samplingShift;

	// Sample display image and return
	return Mask? float4(0.027, 0.027, 0.027, 0.17).rgb : tex2D(ReShade::BackBuffer, coord).rgb;
}


	  ///////////////
	 /// DISPLAY ///
	///////////////

technique AspectRatioPS
<
	ui_label = "Integer Horizontal Stretch";
	ui_tooltip = "Stretch pixel art games horizontally without smearing (bilinear) for the purpose of aspect ratio correction of games dispalyed on CRT monitors outputting [highTVL]x240, allowing for a larger image than outputting raw 320x240";
>
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = AspectRatioPS;
	}
}
