# 5G NR Cell Search and MIB/SIB1 Recovery

This README documents a MATLAB 5G NR initial-access receiver that synchronizes to a gNodeB signal, decodes the MIB, blindly decodes PDCCH with SI‑RNTI, and recovers SIB1 over PDSCH using 5G Toolbox workflows. It summarizes what the project does, the implementation steps, quantitative results, and key learnings for reproducibility and resume-ready reporting.

### What it does
- Implements end-to-end UE-side cell search and system information recovery: PSS-based coarse CFO search, time alignment, SSS-based NCellID, PBCH DM-RS–assisted channel estimation, BCH/MIB parsing, CORESET 0 derivation, blind PDCCH decode with SI-RNTI, and PDSCH LDPC decode of SIB1.
- Supports both captured I/Q waveforms and locally generated SS-burst + SIB1 waveforms using nrWaveformGenerator, with AWGN injection to control SNR during testing.
- Aligns common-SCS demodulation to the CRB raster via k_SSB frequency shift for correct CORESET 0 placement and monitoring occasions computation per Type0-PDCCH CSS.

### System flow
- Synchronization: search over half-subcarrier-spaced CFO candidates around the SS-burst bandwidth, correct frequency, estimate timing to strongest SSB, and OFDM-demodulate SSB symbols.
- Cell identity and PBCH: correlate SSS to obtain NCellID, select PBCH DM-RS index to resolve SSB index LSBs, MMSE-equalize PBCH, and decode BCH to extract MIB and initial system info fields including SubcarrierSpacingCommon, k_SSB, and PDCCHConfigSIB1.
- Control and data: compute CORESET 0 resources/search spaces from MIB and SSB location, blind-decode PDCCH using SI-RNTI, configure PDSCH from DCI, and LDPC-decode DL-SCH to extract SIB1 with CRC verification.

### Implementation steps
1) Generate a waveform containing an SS burst and SIB1, optionally boosting one SSB’s power to emulate beamforming gain for robustness in controlled AWGN conditions.
2) Perform PSS-based CFO sweep and correction, then estimate timing to the SSB and OFDM-demodulate the SSB region for subsequent SSS/PBCH processing.
3) Determine NCellID via SSS correlation, evaluate PBCH DM-RS hypotheses to select the best SNR, estimate channel/noise, equalize PBCH, and decode BCH to recover the MIB and SSB index.
4) Realign to the CRB raster using k_SSB, compute CORESET 0 and Type0-PDCCH monitoring occasions, and blind-decode PDCCH (SI‑RNTI) to obtain the SIB1 PDSCH allocation.
5) Equalize and demodulate PDSCH using DM-RS, set LDPC decoder parameters from MCS/DCI/TBS, and recover SIB1 upon CRC pass; if decoding is fragile, sweep carrier frequency around fPhaseComp within the SCS-dependent band.

### Key quantitative results
- Coarse carrier frequency offset: −16 Hz from PSS search within a bandwidth of 6×scsSSB kHz, followed by fine CFO estimation using CP correlation.
- Timing alignment: 2200 samples to the strongest SSB, equivalent to 0.1432 ms at the configured sample rate for the generated case.
- Cell identity and indexing: NCellID = 102 and SSB index = 0 resolved via SSS and PBCH DM-RS payload bits with BCH CRC = 0.
- EVM and integrity: PBCH RMS EVM ≈ 12.4% with successful BCH CRC, PDCCH RMS EVM ≈ 12.3% with SI‑RNTI CRC = 0 at aggregation level 8, and PDSCH RMS EVM ≈ 10.3% with DL‑SCH CRC = 0 for SIB1.
- Test configuration (generated): FR1 Case B with 8 transmitted SSBs, 6 dB power boost on the first SSB, and AWGN SNR = 20 dB relative to the boosted SSB path.

### Configuration highlights
- FR1 SS-burst pattern Case B with L_max = 8 drives SSB subcarrier spacing and PBCH scrambling index bits, while the MIB exposes SubcarrierSpacingCommon, k_SSB offset to CRB raster, DMRS Type A position, and PDCCH Type0 configuration for CORESET 0.
- Frequency realignment before common-SCS demodulation uses f_shift = k_SSB × scsKSSB × 10^3 Hz with scsKSSB = 15 kHz in FR1, ensuring CORESET 0 and PDCCH/PDSCH are aligned to the CRB raster.

### Usage
- Requirements: MATLAB with 5G Toolbox and a supported environment for waveform generation/processing and LDPC decoding in the downlink chain.
- To run: configure waveform mode (captured or generated), set SS-burst parameters and minimum channel bandwidth, execute synchronization and SSB extraction, decode PBCH/BCH to obtain MIB, compute CORESET 0/search spaces, blind-decode PDCCH with SI‑RNTI, and decode PDSCH DL‑SCH for SIB1.
- Troubleshooting: if SIB1 decoding fails at moderate SNRs, expand the carrier-frequency sweep around fPhaseComp with step/bandwidth scaled to SubcarrierSpacingCommon until DL‑SCH CRC passes.

### Learnings
- The MIB fields and k_SSB bridge the SSB domain to the CRB-aligned control/data domain, enabling correct CORESET 0 placement and PDCCH monitoring timing from the detected SSB.
- PBCH DM-RS and SSS provide a robust scaffold for channel/noise estimation and PBCH equalization, and BCH CRC gating prevents futile control/data decoding attempts.
- A small carrier-frequency sweep tailored to the common SCS mitigates residual oscillator/phase error and often converts marginal PDSCH equalization into reliable DL‑SCH decoding for SIB1.

### Reproducibility tips
- Log CFO estimates, timing offsets, NCellID/SSB index, EVMs, and CRC outcomes across runs to validate stability of the pipeline under SNR and channel variations.
- Start with generated waveforms and controlled SNR/boost settings to validate each stage in isolation before moving to captured live I/Q signals.
- Keep CORESET 0 bandwidth checks against sample rate to ensure the demodulation grid covers the entire control region for the configured numerology.

### References
- Related MathWorks materials on NR cell search and HDL workflows can provide hardware-oriented perspectives for SSB detection and MIB recovery if targeting FPGA/ASIC implementations.[2]
- MathWorks 5G Toolbox example: NR Cell Search and MIB and SIB1 Recovery, covering SS-burst generation, synchronization, PBCH/BCH/MIB parsing, Type0-PDCCH CSS, and SIB1 decoding flow.[1]

[1](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html)
[2](https://www.mathworks.com/help/wireless-hdl/ug/nr-hdl-cell-search.html)

