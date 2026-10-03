# Symmetrical Component Based Power System Fault Analysis (5-Bus Zbus Version)

A MATLAB/Simulink project for analyzing three-phase and unsymmetrical faults in a custom 5-bus transmission network using symmetrical components, sequence networks, Ybus/Zbus matrices, parameter studies, and Simulink cross-validation.

> **Note:** All network parameters are assumed study parameters. They do not represent a real grid, and the network is not an IEEE benchmark system.

---

## 1. Project Overview

The project answers the following question:

> Given a multi-bus power system and a fault at any bus, what are the fault currents and post-fault voltages, and how do they change with fault type, fault impedance, grounding, transformer connection, and network configuration?

```text
Symmetrical Components
        ↓
Sequence Networks
        ↓
Ybus / Zbus
        ↓
Fault Calculation at Any Bus
        ↓
Phase Currents and Voltages
        ↓
Parameter Studies
        ↓
Network Outage Study
        ↓
Simulink Cross-Validation
```

### Main objectives

- Build positive-, negative-, and zero-sequence Ybus/Zbus matrices.
- Calculate 3φ, LG, LL, and LLG fault currents at every bus.
- Transform sequence currents and voltages back into phase quantities.
- Analyze post-fault voltage profiles.
- Determine generator and line contributions to a remote fault.
- Study the effect of fault impedance and generator neutral impedance.
- Compare Δ–Yg and Yg–Yg transformer zero-sequence behavior.
- Analyze the effect of removing a transmission line.
- Cross-check selected analytical results in Simulink/Simscape Electrical.

---

## 2. Network Under Study

```text
G1 ─(1)─ T1 ─(2)────────(3)────────(4)─ T2 ─(5)─ G2
                 └───────────────────┘
                       Line 2–4
```

### Network parameters (per unit, 100 MVA base)

| Element | Positive / Negative Sequence | Zero Sequence |
|---|---|---|
| G1, Bus 1 | X1 = j0.15, X2 = j0.17 | X0 = j0.05 |
| G2, Bus 5 | X1 = j0.20, X2 = j0.22 | X0 = j0.06 |
| T1, 1–2 | j0.10 | Δ–Yg |
| T2, 5–4 | j0.12 | Δ–Yg |
| Line 2–3 | 0.02 + j0.10 | 0.06 + j0.30 |
| Line 3–4 | 0.02 + j0.08 | 0.06 + j0.24 |
| Line 2–4 | 0.03 + j0.12 | 0.09 + j0.36 |

### Assumptions

- Base power: 100 MVA.
- Generator buses (1, 5): 11 kV. Transmission buses (2, 3, 4): 132 kV.
- Prefault voltage: 1.0 pu everywhere (Thevenin fault model, no load flow).
- Loads and shunt capacitance are neglected in the analytical model.
- Fault impedance is zero for solid-fault studies; generator neutral impedances are initially zero.
- Line negative-sequence impedance equals positive-sequence impedance.
- Line zero-sequence impedance is three times the positive-sequence impedance.

---

## 3. Per-Unit Bases

$$S_{base}=100\ \text{MVA},\qquad I_{base}=\frac{S_{base}}{\sqrt{3}\,V_{base}},\qquad I_{actual}=I_{pu}\,I_{base}$$

| Bus | Voltage Base | Current Base |
|---:|---:|---:|
| 1 | 11 kV | 5248.6 A |
| 2 | 132 kV | 437.4 A |
| 3 | 132 kV | 437.4 A |
| 4 | 132 kV | 437.4 A |
| 5 | 11 kV | 5248.6 A |

For Simulink line blocks that need ohms, the 132 kV impedance base is $Z_{base}=132^2/100=174.24\ \Omega$.

---

## 4. Symmetrical Components

The operator is $a=e^{j2\pi/3}=1\angle120^\circ$, with $1+a+a^2=0$.

$$\begin{bmatrix}V_a\\V_b\\V_c\end{bmatrix}=\underbrace{\begin{bmatrix}1&1&1\\1&a^2&a\\1&a&a^2\end{bmatrix}}_{A}\begin{bmatrix}V_0\\V_1\\V_2\end{bmatrix},\qquad A^{-1}=\frac13\begin{bmatrix}1&1&1\\1&a&a^2\\1&a^2&a\end{bmatrix}$$

The same transformation applies to currents. The implementation was tested with a balanced positive-sequence set, an unbalanced set (round-trip error ~1e-16), and $A\,A^{-1}=I$.

---

## 5. Sequence Network Construction

- Positive: Y1, Z1. Negative: Y2, Z2. Zero: Y0, Z0. Each $Z=Y^{-1}$.
- Series elements are added with `addbranch` (adds y to both diagonals, subtracts from off-diagonals). Elements to ground are added with `addshunt`.
- Lines and transformers are branches in the positive and negative networks. Generators are shunts to ground.
- Generator zero-sequence shunt is $Z_0+3Z_n$.

### Zero-sequence transformer treatment

- **Δ–Yg:** the Yg (132 kV) side connects to ground through the leakage impedance (a shunt at the HV bus). The delta (generator) side is isolated, so buses 1 and 5 are decoupled from the transmission zero-sequence network.
- **Yg–Yg:** the transformer is a series branch, so zero-sequence current passes through.

---

## 6. Fault Models

For a fault at bus k, the diagonal elements $Z_{0,kk}, Z_{1,kk}, Z_{2,kk}$ are used with $V_f=1.0$ pu.

| Fault | Equations |
|---|---|
| 3φ | $I_1=\dfrac{V_f}{Z_{1,kk}+Z_f}$, $I_0=I_2=0$ |
| LG (A-G) | $I_0=I_1=I_2=\dfrac{V_f}{Z_{0,kk}+Z_{1,kk}+Z_{2,kk}+3Z_f}$ |
| LL (B-C) | $I_1=\dfrac{V_f}{Z_{1,kk}+Z_{2,kk}+Z_f}$, $I_2=-I_1$, $I_0=0$ |
| LLG (B-C-G) | $Z_p=Z_{2,kk}\parallel(Z_{0,kk}+3Z_f)$, $I_1=\dfrac{V_f}{Z_{1,kk}+Z_p}$, $I_2=-I_1\dfrac{Z_{0,kk}+3Z_f}{Z_{2,kk}+Z_{0,kk}+3Z_f}$, $I_0=-I_1\dfrac{Z_{2,kk}}{Z_{2,kk}+Z_{0,kk}+3Z_f}$ |

The factor $3Z_f$ appears because $V_a=Z_fI_a=3Z_fI_0$ and the zero-sequence network carries only $I_0$.

---

## 7. Phase-Current Reconstruction

$$\begin{bmatrix}I_a\\I_b\\I_c\end{bmatrix}=A\begin{bmatrix}I_0\\I_1\\I_2\end{bmatrix}$$

Boundary-condition checks pass for every fault type: 3φ has equal phase magnitudes and $I_0=I_2=0$; LG has $I_b=I_c=0$; LL has $I_a=0$, $I_b=-I_c$, $I_0=0$; LLG has $I_a=0$ and $I_b+I_c=3I_0$.

---

## 8. Post-Fault Voltage Calculation

For a fault at bus k, at every bus i:

$$V_{1,i}=V_f-Z_1(i,k)I_1,\qquad V_{2,i}=-Z_2(i,k)I_2,\qquad V_{0,i}=-Z_0(i,k)I_0$$

The sequence voltages are transformed back with $A$.

---

## 9. Fault-Level Results

Solid faults, maximum phase current.

| Bus | 3φ (pu) | 3φ (kA) | LG (kA) | LL (kA) | LLG (kA) | 3φ MVA |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 8.697 | 45.647 | 53.807 | 37.467 | 53.904 | 869.69 |
| 2 | 6.547 | 2.864 | 3.336 | 2.398 | 3.278 | 654.70 |
| 3 | 5.377 | 2.352 | 2.291 | 1.983 | 2.391 | 537.73 |
| 4 | 6.224 | 2.722 | 3.133 | 2.286 | 3.068 | 622.38 |
| 5 | 7.259 | 38.102 | 45.399 | 31.693 | 45.030 | 725.95 |

3φ MVA = $S_{base}V_f/|Z_{1,kk}|$.

LG / 3φ current ratio: 1.179, 1.165, 0.974, 1.151, 1.192 (buses 1–5).

### Observations

- Buses 1 and 5 show tens of kA only because their current base (5248.6 A) is 12 times larger than at 132 kV. Per-unit values are the fair cross-bus comparison.
- **LG exceeds 3φ at buses 1, 2, 4 and 5.** Only Bus 3 has LG below 3φ, because $Z_{0}(3,3)=0.189$ is large there.
- LG exceeds 3φ when $Z_0 < Z_1$ at the fault bus, since $3/(Z_0+Z_1+Z_2)>1/Z_1$.
- LLG gives the highest maximum phase current at buses 1 and 3. At buses 2, 4 and 5, LG is the highest.

---

## 10. Post-Fault Voltage Profile

Fault at Bus 3, voltage magnitudes in pu.

**3φ fault** (all phases equal)

| Bus | \|Va\| | \|Vb\| | \|Vc\| |
|---:|---:|---:|---:|
| 1 | 0.5591 | 0.5591 | 0.5591 |
| 2 | 0.2675 | 0.2675 | 0.2675 |
| 3 | 0 | 0 | 0 |
| 4 | 0.2272 | 0.2272 | 0.2272 |
| 5 | 0.5154 | 0.5154 | 0.5154 |

**A-G fault:** Va collapses at Bus 3 (0.4227 at Bus 2); Vb and Vc stay near 0.93–1.04 pu.
**B-C fault:** Va stays ≈1.03 pu; Vb and Vc drop to ≈0.51 pu at Bus 3.
**B-C-G fault:** Vb and Vc go to 0 at Bus 3; Va stays ≈1.03 pu.

---

## 11. Generator and Line Contribution Analysis

3φ fault at Bus 3, positive sequence.

| Source | Current (pu) | Magnitude (pu) | At generator terminal (11 kV) |
|---|---|---:|---:|
| G1 | 0.1679 − j2.9432 | 2.9480 | 15.47 kA |
| G2 | 0.1247 − j2.4262 | 2.4294 | 12.75 kA |

$I_{G1}+I_{G2}=0.2926-j5.3694=I_f$ exactly **in per unit**. The kA values are at the 11 kV generator buses, so they do not sum to the 2.352 kA fault current at 132 kV. On the 132 kV side the contributions are about 1.29 kA and 1.06 kA.

| Branch | Current (pu) | Magnitude (pu) | Current (kA) |
|---|---|---:|---:|
| Line 2–3 | 0.1045 − j2.6210 | 2.6231 | 1.147 |
| Line 3–4 | −0.1881 + j2.7483 | 2.7548 | 1.205 |
| Line 2–4 | 0.0634 − j0.3222 | 0.3284 | 0.144 |

The two currents arriving at Bus 3 (from lines 2–3 and 4–3) sum to the fault current.

---

## 12. Impedance Studies

### 12.1 Fault current vs fault impedance
$Z_f$ swept from 0 to 0.5 pu for all four fault types. Current falls as $Z_f$ rises. The plotted quantity is the *maximum phase current*, which for LLG can vary non-monotonically at small $Z_f$ because the phase composition changes.

### 12.2 LG current vs generator neutral impedance
$Z_n$ swept from 0 to 0.5 pu. LG current at **Bus 1 falls strongly** as $Z_n$ increases. LG current at **Bus 3 is flat** (≈5.238 pu) because the Δ windings isolate the generator neutral from the transmission zero-sequence network.

### 12.3 Δ–Yg vs Yg–Yg

| Bus | Δ–Yg (pu) | Yg–Yg (pu) | Δ–Yg (kA) | Yg–Yg (kA) | Δ vs Yg |
|---:|---:|---:|---:|---:|---:|
| 1 | 10.2516 | 10.4129 | 53.807 | 54.654 | −1.57% |
| 2 | 7.6266 | 7.0562 | 3.336 | 3.086 | +7.48% |
| 3 | 5.2380 | 4.9989 | 2.291 | 2.187 | +4.56% |
| 4 | 7.1626 | 6.6279 | 3.133 | 2.899 | +7.47% |
| 5 | 8.6496 | 8.8155 | 45.399 | 46.270 | −1.92% |

Only the zero-sequence network differs between the two cases. The Yg–Yg Y0 matrix has off-diagonal entries (+j10 for 1–2 and +j8.33 for 5–4) that are zero for Δ–Yg.

---

## 13. Line-Outage Study

Line 2–4 removed, sequence networks rebuilt.

| Bus | Base 3φ (kA) | Outage 3φ (kA) | Change |
|---:|---:|---:|---:|
| 1 | 45.647 | 43.704 | −4.26% |
| 2 | 2.864 | 2.620 | −8.52% |
| 3 | 2.352 | 2.340 | −0.52% |
| 4 | 2.722 | 2.377 | −12.68% |
| 5 | 38.102 | 35.743 | −6.19% |

The fault level drops at every bus, with the largest change at Bus 4.

---

## 14. Simulink Validation

Model: Three-Phase Source (Yg, 11 kV), Three-Phase Transformer (Two Windings, D1–Yg, pu parameters split equally between windings), Three-Phase PI Section Line (R and L converted to ohms using $Z_{base}=174.24\ \Omega$, 1 km, C = 1e-7 F/km), Three-Phase Fault, Three-Phase V-I Measurement, `powergui` in Phasor 60 Hz.

**Phasor values in this mode are peak values, so divide by √2 to compare with the RMS analytical results.**

### 14.1 Positive-sequence impedance at Bus 3

Measured with `power_zmeter` (impedance block between phases A and B, multiplication factor 0.5, fault disabled).

| | R (Ω) | X (Ω) | \|Z\| (Ω) |
|---|---:|---:|---:|
| MATLAB | 1.763 | 32.355 | 32.403 |
| Simulink | 1.777 | 32.422 | 32.471 |

Magnitude difference ≈ **0.21%**.

### 14.2 3φ fault at Bus 3
MATLAB 2.352 kA RMS; Simulink 3.328 kA peak = 2.353 kA RMS. Difference ≈ **0.04%**.

### 14.3 LG fault at Bus 3
MATLAB 2.291 kA RMS; Simulink 3.300 kA peak = 2.334 kA RMS. Difference ≈ **1.9%**. Phases B and C are negligible (<0.1 A).

### 14.4 LLG fault at Bus 4

The analytical reference must be the **Bus 4** result (7.015 pu and 6.949 pu in phases B and C).

| Phase | MATLAB RMS | Simulink RMS | Difference |
|---|---:|---:|---:|
| A | 0 | ≈0 | – |
| B | 3.068 kA | 3.078 kA | +0.3% |
| C | 3.039 kA | 3.051 kA | +0.4% |

| Sequence | MATLAB RMS | Simulink RMS |
|---|---:|---:|
| I0 | 1.323 kA | 1.304 kA |
| I1 | 2.002 kA | 2.014 kA |
| I2 | 0.679 kA | 0.710 kA |

> **Correction note:** an earlier version of this validation compared the Bus 4 Simulink result with the Bus 3 analytical LLG values (2.391 kA), which gave an apparent 28–36% error. That was a wrong reference, not a modeling limitation.

---

## 15. Validation Summary

| Validation | Result |
|---|---|
| Sequence transformation round trip | Passed |
| Ybus/Zbus symmetry, $YZ=I$ | Passed |
| Independent Bus-3 Thevenin check | Passed |
| Fault boundary conditions (4 types) | Passed |
| Positive-sequence impedance (Simulink) | 0.21% |
| 3φ at Bus 3 | 0.04% |
| LG at Bus 3 | 1.9% |
| LLG at Bus 4 | ≈0.3% |

---

## 16. Requirements

- MATLAB R2021a or later, Simulink, Simscape, Simscape Electrical (Specialized Power Systems).
- Familiarity with phasors, per-unit systems, Ybus/Zbus, symmetrical components, and basic Simulink.

---

## 17. Key Engineering Insights

1. **Zbus is convenient:** one function handles any fault at any bus using $Z_{kk}$ and column k.
2. **Fault type sets the sequence interconnection:** 3φ is positive only; LG is all three in series; LL is positive and negative; LLG is positive in series with negative ∥ zero.
3. **Zero-sequence connectivity controls ground faults:** Δ–Yg isolates generator neutrals from the transmission buses.
4. **Ground faults can exceed 3φ faults** when the fault-bus zero-sequence impedance is lower than the positive-sequence impedance.
5. **Topology matters:** removing line 2–4 lowers fault level at every bus.
6. **Per-unit** lets 11 kV and 132 kV parts share one base, with actual currents recovered via each bus's current base.
7. **Cross-validation pitfalls:** unit conversion of line parameters, peak vs RMS in phasor mode, and choosing the matching fault bus for the reference value.

---

## 18. Limitations

- Prefault voltage fixed at 1.0 pu; no load flow; loads neglected.
- Shunt capacitance neglected analytically (Simulink uses a very small value because the block requires it).
- Constant sequence impedances; assumed generator data.
- The Simulink Three-Phase Source takes one series R-L impedance, so it cannot set Z1, Z2 and Z0 independently. This has little effect here because the Δ windings block generator Z0 for faults at buses 2–4. A Z2 mismatch (source uses the positive-sequence value) is a plausible contributor to the ~1.9% LG difference.
- Only three Simulink cases were compared.

Out of scope: relay coordination, CT saturation, protection schemes, arc models, EMT simulation, IEEE benchmark systems.

---

## 19. Recommended Figures

1. Sequence-transformation validation phasors.
2. Fault-level table or heatmap.
3. Phase-current phasors for representative faults.
4. Post-fault voltage profiles (four fault types).
5. Generator and line contribution to the Bus-3 fault.
6. Fault current vs $Z_f$.
7. LG current vs $Z_n$.
8. Δ–Yg vs Yg–Yg LG comparison.
9. Line-outage comparison.
10. MATLAB vs Simulink comparison.

---

## 20. Technologies Used

MATLAB, Simulink, Simscape Electrical (Specialized Power Systems), Ybus/Zbus analysis, symmetrical components, per-unit system, sequence networks.

---

## Conclusion

The MATLAB model forms positive-, negative-, and zero-sequence Ybus/Zbus matrices and calculates 3φ, LG, LL, and LLG faults at every bus. Further studies cover post-fault voltages, generator and line contributions, fault impedance, neutral grounding, transformer zero-sequence connections, and a line outage.

Simulink cross-checks agree closely with the analytical model: the Bus-3 positive-sequence impedance differs by 0.21%, the Bus-3 3φ current by 0.04%, the Bus-3 LG current by about 1.9%, and the Bus-4 LLG phase currents by about 0.3%.