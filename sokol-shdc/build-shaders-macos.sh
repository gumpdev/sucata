#!/bin/bash

for d in ./src/shaders/*/; do
    if [ ! -d "$d" ]; then
        continue
    fi
    
    shader_name="${d%/}"
    shader_name="${shader_name##*/}"
    
    if [ ! -f "$d$shader_name.glsl" ]; then
        echo "Aviso: Arquivo $shader_name.glsl não encontrado em $d"
        continue
    fi
    
    echo "Compilando shader: $shader_name"

    ./sokol-shdc/sokol-shdc-macos -i "$d$shader_name.glsl" -o "$d$shader_name.odin" -l glsl430:hlsl5:metal_macos:wgsl -f sokol_odin

    echo ""
done

echo "Compilação de shaders concluída!"