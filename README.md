# 🎧 Mono-to-Stereo DSP — Spatial Audio for VR Systems

A **MATLAB-based Digital Signal Processing system** that converts mono audio into pseudo-stereo by simulating a sound source at a specific angular position around the listener. Designed for VR environmental audio, it applies a combination of FIR filtering, the Haas effect, chorus modulation, and stereo panning to produce spatially aware left/right channel output.

Pre-processed audio samples at 8 different angles (0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°) are included in the repository as `.mp3` files for immediate listening.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
- [Signal Processing Pipeline](#signal-processing-pipeline)
- [Output Audio Samples](#output-audio-samples)
- [Requirements](#requirements)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Filter Reference](#filter-reference)

---

## Overview

Mono audio sources — such as environmental sounds captured for VR — lack the spatial cues the human auditory system uses to localize sound. This system recreates those cues by:

1. **Splitting** the mono signal into two frequency bands via FIR LPF and HPF filters
2. **Enriching** each band independently with chorus modulation and the Haas time delay
3. **Panning** the two bands into a stereo L/R output at a specified angle
4. **Normalizing** and exporting the result as a stereo `.mp3`

The angle of the sound source is controlled by adjusting the `panning_ratio` parameter in `main.m`, producing perceptually distinct directionality when listened to on headphones.

A companion **Python runtime (`DSP.py`)** provides a live interactive playback experience: all 8 angle-rendered files play simultaneously across 8 mixer channels, and the user types an angle (0°–360°) at any time to dynamically crossfade the volume of each channel — simulating a sound source rotating around the listener in real time.

---

## Features

- 🎚️ **FIR filter bank** — custom windowed FIR LPF (fc = 550 Hz) and HPF (fc = 1050 Hz) split the mono signal into low and high frequency bands
- ⏱️ **Haas effect** — a 20ms delay on the low-frequency channel creates psychoacoustic width
- 🌀 **Chorus modulation** — sinusoidal delay modulation (depth: 5ms, rate: 1 Hz) adds movement and depth to both channels
- 📐 **Angular panning** — `panning_ratio` maps sound source angle to L/R amplitude balance
- 📊 **FFT spectrum analyzer** — visualizes the frequency spectrum before and after filtering
- 🔉 **8 pre-rendered angle samples** — output `.mp3` files at 45° increments from 0° to 315°
- 🔧 **Butterworth IIR filter** — alternative 6th-order Butterworth LPF implementation included
- 🎮 **Live angle playback (`DSP.py`)** — plays all 8 pre-rendered files simultaneously and dynamically crossfades their volumes based on a user-entered angle in real time

---

## How It Works

### Frequency Band Splitting

The mono input is passed through two parallel FIR filters:

- **Low-pass filter** (`tst_WD1rL`) — cutoff at **550 Hz**, captures the bass/warmth of the signal, routed to the **left channel**
- **High-pass filter** (`tst_WD1rH`) — cutoff at **1050 Hz**, captures the presence/air of the signal, routed to the **right channel**

Both filters use the **Hanning window** (Wtype = 3) and are designed via the windowed sinc method in `firwd.m`. The filter length is computed dynamically from the zero-crossing time: `N = 20 * n_zc + 1`.

### Haas Effect (Precedence Effect)

A **20ms delay** is applied to the low-frequency (left) channel:
```
delay_samples = round(0.02 * Fs)
```
The human auditory system fuses sounds arriving within ~30ms as a single source but perceives the direction from the first-arriving sound. This delay pushes the low-frequency band slightly behind the high-frequency band, creating a wider, more enveloping stereo image.

### Chorus Modulation

Both channels are passed through a chorus effect — a time-varying delay modulated by a sine wave:
```
modulation = depth * sin(2π * rate * t / Fs)
depth = 5ms,  rate = 1 Hz
```
`interp1` is used to apply the fractional sample delay, creating subtle pitch and timing variation that enhances the spatial effect.

### Angular Panning

The `panning_ratio` parameter controls the perceived angle of the sound source by scaling the L/R amplitudes:

```matlab
panning_ratio = 0.25;  % Adjust to change the sound angle
% Positive: attenuates L, boosts R → source moves right
% Negative: attenuates R, boosts L → source moves left
```

| `panning_ratio` | Perceived Direction |
|---|---|
| `0.0` | Center (equal L/R) |
| `+0.5` | Right of center |
| `+1.0` | Hard right |
| `-0.5` | Left of center |
| `-1.0` | Hard left |

The final output is normalized to prevent clipping before being written to file.

---

## Signal Processing Pipeline

```
VRSoundsMono.mp3  (mono input)
        │
        ├──── tst_WD1rL() ──── FIR LPF (fc=550Hz, Hanning) ──── ×2 gain
        │           │
        │     Haas delay (20ms) ──── Chorus modulation
        │           │
        │     xw_rL_chorus_panned  (Left channel)
        │
        └──── tst_WD1rH() ──── FIR HPF (fc=1050Hz, Hanning) ──── ÷20 gain
                    │
              Chorus modulation
                    │
              xw_rH_chorus_panned  (Right channel)
                    │
              [L | R] → Normalize → audiowrite() → processed_audio-<angle>deg.mp3
```

---

## Output Audio Samples

The following pre-processed stereo files are included, each rendered at a different simulated source angle. Use headphones for best effect.

| File | Simulated Angle |
|---|---|
| `processed_audio-0deg.mp3` | 0° (front) |
| `processed_audio-45deg.mp3` | 45° (front-right) |
| `processed_audio-90deg.mp3` | 90° (right) |
| `processed_audio-135deg.mp3` | 135° (rear-right) |
| `processed_audio-180deg.mp3` | 180° (rear) |
| `processed_audio-225deg.mp3` | 225° (rear-left) |
| `processed_audio-270deg.mp3` | 270° (left) |
| `processed_audio-315deg.mp3` | 315° (front-left) |

---

## Requirements

- **MATLAB** R2018b or later (any edition with the Signal Processing Toolbox)
- An `.mp3` mono input file named `VRSoundsMono.mp3` placed in the working directory
- **Python 3.7+** with `pygame` and `pydub` (for the live playback runtime only)

> No additional MATLAB toolboxes are required — all filters (`firwd.m`, `get_butterworthD.m`) are implemented from scratch.

---

## Usage

1. **Place your mono `.mp3` file** in the project directory and rename it `VRSoundsMono.mp3`, or update the filename in `main.m`:
   ```matlab
   [y, Fs] = audioread("VRSoundsMono.mp3");
   ```

2. **Set the desired source angle** by adjusting `panning_ratio` in `main.m`:
   ```matlab
   panning_ratio = 0.25;  % Range: -1.0 (hard left) to +1.0 (hard right)
   ```

3. **Run the main script** in MATLAB:
   ```matlab
   run('main.m')
   ```

4. The processed stereo audio will be saved as `processed_audio-<angle>deg.mp3` and played automatically.

### Running the filter test scripts individually

To visualize and listen to only the LPF or HPF output:

```matlab
[y, Fs] = audioread("VRSoundsMono.mp3");
xw_i = y(:, 1);

xw_rL = tst_WD1rL(Fs, xw_i);   % Low-pass filtered output
xw_rH = tst_WD1rH(Fs, xw_i);   % High-pass filtered output
```

Each function plots three subplots — the filter impulse response, the input signal, and the filtered output — along with a single-sided FFT spectrum before and after filtering.

---

### Live Angle Playback (`DSP.py`)

`DSP.py` provides a real-time interactive player that crossfades between the 8 pre-rendered angle files based on a user-entered angle.

**Requirements:**
```bash
pip install pygame pydub
```

**Run:**
```bash
python DSP.py
```

**How it works:**

All 8 pre-rendered `.mp3` files are loaded into separate pygame mixer channels simultaneously. A background input thread continuously prompts for an angle. When an angle is entered, the volume of each channel is recalculated using a **triangular crossfade window** — each channel peaks at its corresponding angle (e.g., channel 2 peaks at 90°) and fades to 0.5 at the adjacent 45° steps, and to 0 elsewhere:

```
Volume at peak angle  = 1.0
Volume at ±45° away  = 0.5
Volume beyond ±45°   = 0.0
```

This creates a smooth perceptual blend as the simulated source moves around the listener. Enter angles continuously to animate the sound source position in real time.

> **Note:** All 8 pre-rendered `.mp3` files (`processed_audio-0deg.mp3` through `processed_audio-315deg.mp3`) must be present in the same directory as `DSP.py`.

---

## Project Structure

```
mono-to-stereo-digital-signal-processing/
│
├── Pseudo_stereo_DSP1/             # MATLAB source code
│   ├── main.m                      # Main pipeline: LPF + HPF → Haas → Chorus → Pan → Export
│   ├── tst_WD1rL.m                 # FIR low-pass filter (fc=550Hz), plots & returns output
│   ├── tst_WD1rH.m                 # FIR high-pass filter (fc=1050Hz), plots & returns output
│   ├── tst_WD1r.m                  # Combined FIR filter (HPF), with playback & FFT display
│   ├── tst_BT6r.m                  # Alternative: 6th-order Butterworth IIR LPF
│   ├── firwd.m                     # FIR filter design via windowed sinc method
│   ├── get_butterworthD.m          # Butterworth pole coefficient generator
│   ├── do_display_fft_Fs.m         # FFT-based single-sided spectrum analyzer
│   └── test.m                      # Minimal test: load and play mono input
│
├── processed_audio-0deg.mp3        # Pre-rendered output: 0° (front)
├── processed_audio-45deg.mp3       # Pre-rendered output: 45°
├── processed_audio-90deg.mp3       # Pre-rendered output: 90° (right)
├── processed_audio-135deg.mp3      # Pre-rendered output: 135°
├── processed_audio-180deg.mp3      # Pre-rendered output: 180° (rear)
├── processed_audio-225deg.mp3      # Pre-rendered output: 225°
├── processed_audio-270deg.mp3      # Pre-rendered output: 270° (left)
├── processed_audio-315deg.mp3      # Pre-rendered output: 315°
├── DSP.py                          # Python live playback: crossfades 8 channels by user angle
└── Python Codes/                   # Incomplete — not in use
```

---

## Filter Reference

### `firwd(N, Ftype, WnL, WnH, Wtype)`
Custom FIR filter designer using the windowed sinc method.

| Parameter | Description |
|---|---|
| `N` | Number of filter taps (must be odd) |
| `Ftype` | `1`=LPF, `2`=HPF, `3`=BPF, `4`=BSF |
| `WnL` | Lower cutoff frequency in radians |
| `WnH` | Upper cutoff frequency in radians |
| `Wtype` | `1`=Rectangular, `2`=Triangular, `3`=Hanning, `4`=Hamming, `5`=Blackman |

### `get_butterworthD(N)`
Returns the denominator coefficients for an Nth-order Butterworth filter prototype (used by `tst_BT6r.m`).

### `do_display_fft_Fs(xw_i, Fs)`
Plots the single-sided amplitude spectrum of signal `xw_i` sampled at `Fs` Hz using zero-padded FFT.
