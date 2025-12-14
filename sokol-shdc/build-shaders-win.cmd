@echo off
set SHADER_DIR=.\src\shaders

for /d %%D in ("%SHADER_DIR%\*") do (
	echo Compilando shader: %%~nD

	.\sokol-shdc\sokol-shdc.exe -i "%%D\%%~nD.glsl" -o "%%D\%%~nD.odin" -l glsl430:hlsl5:metal_macos:wgsl -f sokol_odin
)