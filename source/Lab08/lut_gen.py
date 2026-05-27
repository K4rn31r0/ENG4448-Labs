import argparse
import math
from typing import Callable, Protocol


class WaveformFunc(Protocol):
    def __call__(self, t: list[float]) -> list[float]: ...


def generate_lut(
    func: WaveformFunc,
    n_samples: int = 16,
    bits_per_sample: int = 12
) -> list[int]:
    """
    Gera LUT de <n_samples> amostras, com cada amostra tendo <bits_per_sample> bits.
    func é uma função com imagem [-1, 1].
    """
    max_val = (1 << bits_per_sample) - 1    # 12 bits -> 4095
    mid_val = max_val / 2                   # DC offset

    t = [2 * math.pi * i / n_samples for i in range(n_samples)]
    samples_f = func(t)

    # Normalização garante que func está entre -1 e 1
    peak = max(abs(x) for x in samples_f)
    if peak > 0:
        samples_f = [x / peak for x in samples_f]

    # Mapping [-1, 1] --> [0, 4095] para n_bits = 12
    samples_int = [
        max(0, min(max_val, round(mid_val + mid_val * x)))
        for x in samples_f
    ]

    return samples_int


def print_lut_hex(samples: list[int], bits: int = 12) -> None:
    hex_digits = (bits + 3) // 4
    n = len(samples)

    print(f"LUT gerada: {n} amostras, resolução {bits} bits")
    print("constant SAMPLE_ROM : sample_rom_t := (")
    for i, val in enumerate(samples):
        sep = "," if i < n - 1 else " "
        print(f"    x\"{val:0{hex_digits}X}\"{sep}  -- i={i:>3} : {val:>4}")
    print(");")


AVAILABLE_FUNCS: dict[str, Callable[[list[float]], list[float]]] = {
    "cos_cos2": lambda t: [math.cos(x) * math.cos(2 * x) for x in t],
    "sin":      lambda t: [math.sin(x) for x in t],
    "cos":      lambda t: [math.cos(x) for x in t],
    "sin_cos2": lambda t: [math.sin(x) * math.cos(2 * x) for x in t],
    "square":   lambda t: [math.copysign(1.0, math.sin(x)) for x in t],
    "sawtooth": lambda t: [(x / math.pi) - 1 for x in t],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Gera LUT de amostras para DAC em formato VHDL.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-n", "--n-samples",
        type=int,
        default=16,
        help="Número de amostras por período",
    )
    parser.add_argument(
        "-b", "--bits",
        type=int,
        default=12,
        choices=[8, 10, 12, 14, 16],
        help="Resolução do DAC em bits",
    )
    parser.add_argument(
        "-f", "--func",
        type=str,
        default="cos_cos2",
        choices=list(AVAILABLE_FUNCS.keys()),
        help="Função de entrada",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.n_samples < 2:
        raise ValueError("n_samples deve ser >= 2")

    func = AVAILABLE_FUNCS[args.func]
    samples = generate_lut(func, args.n_samples, args.bits)  # ordem corrigida
    print_lut_hex(samples, args.bits)


if __name__ == "__main__":
    main()