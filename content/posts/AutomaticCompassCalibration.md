+++
title = "Automatic Compass Calibration"
author = ["Bernhard Specht"]
draft = false
+++

This blog post covers how to automatically and
continuously calibrate a magnetometer so that it
can be used to calculate accurate headings.


## Calibration {#calibration}

The samples from each axis usually have a different **scale** and **offset**
from zero. One of the easiest ways for calibration to remove
the offset and rescale the measurements. This requires knowing the
[minimum and maximum reading on each axis](https://www.appelsiini.net/2018/calibrate-magnetometer/). Usually one collects samples while
rotating the magnetometer in all directions, e.g. by following a geometric
form such as an 8.

Afterward, each reading \\(x\\) can be calibrated along an axis \\((i)\\) with

\begin{equation}
x^{(i)}\_{calib} = \frac{s^{(i)}}{s\_{avg}} (x^{(i)} - o^{(i)})
\end{equation}

with offset \\(o\\) along axis \\((i)\\):

\begin{equation}
o^{(i)} = \frac{x^{(i)}\_{max} + x^{(i)}\_{min}}{2}
\end{equation}

and scale \\(s\\) along axis \\((i)\\):

\begin{equation}
s^{(i)} = \frac{x^{(i)}\_{max} - x^{(i)}\_{min}}{2}
\end{equation}

and the average scale \\(s\_{avg}\\)

\begin{equation}
s\_{avg} = \frac{s^{x} + s^{y} + s^{z}}{3}
\end{equation}


## Problems with automation {#problems-with-automation}

There are two major problems when it comes to automation:

**1. Collecting distorted samples during calibration leads to errors later on**

If we collect the samples close to an object that distorts the earth's magnetic field (e.g. magnetic wall)
we will calibrate with incorrect minima and maxima. Most of the later headings that we calculate with the
incorrect calibration parameters will itself be incorrect.

**2. Manual calibration doesn't scale**

It might be fine for the owner of a phone to calibrate the magnetometer from time to time.
However, imagine a shopping cart that uses a magnetometer indoors:
Spinning it in circles is not something you can expect from a customer to do before using
indoor navigation features.


## Continuously calibrate and filter out distortions {#continuously-calibrate-and-filter-out-distortions}

Let's assume we know the position of our device (GPS, [UWB](https://mapsted.com/en-es/blog/uwb-positioning-explained/)). We can then build
a grid and assign each position to a tile. In each tile we continuously sample the
minimum and maximum readings of the magnetometer. We then define a threshold of
how many tiles we trust not to have any sources of distortion.

We can for example assume that 75% of our tiles not to suffer from any sources of distortion.
If we have a total of four tiles we might end up with readings such as shown in the figure below:

{{< figure src="/ox-hugo/compass_calibration.jpg" >}}

The tile marked in red has distorted readings with minima and maxima both higher than on the other tiles.
When sampling for the global minima and maxima we take the minima and maxima from all tiles, sort them
and discard 25% (our defined threshold of tiles we do not trust). Going back to the example in the figure
above we would end up with minima and maxima shown in green.

Given sufficient time of the device moving within the grid we can assume that it covered at least one 360-degree rotation.

One last thing that we need to take care of is expiration of minima and maxima. Even if a tile does not have
any objects inside that distort the earth's magnetic field, readings can still be incorrect (e.g. hardware bug).
The solution to this is to record the timestamp of when a minima or maxima is set. After a configurable
expiration time, any new reading will overwrite an old minima/maxima.
