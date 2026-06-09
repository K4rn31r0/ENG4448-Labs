#!/usr/bin/env python3
"""
Gera a escala de ativacao dos LEDs a partir do valor do ADC (Lab09).

O ADC LTC1407A-1 entrega D[13:0] em complemento de 2 (-8192..8191).
Com ganho -1 (Eq. 10-1 do UG230):  D = -(VIN - 1.65) / 1.25 * 8192
  => VIN = 1.65 - D * 1.25 / 8192

Como o ganho e inversor, a tensao cresce conforme D fica mais negativo.
Normalizamos para um nivel crescente com a tensao:
  nivel = 8191 - D          (0 .. 16383)
  n_leds = (nivel * 9) // 16384   (0 .. 8)   -> mesma conta do VHDL

Esta tabela deve ser incluida no relatorio (Secao 1.3 do enunciado).
"""

GAIN = -1
VREF = 1.65
VRANGE = 1.25
FS = 8192  # 2**13


def vin_from_d(d: int) -> float:
    return VREF - d * VRANGE / FS


def n_leds(d: int) -> int:
    level = 8191 - d
    return (level * 9) // 16384


def main() -> None:
    # encontra, para cada quantidade de LEDs, a faixa de D e de tensao
    bands = {}
    for d in range(-8192, 8192):
        n = n_leds(d)
        lo, hi = bands.get(n, (d, d))
        bands[n] = (min(lo, d), max(hi, d))

    print("LEDs | D[13:0] (dec)      | D (hex)         | VIN (V)")
    print("-----+--------------------+-----------------+-----------------")
    for n in range(0, 9):
        if n not in bands:
            continue
        d_lo, d_hi = bands[n]
        # tensao cresce quando D diminui, entao Vmin corresponde a d_hi
        v_at_dhi = vin_from_d(d_hi)
        v_at_dlo = vin_from_d(d_lo)
        v_min, v_max = sorted((v_at_dhi, v_at_dlo))
        hex_lo = f"{d_lo & 0x3FFF:04X}"
        hex_hi = f"{d_hi & 0x3FFF:04X}"
        print(f" {n}   | {d_lo:6d} .. {d_hi:6d} | {hex_lo} .. {hex_hi} | "
              f"{v_min:.3f} .. {v_max:.3f}")


if __name__ == "__main__":
    main()
