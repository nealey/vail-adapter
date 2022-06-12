default: body.stl cap.stl

%.stl: case.scad
	openscad -o $@ -D TARGET=\"$*\" $<
