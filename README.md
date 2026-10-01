# Symmetrical Component Based Power System Fault Analysis (5-Bus Zbus Version)

A MATLAB/Simulink project for analyzing three-phase and unsymmetrical
faults in a custom 5-bus transmission network using symmetrical
components, sequence networks, Ybus/Zbus matrices, parameter studies,
and Simulink validation.

> **Note:** All network parameters in this project are assumed study
> parameters and do not represent a real electrical grid.

------------------------------------------------------------------------

## 1. Project Overview

The project answers the following question:

> Given a multi-bus power system and a fault at any bus, what are the
> fault currents and post-fault voltages, and how do they change with
> fault type, fault impedance, grounding, transformer connection, and
> network configuration?

The analysis workflow is:

``` text
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

-   Build positive-, negative-, and zero-sequence Ybus/Zbus matrices.
-   Calculate 3φ, LG, LL, and LLG fault currents at every bus.
-   Transform sequence currents and voltages back into phase quantities.
-   Analyze post-fault voltage profiles.
-   Determine generator and line contributions to a remote fault.
-   Study the effect of fault impedance and generator neutral impedance.
-   Compare Δ--Yg and Yg--Yg transformer zero-sequence behavior.
-   Analyze the effect of removing a transmission line.
-   Cross-check selected analytical results using Simulink/Simscape
    Electrical.

------------------------------------------------------------------------

## 2. Network Under Study

The project uses the following custom 5-bus network:

``` text
G1 ─(1)─ T1 ─(2)────────(3)────────(4)─ T2 ─(5)─ G2
                 └───────────────────┘
                       Line 2–4
```

### Network parameters

  Element     Positive / Negative Sequence   Zero Sequence
  ----------- ------------------------------ ---------------
  G1, Bus 1   X1 = j0.15, X2 = j0.17         X0 = j0.05
  G2, Bus 5   X1 = j0.20, X2 = j0.22         X0 = j0.06
  T1, 1--2    j0.10                          Δ--Yg
  T2, 5--4    j0.12                          Δ--Yg
  Line 2--3   0.02 + j0.10                   0.06 + j0.30
  Line 3--4   0.02 + j0.08                   0.06 + j0.24
  Line 2--4   0.03 + j0.12                   0.09 + j0.36

### Assumptions

-   Base power: 100 MVA.
-   Generator buses: 11 kV.
-   Transmission buses: 132 kV.
-   Prefault voltage: 1.0 pu.
-   Loads are neglected.
-   Shunt capacitance is neglected in the analytical MATLAB model.
-   Fault impedance is initially taken as zero for the solid-fault
    studies.
-   Generator neutral impedances are initially zero.
-   Line zero-sequence impedance is approximately three times the
    positive-sequence impedance.
-   The system is represented using a Thevenin-equivalent fault model.

------------------------------------------------------------------------

## 3. Per-Unit Bases

The system uses:

\[ S\_{base}=100`\text{ MVA}`{=tex} \]

Current base:

\[ I\_{base}=`\frac{S_{base}}{\sqrt{3}V_{base}}`{=tex} \]

The resulting current bases are:

  Bus     Voltage Base   Current Base
  ----- -------------- --------------
  1              11 kV       5248.6 A
  2             132 kV        437.4 A
  3             132 kV        437.4 A
  4             132 kV        437.4 A
  5              11 kV       5248.6 A

Actual current is obtained from:

\[ I\_{actual}=I\_{pu}I\_{base} \]

------------------------------------------------------------------------

## 4. Symmetrical Components

The phase quantities are decomposed into positive-, negative-, and
zero-sequence components.

The operator is:

\[ a=e\^{j2`\pi`{=tex}/3} \]

with:

\[ 1+a+a\^2=0 \]

The sequence-to-phase transformation is:

\[
```{=tex}
\begin{bmatrix}
V_a\\
V_b\\
V_c
\end{bmatrix}
```
=
```{=tex}
\begin{bmatrix}
1&1&1\\
1&a^2&a\\
1&a&a^2
\end{bmatrix}
\begin{bmatrix}
V_0\\
V_1\\
V_2
\end{bmatrix}
```
\]

The same transformation is used for currents.

The inverse transformation converts phase quantities back into sequence
components.

The transformation implementation and reconstruction tests were
validated using balanced and unbalanced phasors.

------------------------------------------------------------------------

## 5. Sequence Network Construction

Three sequence networks are constructed:

-   Positive sequence: Y1, Z1
-   Negative sequence: Y2, Z2
-   Zero sequence: Y0, Z0

The impedance matrices are obtained from:

\[ Z=Y\^{-1} \]

### Positive and negative sequence

Lines and transformers are represented as branches in the corresponding
sequence networks.

Generator sequence impedances are represented as shunt branches to the
reference node.

### Zero sequence

The zero-sequence network requires special transformer treatment.

For the Δ--Yg transformers used in this project:

-   The grounded-wye line side is connected to ground through the
    transformer leakage impedance.
-   The delta generator side is isolated from the transformer in the
    zero-sequence network.
-   Therefore, zero-sequence current does not pass directly through the
    transformer from the generator side.

For comparison, the project also rebuilds the zero-sequence network
using Yg--Yg transformers, where zero-sequence current can pass through
the transformer.

------------------------------------------------------------------------

## 6. Fault Models

For a fault at bus k, the diagonal Zbus elements:

\[ Z\_{0,kk},`\quad `{=tex}Z\_{1,kk},`\quad `{=tex}Z\_{2,kk} \]

are used.

The prefault voltage is:

\[ V_f=1.0 pu \]

### 3-phase fault

\[ I_1=`\frac{V_f}{Z_{1,kk}+Z_f}`{=tex} \]

\[ I_0=I_2=0 \]

### Single-line-to-ground fault

For an A-G fault:

\[ I_0=I_1=I_2= `\frac{V_f}`{=tex} {Z\_{0,kk}+Z\_{1,kk}+Z\_{2,kk}+3Z_f}
\]

### Line-to-line fault

For a B-C fault:

\[ I_1=`\frac{V_f}{Z_{1,kk}+Z_{2,kk}+Z_f}`{=tex} \]

\[ I_2=-I_1 \]

\[ I_0=0 \]

### Double-line-to-ground fault

For a B-C-G fault:

\[ Z_p= Z\_{2,kk}`\parallel`{=tex}(Z\_{0,kk}+3Z_f) \]

\[ I_1=`\frac{V_f}{Z_{1,kk}+Z_p}`{=tex} \]

\[ I_2= -I_1 `\frac{Z_{0,kk}+3Z_f}`{=tex} {Z\_{2,kk}+Z\_{0,kk}+3Z_f} \]

\[ I_0= -I_1 `\frac{Z_{2,kk}}`{=tex} {Z\_{2,kk}+Z\_{0,kk}+3Z_f} \]

------------------------------------------------------------------------

## 7. Phase-Current Reconstruction

After calculating sequence currents:

\[
```{=tex}
\begin{bmatrix}
I_a\\
I_b\\
I_c
\end{bmatrix}
```
= A
```{=tex}
\begin{bmatrix}
I_0\\
I_1\\
I_2
\end{bmatrix}
```
\]

where:

\[ A=
```{=tex}
\begin{bmatrix}
1&1&1\\
1&a^2&a\\
1&a&a^2
\end{bmatrix}
```
\]

This makes it possible to report the actual phase currents for each
fault type.

------------------------------------------------------------------------

## 8. Post-Fault Voltage Calculation

For a fault at bus k, the sequence voltage at bus i is calculated using
the corresponding Zbus column.

Positive sequence:

\[ V\_{1i}=V_f-Z_1(i,k)I_1 \]

Negative sequence:

\[ V\_{2i}=-Z_2(i,k)I_2 \]

Zero sequence:

\[ V\_{0i}=-Z_0(i,k)I_0 \]

The sequence voltages are then transformed back to phase voltages.

------------------------------------------------------------------------

# 9. Fault-Level Results

The following table contains the calculated solid-fault currents for all
five buses.

    Bus   3φ (kA)   LG (kA)   LL (kA)   LLG (kA)   3φ Fault MVA
  ----- --------- --------- --------- ---------- --------------
      1    45.647    53.807    37.467     53.904         869.69
      2     2.864     3.336     2.398      3.278         654.70
      3     2.352     2.291     1.983      2.391         537.73
      4     2.722     3.133     2.286      3.068         622.38
      5    38.102    45.399    31.693     45.030         725.95

### Observations

-   Generator buses have substantially higher fault currents because of
    their lower equivalent impedances and lower voltage-base conversion
    to actual current.
-   At buses 1 and 5, LG fault currents exceed the corresponding 3φ
    fault currents.
-   This behavior is associated with the relatively low zero-sequence
    impedance at the generator buses.
-   The transmission-bus fault currents are considerably lower in
    absolute kA because their current base is only approximately 437.4
    A.

------------------------------------------------------------------------

# 10. Post-Fault Voltage Profile

A fault at Bus 3 was used to study the voltage response across all five
buses.

### 3φ fault at Bus 3

    Bus   \|Va\|   \|Vb\|   \|Vc\|
  ----- -------- -------- --------
      1   0.5591   0.5591   0.5591
      2   0.2675   0.2675   0.2675
      3        0        0        0
      4   0.2272   0.2272   0.2272
      5   0.5154   0.5154   0.5154

For unbalanced faults, the three phase voltages become unequal,
illustrating the different effects of positive-, negative-, and
zero-sequence components.

------------------------------------------------------------------------

# 11. Generator and Line Contribution Analysis

A 3φ fault at Bus 3 was used for contribution analysis.

### Generator contributions

#### G1

Positive-sequence current:

\[ I\_{G1}=0.1679-j2.9432 pu \]

Magnitude:

\[ \|I\_{G1}\|=2.9480 pu \]

At the 11-kV generator terminal:

\[ I\_{G1}`\approx15.473`{=tex}`\text{ kA}`{=tex} \]

#### G2

\[ I\_{G2}=0.1247-j2.4262 pu \]

Magnitude:

\[ \|I\_{G2}\|=2.4294 pu \]

At the 11-kV generator terminal:

\[ I\_{G2}`\approx12.751`{=tex}`\text{ kA}`{=tex} \]

The two generator contributions add exactly to the calculated fault
current in per-unit terms.

### Line currents for the Bus-3 fault

  Branch      Current (pu)          Magnitude (pu)   Current (kA)
  ----------- ------------------- ---------------- --------------
  Line 2--3   0.1045 − j2.6210              2.6231          1.147
  Line 3--4   −0.1881 + j2.7483             2.7548          1.205
  Line 2--4   0.0634 − j0.3222              0.3284          0.144

The generator and branch contributions satisfy the Bus-3 current
balance.

------------------------------------------------------------------------

# 12. Impedance Studies

## 12.1 Fault current versus fault impedance

Fault current was evaluated as fault impedance (Z_f) was increased from:

\[ 0`\rightarrow0.5`{=tex} pu \]

for:

-   3φ
-   LG
-   LL
-   LLG

The general trend is a reduction in fault current as fault impedance
increases.

------------------------------------------------------------------------

## 12.2 LG current versus generator neutral impedance

Generator neutral impedance (Z_n) was varied from:

\[ 0`\rightarrow0.5`{=tex} pu \]

at:

-   Bus 1
-   Bus 3

The study demonstrates that generator-bus LG faults are much more
sensitive to neutral grounding impedance than faults at transmission
buses separated from the generator by Δ--Yg transformers.

------------------------------------------------------------------------

## 12.3 Δ--Yg versus Yg--Yg transformer connection

LG fault current comparison:

    Bus   Δ--Yg (pu)   Yg--Yg (pu)   Δ--Yg (kA)   Yg--Yg (kA)
  ----- ------------ ------------- ------------ -------------
      1      10.2516       10.4129       53.807        54.654
      2       7.6266        7.0562        3.336         3.086
      3       5.2380        4.9989        2.291         2.187
      4       7.1626        6.6279        3.133         2.899
      5       8.6496        8.8155       45.399        46.270

This demonstrates that transformer zero-sequence connectivity can
materially change ground-fault current.

------------------------------------------------------------------------

# 13. Line-Outage Study

The optional outage study removes the 2--4 transmission line and
rebuilds the sequence networks.

### 3φ fault-current comparison

    Bus   Base (kA)   Line 2--4 Out (kA)    Change
  ----- ----------- -------------------- ---------
      1      45.647               43.704    −4.26%
      2       2.864                2.620    −8.52%
      3       2.352                2.340    −0.52%
      4       2.722                2.377   −12.68%
      5      38.102               35.743    −6.19%

The largest change occurs at Bus 4, where the 3φ fault current decreases
by approximately 12.7%.

------------------------------------------------------------------------

# 14. Simulink Validation

The analytical model was cross-checked using a Simulink/Simscape
Electrical model containing:

-   Three-Phase Source blocks
-   Three-Phase Transformer (Two Windings) blocks
-   Δ--Yg transformer configuration
-   Three-Phase PI Section Line blocks
-   Three-Phase Fault block
-   Three-Phase V-I Measurement
-   `powergui` in Phasor 60 Hz mode

## 14.1 Positive-sequence impedance validation

The analytical positive-sequence impedance seen from Bus 3 was:

\[ Z\_{1,`\text{MATLAB}`{=tex}}
`\approx1.763`{=tex}+j32.355 `\Omega`{=tex} \]

Using the `powergui` impedance measurement:

\[ Z\_{1,`\text{Simulink}`{=tex}} =1.7773+j32.4225 `\Omega`{=tex} \]

Magnitudes:

\[ \|Z\_{1,`\text{MATLAB}`{=tex}}\|`\approx32.403`{=tex} `\Omega`{=tex}
\]

\[
\|Z\_{1,`\text{Simulink}`{=tex}}\|`\approx32.471`{=tex} `\Omega`{=tex}
\]

Difference:

\[ `\boxed{\approx0.21\%}`{=tex} \]

This provides strong validation of the positive-sequence network
representation.

------------------------------------------------------------------------

## 14.2 3φ fault at Bus 3

MATLAB analytical result:

\[ I_f`\approx2.352`{=tex}`\text{ kA RMS}`{=tex} \]

Simulink produced approximately 3.328 kA peak.

Because the Specialized Power Systems phasor representation is
peak-based:

\[ I\_{RMS}=`\frac{I_{peak}}{\sqrt{2}}`{=tex} \]

giving approximately:

\[ I\_{Simulink}`\approx2.353`{=tex}`\text{ kA RMS}`{=tex} \]

Difference:

\[ `\boxed{\approx0.04\%}`{=tex} \]

------------------------------------------------------------------------

## 14.3 LG fault at Bus 3

MATLAB:

\[ I_A`\approx2.291`{=tex}`\text{ kA RMS}`{=tex} \]

Simulink:

\[ I_A`\approx2.334`{=tex}`\text{ kA RMS}`{=tex} \]

Difference:

\[ `\boxed{\approx1.86\%}`{=tex} \]

The B- and C-phase currents were negligible, consistent with an A-G
fault.

------------------------------------------------------------------------

## 14.4 LLG fault at Bus 4

For the B-C-G fault:

  Phase     MATLAB RMS   Simulink RMS
  ------- ------------ --------------
  A          ≈0.450 kA             ≈0
  B           2.391 kA       3.078 kA
  C           2.248 kA       3.051 kA

The Simulink sequence currents were approximately:

  Sequence     Simulink RMS   MATLAB analytical RMS
  ---------- -------------- -----------------------
  (I_0)            1.304 kA                0.783 kA
  (I_1)            2.014 kA                1.546 kA
  (I_2)            0.710 kA                0.765 kA

The larger discrepancy for the LLG case is associated with the
representation of generator sequence impedances. The analytical model
explicitly uses independent (Z_1), (Z_2), and (Z_0) generator
impedances, while the standard Three-Phase Source blocks used in the
Simulink validation do not reproduce the same independent
sequence-source specification.

Therefore, the LLG case is treated as a qualitative/partial cross-check
rather than an exact numerical validation.

------------------------------------------------------------------------

# 15. Validation Summary

  Validation                    Result
  ----------------------------- --------------------------------------------------
  Sequence transformation       Validated
  Ybus/Zbus symmetry            Validated
  (YZ=I) check                  Validated
  Fault boundary conditions     Passed
  Positive-sequence impedance   0.21% difference
  3φ Bus-3 fault                \~0.04% difference
  LG Bus-3 fault                \~1.86% difference
  LLG Bus-4 fault               Larger deviation due to source sequence modeling

------------------------------------------------------------------------


------------------------------------------------------------------------

# 16. Requirements

### Software

-   MATLAB R2021a or compatible MATLAB release
-   Simulink
-   Simscape
-   Simscape Electrical / Specialized Power Systems

### MATLAB knowledge

The project assumes familiarity with:

-   Complex numbers and phasors
-   Matrix operations
-   Per-unit systems
-   Ybus/Zbus formation
-   Symmetrical components
-   Power-system fault analysis
-   Basic Simulink modeling

------------------------------------------------------------------------


------------------------------------------------------------------------

# 17. Key Engineering Insights

### 1. Zbus is convenient for fault analysis

Once the sequence Zbus matrices are available, a fault can be applied at
any bus using the appropriate diagonal Zbus elements and Zbus columns.

### 2. Fault type determines sequence-network interconnection

-   3φ → positive sequence only
-   LG → all three sequence networks in series
-   LL → positive and negative sequence
-   LLG → all three sequence networks with a parallel combination

### 3. Zero-sequence connectivity is critical for ground faults

The Δ--Yg transformer prevents zero-sequence current from passing
directly from the grounded-wye transmission side into the delta
generator side.

### 4. Ground faults can exceed 3φ faults

A ground fault is not necessarily less severe than a 3φ fault. When the
zero-sequence impedance is sufficiently low, LG fault current can exceed
the 3φ fault current.

### 5. Network topology affects fault level

Removing line 2--4 changes the Zbus matrices and therefore changes the
fault level at every bus, with the largest observed 3φ change occurring
at Bus 4.

### 6. Per-unit analysis simplifies multi-voltage-level systems

The 11-kV and 132-kV portions can be analyzed in a common 100-MVA
per-unit system, with actual currents recovered using the appropriate
bus current base.

------------------------------------------------------------------------

# 18. Limitations

This project is a study model rather than a full electromagnetic
transient representation.

The main assumptions are:

-   Prefault voltage is fixed at 1.0 pu.
-   Loads are neglected.
-   Shunt capacitance is neglected in the analytical model.
-   Network elements are represented using constant sequence impedances.
-   Faults are represented using ideal sequence-network equations.
-   Generator sequence impedances are assumed rather than obtained from
    machine models.
-   The Simulink Three-Phase Source blocks do not independently
    reproduce all specified generator (Z_1), (Z_2), and (Z_0) values.
-   The LLG Simulink case therefore shows a larger numerical difference
    than the 3φ and LG cases.

The following are intentionally outside the scope of this project:

-   Relay coordination
-   CT saturation
-   Distance protection
-   Differential protection
-   Arc-impedance models
-   Electromagnetic transient simulations
-   Real-time protection hardware
-   Large IEEE benchmark systems

------------------------------------------------------------------------


------------------------------------------------------------------------

# 19. Recommended Figures

The following figures are recommended for the project report:

1.  Symmetrical-component transformation validation.
2.  Fault-level table or heatmap.
3.  Phase-current phasors for representative faults.
4.  Post-fault voltage profiles.
5.  Generator contribution to the Bus-3 fault.
6.  Line-current contribution.
7.  Fault current versus fault impedance.
8.  LG current versus generator neutral impedance.
9.  Δ--Yg versus Yg--Yg LG fault comparison.
10. Line-outage fault-level comparison.
11. MATLAB versus Simulink validation comparison.

------------------------------------------------------------------------

# 20. Technologies Used

-   MATLAB
-   Simulink
-   Simscape Electrical
-   Specialized Power Systems
-   Ybus/Zbus analysis
-   Symmetrical components
-   Per-unit system
-   Sequence networks
-   Power-system fault analysis
-   Numerical matrix methods

------------------------------------------------------------------------

## Conclusion

This project implements a complete symmetrical-component-based
fault-analysis workflow for a custom 5-bus power system.

The MATLAB model forms positive-, negative-, and zero-sequence Ybus/Zbus
matrices and uses them to calculate 3φ, LG, LL, and LLG faults at every
bus. Additional studies investigate post-fault voltages, generator and
line contributions, fault impedance, neutral grounding, transformer
zero-sequence connections, and line outages.

The positive-sequence network was independently cross-checked in
Simulink, with the measured Bus-3 positive-sequence impedance differing
from the analytical result by approximately 0.21%. The 3φ Bus-3 fault
showed approximately 0.04% difference after converting Simulink peak
phasors to RMS values, while the LG Bus-3 case differed by approximately
1.86%.

The LLG Bus-4 case showed a larger numerical deviation because the
analytical model explicitly represents independent generator positive-,
negative-, and zero-sequence impedances, whereas the standard
Three-Phase Source representation used for the Simulink cross-check does
not reproduce those independent sequence-source parameters. This
limitation is documented rather than compensated for by altering the
validated network parameters.
