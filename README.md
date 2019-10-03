# nepal

[cl-openal](https://github.com/zkat/cl-openal) helpers for 3d positional audio

Depends on Common Music [fork](https://github.com/ormf/cm)

## raison d'être

I wanted a CLOS based solution to interact with OpenAL. That is:

- I can inherith from a class and now my own camera class would be an audio listener with a 3d position.
- Or I can inherith from another class and my object would be an audio source.
- Also I wanted to have a clos way to exploit all the openal concepts

All of these sort of "free" by just inheriting form the classes. Not sure if succeded. I only tough so far about how to do it and eventually just clobbed things together.

## Status

Works?

## License

MIT
