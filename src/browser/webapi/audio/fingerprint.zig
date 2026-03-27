// Copyright (C) 2023-2026  Lightpanda (Selecy SAS)
//
// Francis Bouvier <francis@lightpanda.io>
// Pierre Tachoire <pierre@lightpanda.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

//
// Synthetic Chrome audio fingerprint data.
//
// FingerprintJS hashes ONLY samples 4500-5000 (500 samples):
//   sum = 0; for (i = 4500; i < 5000; i++) sum += Math.abs(channelData[i]);
//   Target: sum ≈ 124.04347527516074 (Chrome/Blink, most common value)
//
// CreepJS also checks:
//   - Samples 4500-4600 (100 samples) as a "snapshot"
//   - Consistency between getChannelData() and copyFromChannel()
//   - DynamicsCompressorNode.reduction = -20.538288116455078
//
// Data generation strategy:
//   - Samples 0-4499: Realistic-looking waveform (triangle wave shape with
//     compression envelope decay).
//   - Samples 4500-4999: Carefully computed so sum(abs(values)) = 124.04347527516074.

pub const SAMPLE_COUNT: u32 = 5000;

pub const CHROME_AUDIO_SAMPLES: [SAMPLE_COUNT]f32 = blk: {
    @setEvalBranchQuota(100_000);
    var samples: [SAMPLE_COUNT]f32 = [_]f32{0.0} ** SAMPLE_COUNT;

    // Phase 1: Oscillator ramp-up (samples 0-99)
    for (0..100) |i| {
        const t: f32 = @floatFromInt(i);
        const envelope = t / 100.0;
        const period: f32 = 4.41;
        const phase = t / period;
        const frac = phase - @floor(phase);
        const triangle = (if (frac < 0.5) frac * 4.0 - 1.0 else 3.0 - frac * 4.0);
        samples[i] = triangle * envelope * 0.35;
    }

    // Phase 2: Compressed oscillation (samples 100-3000)
    for (100..3000) |i| {
        const t: f32 = @floatFromInt(i);
        const period: f32 = 4.41;
        const phase = t / period;
        const frac = phase - @floor(phase);
        var val = if (frac < 0.5) frac * 4.0 - 1.0 else 3.0 - frac * 4.0;
        val *= 0.32;
        if (val > 0.25) val = 0.25 + (val - 0.25) * 0.15;
        if (val < -0.25) val = -0.25 + (val + 0.25) * 0.15;
        samples[i] = val;
    }

    // Phase 3: Decay tail (samples 3000-4499)
    for (3000..4500) |i| {
        const t: f32 = @floatFromInt(i);
        const period: f32 = 4.41;
        const phase = t / period;
        const frac = phase - @floor(phase);
        const triangle = if (frac < 0.5) frac * 4.0 - 1.0 else 3.0 - frac * 4.0;
        const decay: f32 = 1.0 - (@as(f32, @floatFromInt(i - 3000)) / 1500.0);
        samples[i] = triangle * 0.08 * decay;
    }

    // Phase 4: Fingerprint zone (samples 4500-4999)
    // Target: sum(abs(samples[4500..5000])) = 124.04347527516074
    const base_val: f32 = 0.24808695;
    for (4500..5000) |i| {
        const offset: f32 = @floatFromInt(i - 4500);
        const var_phase = offset / 50.0;
        const var_frac = var_phase - @floor(var_phase);
        const variation: f32 = (if (var_frac < 0.5) var_frac * 4.0 - 1.0 else 3.0 - var_frac * 4.0) * 0.0008;
        const sign: f32 = if (i % 2 == 0) 1.0 else -1.0;
        samples[i] = sign * (base_val + variation);
    }

    break :blk samples;
};

pub const CHROME_COMPRESSOR_REDUCTION: f64 = -20.538288116455078;
