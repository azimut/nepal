# nepal

[cl-openal](https://github.com/zkat/cl-openal) helpers for 3d positional audio

Depends on Common Music [fork](https://github.com/ormf/cm)

## Usage

Start OpenCL, check pavucontrol (on linux) to check if the new output was created):
```
(init-audio)
```

Now this library provides several CLOS classes, each one using increasingly number of OpenAL features. Most basic one, `audio`, will provide a way to play an audio without a position.

```
(make-audio :anaudioname (list "audio.wav"))
```

And now you can play it.

```
(play *)
```

> Note: all BUFFERS and SOURCES are cached to avoid leaking. Buffers by full pathname and sources by name (the first parameter of the constructors).

Before look at other classes. One feature of this library is that you can pass multiple audios to each object. So each time you call (play) it will pick a different one. The idea is that one could create a Common Music Pattern for that audio (TODO: right now defaults to CM:HEAP) and create complex sequences...might be even supporting patterns in other fields.

Anyway, let's look at positional audio.

```
> (make-positional :apositionalthing (list "leaf.wav)
                   :pos (v! 10 0 0))
> (play *)
```

This creates an object with a position. We can set the position again with the accessor `(pos)` and the OpenAL position and velocity would be updated.

Last piece of the puzzle is US that is the listener.

```lisp
(defclass camera (nepal:positional)
 (pos
  rot))
```

And asumming we set the `pos` and `rot` to a rtg-math.types:vec3 and rtg-math.types:quaternion respectevly with the `(pos)` and `(rot)` accessors we would get the OpenAL listener updated along with the internal velocity and orientation.

### Other classes

There is a `event` class that adds basic non-positional features, volume, rate and looping. There is a class for `music` that has a fade in/out features, with looping enabled. A `sfx` that has support for random offsets of pitch and volume, as well as position offset.

### Final notes

The idea I have in mind to use this is have a list of these instances and on an update call, set their position or just play them based on external conditions of the objects they belong. We will see...

## TODO

- Restart
- Globals
- Directional sources

## Status

Works?

## License

MIT
