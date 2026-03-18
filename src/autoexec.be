# rm -f AnalogClock.tapp; zip -j -0 AnalogClock.tapp src/*.be

do                          # embed in `do` so we don't add anything to global namespace
  import introspect
  var clock = introspect.module('AnalogClock', true)     # load module but don't cache
  tasmota.add_extension(clock)
end