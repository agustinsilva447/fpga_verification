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
from fft_utils import write_twiddle_rom, rnd, sat, butterfly_vector_gen


def test_butterfly(simulator: Simulator):
    """Run parametrized CoCoTB test with pytest"""
    simulator.run()

async def model_cosimulation(dut: HierarchyObject, seed=7):
    """Cosimulate RTL and model and compare results"""

    NBD: int = dut.NBD.value
    NBT: int = dut.NBT.value

    L = 512

    v_d = butterfly_vector_gen(NBD=NBD, NBT=NBT, L=L, seed=seed)
    r_d = {}
    for key in v_d.keys():
        if key.startswith('o_'):
            r_d[key] = []

    # Drive input
    for i in range(len(v_d['i_twiddle_real'])):
        dut.i_x_real.value = v_d['i_x_real'][i]
        dut.i_x_imag.value = v_d['i_x_imag'][i]
        dut.i_y_real.value = v_d['i_y_real'][i]
        dut.i_y_imag.value = v_d['i_y_imag'][i]
        dut.i_twiddle_real.value = v_d['i_twiddle_real'][i]
        dut.i_twiddle_imag.value = v_d['i_twiddle_imag'][i]
        await Timer(1, units="ps")  # wait a bit
        # Collect output
        r_d = get_output(dut, r_d)

    # Assert all outputs equals golden
    for key in r_d:
        try:
            assert r_d[key] == v_d[key]
        except AssertionError:
            dut._log.info(f'Output "{key}" does not match the expected value')
            for i in range(len(r_d[key])):
                if v_d[key][i] != r_d[key][i]:
                    txt = (f'For the inputs:\n'
                           f'{v_d["i_x_real"][i]=}\t'
                           f'{v_d["i_x_imag"][i]=}\t'
                           f'{v_d["i_y_real"][i]=}\t'
                           f'{v_d["i_y_imag"][i]=}\t'
                           f'{v_d["i_twiddle_real"][i]=}\t'
                           f'{v_d["i_twiddle_imag"][i]=}\t')
                    dut._log.info(txt)
                    dut._log.info(f'Output [{i}] should be "{v_d[key][i]}" but is "{r_d[key][i]}"')
            assert 0, f'Test with {seed=} failed'
 
tf = cocotb.regression.TestFactory(model_cosimulation)
tf.add_option(name="seed", optionlist=np.random.choice(1000, size=(10, 1)).tolist())
tf.generate_tests()

def get_output(dut: HierarchyObject, r_d: dict[str, list]):
    r_d['o_x_real'].append(dut.o_x_real.value.signed_integer)
    r_d['o_x_imag'].append(dut.o_x_imag.value.signed_integer)
    r_d['o_y_real'].append(dut.o_y_real.value.signed_integer)
    r_d['o_y_imag'].append(dut.o_y_imag.value.signed_integer)
    return r_d