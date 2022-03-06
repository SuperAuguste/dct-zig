# dct-zig

Calculate those coefficients 😎😎

Simply get yourself a headerless signed 8-bit PCM file (Audacity can export to that format 😇), rename it to `dct.raw` (I didn't include a default `dct.raw` because the one I have on-hand is copyrighted and also 200kbs), put it in your current working directory (here), and `zig build run`!

The program will return a list of DCT coefficients! Then, head to [this convenient Desmos graph I created](https://www.desmos.com/calculator/4rfduj6koz) and paste the coefficients into the brackets of the `K = [ ]` line and you should see a snazzy audio signature. You can change the amplitude scale by changing that `100` at the bottom!
