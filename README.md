# 5G NR SSB, Cell Search and MIB/SIB1 Recovery

This project implements a 5G NR initial‑access receiver that synchronizes to a gNodeB, decodes the MIB from PBCH, blindly decodes PDCCH using SI‑RNTI, and recovers SIB1 on PDSCH. It documents the end‑to‑end pipeline, SS burst pattern and generation, roles of PSS/SSS/PBCH/DM‑RS, quantitative metrics, and repeatable steps for running the receiver on generated waveforms.

### Overview
- Performs cell search and system information acquisition: PSS‑based coarse CFO and timing, SSS correlation for cell identity, PBCH DM‑RS–assisted equalization and BCH decoding for MIB, CORESET 0 derivation, blind PDCCH decode with SI‑RNTI, and PDSCH LDPC decoding of SIB1 with CRC checks.
- Supports locally generated SS‑burst + SIB1 signals via nrWaveformGenerator, enabling controlled AWGN experiments and feature validation before moving to live data.

### SS block and SS burst
- An SS/PBCH block (SSB) contains the PSS, SSS, PBCH, and PBCH DM‑RS, and in the example spans 20 RBs (240 subcarriers) across 4 OFDM symbols in the SSB numerology, with nrbSSB = 20 used for OFDM info and extraction.
- An SS burst is a set of one or more SSBs transmitted within a 5 ms window located in either half of a 10 ms frame, supporting beam sweeping and periodicities of 5, 10, 20, 40, 80, or 160 ms for network configurability and UE discovery latency trade‑offs.
- The SS block pattern (Cases A–E) determines the SSB subcarrier spacing and the maximum number of SSBs per burst $$L_{max}$$, where FR1 uses Cases A–C with $$L_{max} \in \{4,8\}$$ and FR2 uses Cases D–E with $$L_{max} = 64$$ in standard‑compliant configurations reflected in this workflow.

### PSS, SSS, PBCH, and DM‑RS roles
- PSS is used for coarse frequency offset search and initial timing, with candidates spaced at half‑subcarrier intervals over a bandwidth proportional to the SSB SCS, followed by fine CFO via CP correlation within the SSB.
- SSS completes the physical cell identity by correlating received SSS REs against all hypotheses, combining with the detected PSS to yield $$N_{cellID}$$ for subsequent PBCH/DM‑RS processing and scrambling resolution.
- PBCH carries the BCH codeword containing the MIB, which after MMSE equalization and polar decoding yields SubcarrierSpacingCommon, $$k_{SSB}$$, DMRS Type A position, and Type0‑PDCCH configuration needed to derive CORESET 0 and search spaces.
- PBCH DM‑RS provides robust channel/noise estimation across the SSB region and determines LSBs of the SS/PBCH block index, enabling correct PBCH descrambling, SSB index derivation, and improved PBCH equalization quality.

### SS burst generation 
- Configure SS‑burst parameters in MATLAB using 5G Toolbox: set the block pattern (Case A–E), enable transmitted SSBs, and control SSB power per index to emulate beam‑sweeping or boosted SNR for a specific SSB in controlled tests.
- Generate an SS burst or a full downlink test waveform including SIB1 using nrWaveformGenerator and SS‑burst configuration objects such as nrWavegenSSBurstConfig, which parameterize SSB periodicity, mapping, and Case selection for FR1/FR2.

### What the receiver does
- Synchronization and SSB extraction: perform a CFO sweep around the SSB bandwidth using half‑subcarrier spacing, correct frequency, estimate timing to the strongest SSB, demodulate the SSB grid, and extract PSS/SSS/PBCH resources for correlation and equalization.
- Cell identity and MIB recovery: detect $$N_{cellID}$$ via SSS, evaluate PBCH DM‑RS sequences to pick the best SNR and resolve SSB index LSBs, equalize PBCH, and decode BCH to parse the MIB and compute initial system information such as SubcarrierSpacingCommon, $$k_{SSB}$$, and PDCCHConfigSIB1.
- Control and data decoding: realign to the CRB raster using $$k_{SSB}$$, derive CORESET 0 and Type0‑PDCCH monitoring occasions, blind‑decode PDCCH with SI‑RNTI, configure PDSCH via DCI, and LDPC‑decode DL‑SCH to extract SIB1 with CRC validation.

### Implementation steps
1) Waveform setup: generate an SS‑burst + SIB1 waveform, optionally boosting the first SSB to emulate beamforming gain and applying AWGN at a target SNR for test repeatability.
2) PSS search and CFO correction: run frequency‑offset candidates at half‑subcarrier spacing over $$6\times\mathrm{scs}_{SSB}$$ kHz, pick the strongest PSS correlation, and refine CFO via CP‑based estimation within the SSB.
3) Timing and SSB grid: estimate timing to the strongest SSB, OFDM‑demodulate the SSB region, extract PSS/SSS/PBCH symbols, and compute PBCH DM‑RS indices for channel/noise estimation.
4) BCH/MIB: MMSE‑equalize PBCH using DM‑RS, polar‑decode BCH to get the MIB and SSB index, then construct initial system info including SubcarrierSpacingCommon, $$k_{SSB}$$, and Type0‑PDCCH config.
5) PDCCH/PDSCH/SIB1: realign by $$f_{shift}=k_{SSB}\cdot\mathrm{scs}_{K_{SSB}}\cdot10^3$$ Hz, derive CORESET 0 and monitoring occasions, blind‑decode PDCCH with SI‑RNTI, configure PDSCH from DCI, and LDPC‑decode DL‑SCH for SIB1; if decoding is marginal, sweep CarrierFrequency around $$f_{PhaseComp}$$ within an SCS‑scaled band and step.

### Quantitative results
- Estimated coarse CFO: −16 Hz via PSS search over $$6\times\mathrm{scs}_{SSB}$$ kHz with half‑subcarrier candidate spacing, followed by fine CP‑based correction.
- Timing alignment: 2200 samples to the strongest SSB, equal to 0.1432 ms at the configured sample rate in the generated test
- Cell identity and indexing: $$N_{cellID}=102$$ and SSB index $$=0$$, with BCH CRC $$=0$$ confirming MIB integrity and correct PBCH descrambling.
- EVM and CRC outcomes: PBCH RMS EVM ≈ 12.4% with BCH CRC $$=0$$, PDCCH RMS EVM ≈ 12.3% with SI‑RNTI CRC $$=0$$ at aggregation level 8, and PDSCH RMS EVM ≈ 10.3% with DL‑SCH CRC $$=0$$ for SIB1.
- Test configuration: FR1 Case B with 8 SSBs enabled, 6 dB SSB power boost on the first SSB, and AWGN SNR of 20 dB relative to the boosted SSB path for robust end‑to‑end validation.


### Learnings
- MIB fields and $$k_{SSB}$$ bridge SSB‑centric synchronization to CRB‑aligned control/data, enabling correct CORESET 0 frequency region and monitoring timing derived from the detected SSB occasion.
- PBCH DM‑RS and SSS provide a reliable scaffold for channel/noise estimation and PBCH equalization, while BCH CRC gating prevents wasted control/data decode attempts when initial access integrity is not met.
- A small SCS‑aware CarrierFrequency sweep converts marginal PDSCH equalization into reliable DL‑SCH decoding for SIB1 in practical conditions with residual phase/frequency error.


### References
- NR Cell Search and MIB and SIB1 Recovery example: end‑to‑end pipeline including SS burst generation, synchronization, PBCH/BCH/MIB, CORESET 0 and Type0‑PDCCH, and SIB1 decoding steps and metrics.[1]
- Synchronization Signal Blocks and Bursts: generating SSBs and assembling SS bursts, including Case selection and mapping concepts for FR1/FR2.[2]

[1](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html)
[2](https://www.mathworks.com/help/5g/gs/synchronization-signal-blocks-and-bursts.html)





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


