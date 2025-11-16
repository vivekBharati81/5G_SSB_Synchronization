# 5G NR SSB, Cell Search, and MIB/SIB1 Recovery

This project explains how a basic 5G NR receiver detects a 5G gNodeB, synchronizes with it, and decodes the first broadcast messages (MIB and SIB1).
It implements the complete signal-processing chain using MATLAB-generated test waveforms.

---

## Overview

When a 5G device powers on, it must search for a nearby 5G cell and learn the basic system information.
This project performs the following operations:

1. Detects the synchronization signals (PSS, SSS)
2. Corrects timing and frequency
3. Extracts and decodes the PBCH to recover the MIB
4. Uses MIB fields to locate and decode PDCCH
5. Configures and decodes PDSCH
6. Successfully recovers SIB1

---

# SS Block and SS Burst

## SS Block (SSB)

An SSB is a small 5G signal unit containing:

* PSS – used for coarse timing and frequency detection
* SSS – used for cell ID determination
* PBCH – carries the MIB
* DM-RS – channel estimation pilots for PBCH

The SSB occupies 20 RBs (240 subcarriers) and 4 OFDM symbols.

## SS Burst

An SS burst is a collection of SSBs transmitted every 5 ms.
Multiple SSBs are used for beam sweeping, allowing the UE to detect at least one beam direction.

---

# Roles of PSS, SSS, PBCH, and DM-RS

### PSS

Used to estimate rough timing and coarse frequency offset.

### SSS

Provides the physical cell ID by combining with PSS detection.

### PBCH

Carries the MIB, which includes key parameters such as:

* Common subcarrier spacing
* kSSB (frequency offset index)
* Type-0 PDCCH configuration

### DM-RS

Used for accurate channel estimation to decode the PBCH reliably.

---

# SS Burst Generation

* Selects SSB pattern (Case A–E)
* Enables specific SSB indices
* Sets individual SSB power levels for testing
* Generates SSB-only waveforms or full downlink signals including SIB1

This enables repeatable and controlled receiver testing.

---

# Receiver Processing Steps

## 1. Synchronization and SSB Extraction

* Search for PSS over many frequency offset candidates
* Correct frequency error
* Estimate SSB timing
* Extract PSS, SSS, PBCH, and DM-RS resources

## 2. Cell ID and MIB Recovery

* Correlate SSS across all hypotheses to determine the cell ID
* Estimate the channel using PBCH DM-RS
* Equalize PBCH and decode the BCH
* Recover MIB fields such as SubcarrierSpacingCommon, kSSB, and PDCCH configuration

## 3. PDCCH and SIB1 Decoding

* Shift center frequency using kSSB
* Derive CORESET 0
* Blind decode PDCCH using SI-RNTI
* Configure PDSCH from decoded DCI
* LDPC-decode DL-SCH to obtain SIB1

If decoding fails, small frequency sweeps are applied to correct residual frequency error.

---

# Implementation Steps

### Step 1: Waveform Generation

* Create SS burst + SIB1 waveform
* Optionally boost one SSB (beamforming emulation)
* Add AWGN noise at a controlled SNR

### Step 2: PSS Search and Frequency Correction

* Perform frequency sweep
* Select the strongest PSS peak
* Apply fine frequency correction using CP correlation

### Step 3: Timing Estimation and Grid Extraction

* Determine strongest SSB start position
* OFDM-demodulate and extract SSB symbols

### Step 4: PBCH/MIB Decoding

* Perform MMSE equalization
* Decode the BCH transport block
* Extract MIB fields
* Compute kSSB and initial downlink control information

### Step 5: PDCCH/PDSCH/SIB1 Decoding

* Apply frequency shift using kSSB
* Calculate CORESET 0 and monitoring occasions
* Blind-decode PDCCH with SI-RNTI
* Decode PDSCH
* LDPC-decode DL-SCH to recover SIB1

---

# Quantitative Results

| Parameter          | Result                                              |
| ------------------ | --------------------------------------------------- |
| Coarse CFO         | –16 Hz                                              |
| Timing Offset      | 2200 samples (0.1432 ms)                            |
| Cell ID            | 102                                                 |
| SSB Index          | 0                                                   |
| PBCH CRC           | Passed                                              |
| PDCCH CRC          | Passed                                              |
| PDSCH CRC          | Passed                                              |
| PBCH RMS EVM       | ~12.4%                                              |
| PDCCH RMS EVM      | ~12.3%                                              |
| PDSCH RMS EVM      | ~10.3%                                              |
| Test Configuration | FR1 Case B, 8 SSBs, 6 dB boost on SSB0, SNR = 20 dB |

All blocks (PBCH, PDCCH, PDSCH) decoded successfully.

---

# Learnings

1. MIB and kSSB are essential for mapping SSB detection to the correct CORESET and control/data channels.
2. SSS and DM-RS provide reliable cell ID detection and channel estimation for PBCH decoding.
3. Small frequency adjustments significantly improve PDSCH decoding when residual frequency error is present.

---

# References

1. MATLAB NR Cell Search and MIB/SIB1 Recovery Example
2. MATLAB Synchronization Signal Blocks and Bursts Documentation

[1](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html)
[2](https://www.mathworks.com/help/5g/gs/synchronization-signal-blocks-and-bursts.html)


