from typing import Sequence
from textwrap import wrap
from numfi import numfi
import cocotb


def binstr2list(
    binstr: str,
    bits: int = 1,
    bigEndian=False,
    binaryRepresentation=cocotb.binary.BinaryRepresentation.TWOS_COMPLEMENT,
) -> list[int]:
    """Converts a binstr to a list of int values, delimited by bits.
    Defaults to 1 bit per symbol represented in complements of two with little endianness.

    Example:
        >>> binstr2list('000100111011', bits=1)
        [0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1]

        >>> binstr2list('000100111011', bits=4)
        [1, 3, -5]

        >>> binstr2list('000100111011', bits=3)
        [0, -4, -1, 3]

        >>> binstr2list('000000000001', bits=4, bigEndian=True)
        [0, 0, 1]

        By default it will return the Two-Complement representation

        >>> binstr2list('1111', bits=4)
        [-1]

        But it can be set to: 0=Unsigned, 1=Signed magnitude, 2=Two-complement (default)
        >>> binstr2list('1111', bits=4, binaryRepresentation=0)
        [15]
    """
    if bits == 1:
        return [int(bit) for bit in list(binstr)]

    return [
        cocotb.binary.BinaryValue(
            value=byte,
            n_bits=bits,
            bigEndian=bigEndian,
            binaryRepresentation=binaryRepresentation,
        ).integer
        for byte in wrap(binstr, bits)
    ]


def list2binstr(
    values: Sequence[int],
    bits: int = 1,
    bigEndian=False,
    binaryRepresentation=cocotb.binary.BinaryRepresentation.TWOS_COMPLEMENT,
) -> str:
    """Converts a list of values into a binary string, delimited by bits.
    Defaults to 1 bit per symbol represented in complements of two with little endianness.

    Example:
        >>> list2binstr([0, 1, -2, 3], bits=4)
        0000000111100011

        Make sure to check the correct bit length, or might get an overflowed value.
        RuntimeWarning: 2-bit value requested, truncating value '011' (3 bits) to '01'

        >>> list2binstr([0, 1, -2, 3], bits=2)
        00011001

        Is not possible to use unsigned representation with negative values

        >>> list2binstr([0, 1, -2, 3], bits=4, binaryRepresentation=0)
        Traceback (most recent call last):
            ...
        ValueError: Attempt to assigned negative number to unsigned BinaryValue
    """
    if bits == 1:
        return cocotb.binary.BinaryValue(
            "".join(map(str, map(int, values))), bigEndian=False, binaryRepresentation=0
        )

    binstr = [
        cocotb.binary.BinaryValue(
            value=int(value),
            n_bits=bits,
            bigEndian=bigEndian,
            binaryRepresentation=binaryRepresentation,
        ).binstr
        for value in values
    ]

    # For some reason, the binstr zeros are represented as ''.
    binstr = ["0" * bits if x == "" else x for x in binstr]

    return cocotb.binary.BinaryValue(
        "".join(binstr), bigEndian=False, binaryRepresentation=0
    )


def binstr2float(
    binstr: str,
    fractional: int,
    binaryRepresentation=cocotb.binary.BinaryRepresentation.TWOS_COMPLEMENT,
):
    """Convert a fixed-point from binary string representation into a float.

    Arguments:
        binstr: binary string representation for the number to convert.
        freactional: number of fractional bits.
        binaryRepresentation: defines if binstr is signed, unsigned, twos_complement.

    Example:
        Convert 01010101 s(8,7) complement two, to float.

        >>> binstr2float("01010101", fractional=7)
        0.6640625

        Convert 0111001 u(7,7) unsigned to float.
        >>> binstr2float("0111001", fractional=7, binaryRepresentation=cocotb.binary.BinaryRepresentation.UNSIGNED)
        0.4453125
    """
    return cocotb.binary.BinaryValue(
        binstr, bigEndian=False, binaryRepresentation=binaryRepresentation
    ).integer / (2**fractional)


def float2binstr(
    value: float,
    word: int,
    fractional: int,
    binaryRepresentation=cocotb.binary.BinaryRepresentation.TWOS_COMPLEMENT,
):
    """Convert a float number into a fixed-point binary string representation format.

    Arguments:
        value: float number to convert into a fixed-point binary representation.
        word: number of bits to represent the word (sign, integer and fractional bits).
        fractional: number of fractional bits.
        binaryRepresentation: defines if the binstr is signed or unsigned.

    Example:
        Convert -1 into s(8,7) two's complement binary representation.

        >>> float2binstr(-1, word=8, fractional=7)
        '10000000'

        >>> float2binstr(0.0078125, word=8, fractional=7)
        '00000001'

        >>> float2binstr(-0.0078125, word=8, fractional=7)
        '11111111'

        >>> float2binstr(0.001, word=8, fractional=7)
        '00000000'

        >>> float2binstr(0, word=8, fractional=7)
        '00000000'
    """

    # Quantize
    sign = 1 if binaryRepresentation else 0
    fixed_point = int(
        numfi(
            value, s=sign, w=word, f=fractional, rounding="zero", overflow="saturate"
        ).int
    )
    if fixed_point == 0:
        return "0" * word

    return cocotb.binary.BinaryValue(
        fixed_point,
        n_bits=word,
        bigEndian=False,
        binaryRepresentation=binaryRepresentation,
    ).binstr
