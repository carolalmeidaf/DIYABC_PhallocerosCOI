# Phalloceros: COI analyses and DIYABC–ABC-RF pipeline

This repository documents the final COI population analyses: demographic scenario comparison with DIYABC and abcranger, sensitivity to reference-table size, parameter estimation conditional on Scenario 2, and prior predictive checking. The COI landscape-genetic analyses are documented separately below. Laboratory procedures, RAG1, historical analyses, and diagnostic BEAST runs are outside this pipeline.

## Reproducibility status

This package contains documentation and a newly assembled shell pipeline based on the supplied analysis record. It does **not** contain the original input files, reference tables, executables, or analysis outputs. Add and verify these before release. The shell script has not been run against the scientific data.

Two levels of reproduction must be distinguished:

- **Reanalysis of archived simulations:** requires the final reference table, its matching header, observed statistics, and the recorded abcranger executable/settings.
- **Regeneration from COI:** additionally requires complete DIYABC project configuration, simulation command, simulation seed/random-number state, and software provenance. The original simulation command and seed were not available in the supplied record. The abcranger seed below must not be assumed to be the DIYABC simulation seed.

The exact original scripts for prior predictive checking and landscape analyses are also pending. This repository should not yet be described as fully reproducible from raw COI.

## 1. Repository organization

Suggested paths (create the directories and add actual files):

```text
README.md
scripts/
  run_abcranger.sh
  prior_predictive_check.py       # original script to recover and add
  landscape_COI.R                # original script to recover and add
metadata/
  PHCOI_corrected_mapping.tsv
  software_versions.txt
  simulation_commands.txt
  checksums.sha256
pop1/
  PHCOI_pop1.mss
  headerRF.txt
  statobsRF.txt
  reftableRF.bin
  [remaining original DIYABC project files and simulation logs]
pop2/
  PHCOI_pop2.mss
  headerRF.txt
  statobsRF.txt
  reftableRF.bin
  [remaining original DIYABC project files and simulation logs]
pop3/
  PHCOI_pop3.mss
  headerRF.txt
  statobsRF.txt
  reftableRF.bin
  [remaining original DIYABC project files and simulation logs]
bin/
  [locally installed executables; distribution subject to their licenses]
results/
  archived/                      # original results, unchanged
  rerun/                         # newly generated results
```

Keep each population's original project configuration together. Preserve header filenames and the MSS filename referenced by the project; changing a filename without updating its references may break reproduction. Separate populations by directory rather than adding browser-download suffixes such as `(2)` or `(3)`. Rename only after checking the contents and associated project references.

Do not reconstruct original project headers from the descriptions below. Upload their exact final versions, including settings for marker type/ploidy, sequence length, scenarios, priors, and summary statistics. A list of priors in a README does not replace an executable project configuration.

## 2. COI inputs

The analysis used 81 focal COI sequences, each 569 bp long, grouped by geomorphological compartment. Reference/outgroup sequences are excluded from the ABC inputs.

| Input | Compartment | Localities | Focal sequences | Reported sequence-pattern frequencies |
|---|---|---|---:|---|
| `PHCOI_pop1.mss` | Mountain Escarpment | MAC, CON, TRC, SAN | 36 | 32, 2, 1, 1 |
| `PHCOI_pop2.mss` | Rounded Foothills | ATA, BOM, DAN | 26 | 25, 1 |
| `PHCOI_pop3.mss` | Lowland Plain | JUR, POC, COM | 19 | 17, 2 |

Archive `PHCOI_corrected_mapping.tsv`, linking each input sequence identifier to its locality and compartment. Include the final focal alignment if available. The three compartments were analyzed independently; Pop1–Pop3 label separate analyses, not three simultaneously modeled populations.

## 3. Software and execution environment

The supplied record reports:

| Component | Recorded version / environment | Role |
|---|---|---|
| DIYABC executable | macOS ARM build, v1.1.54 | Simulation |
| abcranger | native ARM64, v1.16.69 | ABC random forests |
| DIYABC Linux executable | v1.1.27, x86-64 | Binary-to-text export |
| Docker | 29.8.2 | Linux export environment |
| Container image | `ubuntu:22.04`, `linux/amd64` | Linux export environment |
| Original host | macOS, Apple Silicon (`arm64`) | Original execution |

These executable labels come from the analysis record and must be checked against the actual binaries. Record source/release URL or commit, binary SHA-256, build details, OS version, and full `--help` output where available. For the container, record its image digest; a tag alone does not pin identical bytes.

Official abcranger documentation: https://github.com/diyabc/abcranger

The pipeline retains 1,000 trees, four threads, seed 12345, and the recorded parameter-estimation OOB setting. Other abcranger options use the executable's defaults. Preserve the original `.settings` files and help output to identify these defaults. Do not silently replace the original executable with a different version and claim identical reproduction.

## 4. Demographic scenarios and priors

Both scenarios were fitted independently to each compartment.

**Scenario 1: constant population size**

```text
N
0 sample 1
```

**Scenario 2: population-size changes at two past times**

```text
N1 N2 N3
0 sample 1
t1 VarNe 1 N2
t2 VarNe 1 N3
```

`N1` represents the current interval, `N2` the intermediate interval, and `N3` the oldest interval. Scenario 2 does not constrain change to expansion or contraction. The chronological direction is `N3 → N2 → N1`.

The record explicitly lists the following historical priors for Pop1 and Pop3. Check the final Pop2 header before claiming that all historical priors were identical; only its molecular-rate standardization is explicitly documented.

```text
N   UN[10,10000,0,0]
N1  UN[10,10000,0,0]
N2  UN[10,10000,0,0]
N3  UN[10,10000,0,0]
t1  UN[10,12000,0,0]
t2  UN[24000,32000,0,0]
```

Times are in generations. At four generations per year, `t1` spans 2.5–3,000 years and `t2` spans 6,000–8,000 years. The conversion is an assumption, not an additional analysis.

The following sequence-evolution settings were reported as standardized across the compartments. Preserve their original syntax and verify against each final header:

```text
MEANMU UN[4.37175e-09,1.1952825e-07,0,0]
GAMMU GA[1e-09,1e-06,Mean_u,2]
MEANK1 UN[0.05,20,0,0]
GAMK1 GA[2.49626756e-06,6.825063244e-05,Mean_k1,2]
MEANK2 UN[0.05,20,10,2]
GAMK2 GA[0.05,20,Mean_k2,2]
MODEL K2P 10 2
```

The mitochondrial rate interval was retained from the previous calibrated COI analysis. This pipeline uses that fixed prior specification; it does not reproduce the calibration analysis or independently verify its rate derivation.

Eight summary-statistic codes were retained: `NHA`, `NSS`, `MPD`, `VPD`, `DTA`, `PSS`, `MNS`, `VNS`. Use the original headers as the authoritative selection/order and the matching DIYABC manual for definitions.

| Statistic | Pop1 | Pop2 | Pop3 |
|---|---:|---:|---:|
| NHA | 4 | 2 | 2 |
| NSS | 3 | 1 | 1 |
| MPD | 0.2190476190 | 0.07692307692 | 0.1988304094 |
| VPD | 0.1872359755 | 0.07122507123 | 0.1602339181 |
| DTA | -1.56135462 | -1.155587505 | -0.5621638753 |
| PSS | 3 | 1 | 1 |
| MNS | 1.333333 | 1 | 2 |
| VNS | 0.222222 | 0 | 0 |

These values are transcribed from the methods record. Retain full precision in the original `statobsRF.txt` files.

## 5. Generate or retrieve reference tables

Each compartment used **100,000 simulated datasets in total across the two scenarios**, not 100,000 per scenario. Archive the final `reftableRF.bin`, matching `headerRF.txt` and `statobsRF.txt`, full project configuration, simulation logs, and available random-number state files.

Reported scenario counts:

| Compartment | Scenario 1 | Scenario 2 | Total |
|---|---:|---:|---:|
| Pop1 | 50,058 | 49,942 | 100,000 |
| Pop2 | 49,835 | 50,165 | 100,000 |
| Pop3 | 50,242 | 49,758 | 100,000 |

**Pending:** recover the original simulation commands from shell history or original run logs. Add exact commands, working directories, seed/state initialization, and any batching/resumption procedure to `metadata/simulation_commands.txt`. No replacement simulation command is provided here because the original invocation was not recorded.

## 6. Model choice, sensitivity, and parameter estimation

Install the recorded abcranger executable at `bin/abcranger` or set `ABCRANGER` to its absolute path. Run from the repository root:

```bash
bash scripts/run_abcranger.sh
```

The supplied script checks required inputs, creates a new output directory without overwriting previous results, and runs the following analyses separately for each compartment:

1. Model choice with 20,000, 50,000, and 100,000 records from the same final table.
2. Estimation of `N1`, `N2`, and `N3`, conditional on Scenario 2, using `-n 100000`, `--noob 15000`, 1,000 trees, four threads, and seed 12345.

The sensitivity analyses request different record counts from the same table; they are not independently regenerated simulation tables or newly randomized subsamples.

Equivalent model-choice command, inside a population directory:

```bash
../bin/abcranger -h headerRF.txt -r reftableRF.bin -b statobsRF.txt \
  -o ../results/rerun/pop1/modelchoice_100k \
  -n 100000 -t 1000 -j 4 -s 12345
```

Equivalent parameter-estimation command (repeat for `N2` and `N3`):

```bash
../bin/abcranger -h headerRF.txt -r reftableRF.bin -b statobsRF.txt \
  -o ../results/rerun/pop1/param_N1 \
  -n 100000 -t 1000 -j 4 -s 12345 \
  --parameter N1 --chosenscen 2 --noob 15000
```

Example paths refer to Pop1; use the corresponding input and output directories for the other compartments. Create output directories before manual commands. The shell script handles this automatically.

Preserve all original outputs, particularly `.predictions`, `.ooberror`, `.confusion`, `.importance`, `.settings`, run logs, parameter prediction weights, and OOB diagnostics where generated. RF votes are not posterior probabilities. Check whether the predictions file reports posterior error or probability before reporting its value.

### Reported model-choice results

| Compartment | Records | S1 votes | S2 votes | Selected scenario | Reported posterior probability | Reported prior error |
|---|---:|---:|---:|---:|---:|---:|
| Pop1 | 20,000 | 370 | 630 | 2 | 0.649 | 0.50100 |
| Pop1 | 50,000 | 536 | 464 | 1 | 0.497 | 0.49618 |
| Pop1 | 100,000 | 614 | 386 | 1 | 0.489 | 0.49777 |
| Pop2 | 20,000 | 625 | 375 | 1 | 0.656 | 0.49910 |
| Pop2 | 50,000 | 574 | 426 | 1 | 0.492 | 0.49590 |
| Pop2 | 100,000 | 308 | 692 | 2 | 0.521 | 0.49926 |
| Pop3 | 20,000 | 515 | 485 | 1 | 0.534 | 0.50515 |
| Pop3 | 50,000 | 453 | 547 | 2 | 0.553 | 0.49972 |
| Pop3 | 100,000 | 551 | 449 | 1 | 0.496 | 0.49774 |

This table is transcribed from the supplied report, not recalculated from original outputs. Verify it against the archived files. The record indicates weak discrimination and sensitivity of scenario selection to table size.

### Reported parameter estimates conditional on Scenario 2

| Compartment | Parameter | Expectation | Median | q05 | q95 |
|---|---|---:|---:|---:|---:|
| Pop1 | N1 | 5985.90 | 6039 | 3638 | 9464 |
| Pop1 | N2 | 4844.23 | 4390 | 556 | 9498 |
| Pop1 | N3 | 5217.76 | 5242 | 460.262 | 9482 |
| Pop2 | N1 | 6009.70 | 6337 | 1687 | 9551 |
| Pop2 | N2 | 4604.26 | 4588 | 477.1 | 9361 |
| Pop2 | N3 | 5242.55 | 5236 | 461 | 9676.21 |
| Pop3 | N1 | 6148.70 | 6492 | 1597 | 9683 |
| Pop3 | N2 | 5509.49 | 5719 | 839 | 9532 |
| Pop3 | N3 | 4589.29 | 4779.56 | 392 | 9024 |

The q05–q95 interval spans the central 90% of the reported posterior distribution. These estimates are conditional on Scenario 2 even where Scenario 1 received more RF votes; they are not model-averaged estimates. Broad uncertainty and weak model discrimination limit demographic interpretation.

## 7. Prior predictive checks

The final checks used the same 100,000-record tables. They are **prior predictive**, not posterior predictive checks. The original DIYABC observed-data location routine failed, so checks were performed externally after binary-to-text export.

### Export in an isolated working copy

From the repository root, for Pop1 (repeat for Pop2 and Pop3):

```bash
# Choose a fresh destination; stop if it already exists.
test ! -e pop1_priorcheck || exit 1
cp -R pop1 pop1_priorcheck
cd pop1_priorcheck
cp reftableRF.bin reftable.bin

docker run --rm --platform linux/amd64 \
  -v "$PWD:/work" \
  -v "$PWD/../bin:/tools:ro" \
  -w /work ubuntu:22.04 \
  /tools/diyabc_linux_1.1.27 -p ./ -x
```

This is the successful export command recorded in the methods. Keep any additional original project files required by the exporter in the copied directory. For Pop1, the reported export contained eight header lines and 100,000 records. Inspect the actual header and columns for every compartment before parsing. Do not use `-l 1` as an export option.

### Calculate checks

Recover and add the original `prior_predictive_check.py`. Its recorded invocation, from each prior-check directory, was:

```bash
python3 ../scripts/prior_predictive_check.py reftable.txt pop1
```

For each scenario and statistic, the script must calculate `count(simulated < observed) / n`. For observed zero values, also report `count(simulated == observed) / n` so ties at a boundary are not interpreted as evidence of poor fit. Document handling of undefined/nonfinite statistics and the denominator used for each statistic. Archive tabulated results and the exact observed values.

The original parser was not supplied; a substitute parser is not included because the actual exported table layout has not been inspected.

Reported main checks: Pop1 DTA lower-tail proportions were approximately 0.0032 and 0.0033 under Scenarios 1 and 2. The reported VNS zero frequencies were 86.8305–87.7424% for Pop2 and 88.7823–89.6861% for Pop3. These univariate checks do not establish overall model adequacy or favor one scenario.



