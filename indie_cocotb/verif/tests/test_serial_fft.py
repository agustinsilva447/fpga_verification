"""Butterfly - module testbench"""

import sys
from pathlib import Path
import cocotb
import cocotb.regression
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, Timer
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject
from cocotb_test.simulator import Simulator
import pytest
import numpy as np

sys.path.append(str(Path(__file__).parent.parent.parent.resolve() / 'model' / 'python'))
from fft_utils import my_fft, gen_sin_data, rnd, sat, write_twiddle_rom


VERILOG_SOURCES_DIR = Path(__file__).parent.parent.parent.resolve() / "rtl"


@pytest.mark.parametrize("MAXSIZE", ["16"])
def test_serial_fft(simulator: Simulator, MAXSIZE: str):
    """Run parametrized CoCoTB test with pytest"""
    simulator.parameters["MAXSIZE"] = MAXSIZE
    simulator.run()

@cocotb.test()
async def real_sine_wave(dut: HierarchyObject, seed=7):
    """Cosimulate RTL and model and compare results"""

    NBD: int = dut.NBD.value
    NBT: int = dut.NBT.value
    NSIZES: int = dut.NSIZES.value  # Not using this one
    MAXSIZE: int = dut.MAXSIZE.value

    write_twiddle_rom(NFFT=MAXSIZE, NBT=NBT, directory=VERILOG_SOURCES_DIR)

    np.random.seed(seed)
    i_complex = np.random.uniform(0, 1, MAXSIZE) * np.exp(1.j * np.random.uniform(0, 2 * np.pi, MAXSIZE))
    i_data = sat(rnd(np.real(i_complex) * 2 ** (NBD-1)), NB=NBD) + 1j * sat(rnd(np.imag(i_complex) * 2 ** (NBD-1)), NB=NBD)
    
    o_data = my_fft(x=i_data, NBT=NBT)

    o_d = {'o_real': [], 'o_imag': []}

    await startup(dut)

    await RisingEdge(dut.clk)
    dut.i_valid.value = 1

    # Drive input
    i = 0
    while True:
        if i < len(i_data):
            # Drive inputs
            dut.i_real.value = int(np.real(i_data[i]))
            dut.i_imag.value = int(np.imag(i_data[i]))
        # Collect output
        # o_d = get_output(dut, o_d)
        if dut.o_valid.value == 1:
            o_d['o_real'].append(dut.o_real.value.signed_integer)
            o_d['o_imag'].append(dut.o_imag.value.signed_integer)
        if len(o_d['o_real']) == len(i_data):
            break
        await RisingEdge(dut.clk)
        i += 1

    o_d_golden = {
        'o_real': [np.real(data) for data in o_data],
        'o_imag': [np.imag(data) for data in o_data]
        }

    # Assert all outputs equals golden
    for key in o_d:
        try:
            assert o_d_golden[key] == o_d[key]
        except AssertionError:
            dut._log.info(f'Output "{key}" does not match the expected value')
            for i in range(len(o_d[key])):
                if o_d[key][i] != o_d_golden[key][i]:
                    dut._log.info(f'Output [{i}] should be "{o_d_golden[key][i]}" but is "{o_d[key][i]}"')
            assert 0, f'Test with {seed=} failed'


tf = cocotb.regression.TestFactory(real_sine_wave)
tf.add_option(name="seed", optionlist=np.random.choice(1000, size=(10, 1)).tolist())
tf.generate_tests()

async def random_complex_data(dut: HierarchyObject, seed=7):
    """Cosimulate RTL and model and compare results"""

    NBD: int = dut.NBD.value
    NBT: int = dut.NBT.value
    NSIZES: int = dut.NSIZES.value  # Not using this one
    MAXSIZE: int = dut.MAXSIZE.value


    write_twiddle_rom(NFFT=MAXSIZE, NBT=NBT, directory=VERILOG_SOURCES_DIR)

    i_data = gen_sin_data(frequency=np.random.randint(low=0, high=round((MAXSIZE/2)-1)), sample_rate=MAXSIZE)
    i_data = sat(rnd(i_data * 2 ** (NBD - 1)), NBD)

    o_data = my_fft(x=i_data, NBT=NBT)

    o_d = {'o_real': [], 'o_imag': []}

    await startup(dut)

    await RisingEdge(dut.clk)
    dut.i_valid.value = 1

    # Drive input
    i = 0
    while True:
        if i < len(i_data):
            # Drive inputs
            dut.i_real.value = int(np.real(i_data[i]))
            dut.i_imag.value = int(np.imag(i_data[i]))
        # Collect output
        # o_d = get_output(dut, o_d)
        if dut.o_valid.value == 1:
            o_d['o_real'].append(dut.o_real.value.signed_integer)
            o_d['o_imag'].append(dut.o_imag.value.signed_integer)
        if len(o_d['o_real']) == len(i_data):
            break
        await RisingEdge(dut.clk)
        i += 1

    o_d_golden = {
        'o_real': [np.real(data) for data in o_data],
        'o_imag': [np.imag(data) for data in o_data]
        }

    # Assert all outputs equals golden
    for key in o_d:
        try:
            assert o_d_golden[key] == o_d[key]
        except AssertionError:
            dut._log.info(f'Output "{key}" does not match the expected value')
            for i in range(len(o_d[key])):
                if o_d[key][i] != o_d_golden[key][i]:
                    dut._log.info(f'Output [{i}] should be "{o_d_golden[key][i]}" but is "{o_d[key][i]}"')
            assert 0, f'Test with {seed=} failed'


tf = cocotb.regression.TestFactory(random_complex_data)
tf.add_option(name="seed", optionlist=np.random.choice(1000, size=(10, 1)).tolist())
tf.generate_tests()


async def startup(dut: HierarchyObject):
    """Startup sequence"""
    period = 10
    cocotb.start_soon(Clock(dut.clk, period, units="ns").start())
    await Timer(np.random.randint(1000*period), units="ps")  # wait a bit
    dut.rst_async_n.value = 0
    dut.i_size.value = 0  # Using the max value always
    dut.i_real.value = 0
    dut.i_imag.value = 0
    dut.i_valid.value = 0
    await Timer(np.random.randint(1000*period, 2000*period), units="ps")  # wait a bit
    dut.rst_async_n.value = 1
    await ClockCycles(dut.clk, 2)
