+++
title = "Simulate CPU load with Python"
date = 2021-01-15

[taxonomies]
tags = ["programming", "python"]
+++

{{ image(src="/img/python.webp", alt="sss",
         position="center", style="border-radius: 4px;") }}

While testing out some home automation code on my Raspberry Pi, I noticed it was pretty CPU intensive. Time to bump up the overclock to squeeze more performance out of the Broadcom Arm7 processor. I wanted to keep an eye on temperatures, as well as stability under full load, so I needed to simulate CPU usage.

This Python script will do the job. It uses the multiprocessing library, which you can read more about in the [python documentation](https://docs.python.org/2/library/multiprocessing.html).

```python
#!/usr/bin/env python
from multiprocessing import Pool
from multiprocessing import cpu_count
import signal

stop_loop = 0

def exit_chld(x, y):
    global stop_loop
    stop_loop = 1

def f(x):
    global stop_loop
    while not stop_loop:
        x*x

signal.signal(signal.SIGINT, exit_chld)

if __name__ == '__main__':
    processes = cpu_count()
    print('-' * 20)
    print('Running load on CPU(s)')
    print('Utilizing %d cores' % processes)
    print('-' * 20)
    pool = Pool(processes)
    pool.map(f, range(processes))
```

This will utilize each CPU core and produce ~100% load with the while loops calculation.

```text
--------------------
Running load on CPU(s)
Utilizing 8 cores
--------------------
```
