/*
 * JaamSim Discrete Event Simulation
 * Copyright (C) 2012 Ausenco Engineering Canada Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
#version 130

in vec2 texCoordFrag;
in vec3 normalFrag;

uniform float C;
uniform float FC;
in float interpZ;

//layout(location = 0) out vec4 output;
out vec4 outColour;

uniform sampler2D tex;

uniform vec4 lightDir;
uniform vec4 diffuseColor;

uniform bool useTex;

void main()
{
    if (interpZ < 0)
        discard;

    vec3 l = normalize(lightDir.xyz);
    vec3 n = normalize(normalFrag);

    float lightDotN = dot(n, l) * -1;
    float light = clamp(lightDotN, 0, 1)*0.5 + 0.5;

    if (useTex) {
        outColour = texture2D(tex, texCoordFrag);
    } else {
        outColour = diffuseColor;
    }
    outColour.rgb *= light;

    gl_FragDepth = log(interpZ*C+1)*FC;
}
